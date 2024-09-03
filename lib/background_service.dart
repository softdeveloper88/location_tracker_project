import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'odoo_connector.dart';

void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

const notificationId = 888;
const notificationChannelId = 'my_foreground';
var odooConnector;
// this will be used for notification id, So you can update your custom notification with this id.
Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,
      // auto start service
      autoStart: true,
      isForegroundMode: true,
      foregroundServiceTypes: [AndroidForegroundType.location],
      notificationChannelId: notificationChannelId,
      // this must match with notification channel you created above.
      initialNotificationTitle: 'Employee Location Tracker',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}
 const platformNative = MethodChannel('flutter.native/helper');

Future<void> responseDeviceId() async {
  try {
    String deviceId = await platformNative.invokeMethod("PhoneDeviceId");
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("deviceId",deviceId);

    // deviceListMode = ConnectedDevices().fetchConnectDeviceList(deviceId, widget.email);
    // print("DeviceId:: $deviceId");

  } on PlatformException catch (e) {
    debugPrint("Failed to Invoke: '${e.message}'.");
  }

}
void sendLocationData() async {
  try {
    // Get the current position (latitude and longitude)
    Position position = await GeolocatorPlatform.instance.getCurrentPosition();

    // Get the MAC address (this might require permissions on some devices)
    // String macAddress = await GetMac.macAddress;

    // Get Android ID
    // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    // String androidId = androidInfo.id;
   String deviceUniqueId;
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if(Platform.isAndroid) {
      var prefs = await SharedPreferences.getInstance();
      deviceUniqueId= prefs.getString("deviceId")??'';
        // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // deviceUniqueId = androidInfo.id;
        print('androidInfo');
      }else {
        var prefs = await SharedPreferences.getInstance();
        deviceUniqueId= prefs.getString("deviceId")??'';

        // IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
        // deviceUniqueId = iosDeviceInfo.identifierForVendor.toString();
        // print(deviceUniqueId);
        print('deviceUniqueId');
      }
      if(deviceUniqueId ==''){
         deviceUniqueId = await platformNative.invokeMethod("PhoneDeviceId");
      }

      //
    // Get the current date, time, and dateTime
    DateTime now = DateTime.now();
    String time = DateFormat('HH:mm:ss').format(now);
    String date = DateFormat('yyyy-MM-dd').format(now);
    String dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    // Create the OdooConnector instance
    var odooConnector = OdooConnector(
      'http://13.58.175.151:8017', // Odoo URL
      'staging',                   // Database name
      'mobile_app',                // Username
      '123',                       // Password
    );

    // Send the data to Odoo
    await odooConnector.sendDataToOdoo(
      mac: '',
      androidId:deviceUniqueId,
      time: time,
      date: date,
      dateTime: dateTime,
      latitude: position.latitude.toString(),
      longitude: position.longitude.toString(),
    );

    print("Data sent to Odoo successfully.");
  } catch (e) {
    print("Failed to send data to Odoo: $e");
  }
}
@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
  final Geolocator geolocator = Geolocator();
  late Position position;
  bool isCurrentTimeWithinRange(TimeOfDay startTime, TimeOfDay endTime) {
    // Get the current time
    final now = TimeOfDay.now();

    // Convert TimeOfDay to minutes since midnight
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    // Check if current time is within the specified range
    return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
  }
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // bring to foreground
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    print("${timer.isActive}");
    TimeOfDay startTime = TimeOfDay(hour: 7, minute: 0);
    TimeOfDay endTime = TimeOfDay(hour: 19, minute: 0);

    // Check if current time is within the specified range
    bool isWithinRange = isCurrentTimeWithinRange(startTime, endTime);

    // Print the result
    if (isWithinRange) {

      sendLocationData();

      print("The current time is between 7 AM and 7 PM.");
    } else {
      print("The current time is outside the range of 7 AM to 7 PM.");
    }
    // final odooConnector = OdooConnector(
    //   'http://13.58.175.151:8069',
    //   'staging',
    //   'mobile_app',
    //   '123',
    // );
    // sendAttendanceDataInBackground(
    //   'androidId',
    //   'macAddress',
    //   '2024-08-15',
    //   '12:00',
    //   '2024-08-15 12:00:00',
    //   '37.7749',
    //   '-122.4194',
    // );

    // await GeolocatorPlatform.instance
    //     .getCurrentPosition()
    //     .then((position) async {
    //  var odooConnector = OdooConnector(
    //     'http://13.58.175.151:8069',
    //     'staging',
    //     'mobile_app',
    //     '123',
    //   );
    //   await odooConnector.sendDataToOdoo(
    //     mac: '00:11:22:33:44:55',
    //     androidId: 'android-id-12345',
    //     time: '12:00:00',
    //     date: '2024-08-15',
    //     dateTime: '2024-08-15 12:00:00',
    //     latitude: position.longitude.toString(),
    //     longitude: position.longitude.toString(),
    //   );
    // });
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          notificationId,
          'Employee Track Location',
          'Time Now ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannelId,
              'FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );
      }
    }
  });
}
