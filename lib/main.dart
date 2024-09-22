import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_radar/flutter_radar.dart';
import 'package:test_project/phone_track_location_screen.dart';
import 'package:test_project/splash_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'background_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();
    initRadar();

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      Radar.logResigningActive();
    } else if (state == AppLifecycleState.paused) {
      Radar.logBackgrounding();
    }
  }

  // Add this to iOS callback for termination; Android calls this automatically
  // Radar.logTermination();
  @pragma('vm:entry-point')
  static void onLocation(Map res) {
    print('📍📍 onLocation: $res');
  }

  @pragma('vm:entry-point')
  static void onClientLocation(Map res) {
    print('📍📍 onClientLocation: $res');
  }

  @pragma('vm:entry-point')
  static void onError(Map res) {
    print('📍📍 onError: $res');
  }

  // @pragma('vm:entry-point')
  // static void onLog(Map res) {
  //   print('📍📍 onLog: $res');
  // }

  // @pragma('vm:entry-point')
  // static void onEvents(Map res) {
  //   print('📍📍 onEvents: $res');
  // }

  @pragma('vm:entry-point')
  static void onToken(Map res) {
    print('📍📍 onToken: $res');
  }

  Future<void> initRadar() async {
    Radar.initialize('prj_test_pk_9d971506565e7da310c668b140aebc7eb5655eaa');
    Radar.setUserId('flutter');
    Radar.setDescription('Flutter');
    Radar.setMetadata({'foo': 'bar', 'bax': true, 'qux': 1});
    Radar.setLogLevel('info');
    Radar.setAnonymousTrackingEnabled(false);
    Radar.onLocation(onLocation);
    Radar.onClientLocation(onClientLocation);
    Radar.onError(onError);
    // Radar.onEvents(onEvents);
    // Radar.onLog(onLog);
    Radar.onToken(onToken);
    // Radar.startTracking('efficient');
    // Radar.startTracking('responsive');
    Radar.startTracking('continuous');
    await Radar.requestPermissions(false);

    await Radar.requestPermissions(true);
    var permissionStatus = await Radar.getPermissionsStatus();
    if (permissionStatus != "DENIED") {
      var b = await Radar.startTrackingCustom({
        ... Radar.presetResponsive,
        "showBlueBar": true,
      });
      //Radar.startTracking('continuous');

      var c = await Radar.getTrackingOptions();
      print("Tracking options $c");
    }
  }
  @override
  Widget build(BuildContext context) {

    return ResponsiveSizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Time Optimizer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Scaffold(body: SplashScreens()),
      );
    });
  }
}

