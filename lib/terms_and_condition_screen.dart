import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_project/phone_track_location_screen.dart';

import 'employee_search_screen.dart';

class TermsAndConditionScreen extends StatefulWidget {
  TermsAndConditionScreen({super.key});

  @override
  State<TermsAndConditionScreen> createState() =>
      _TermsAndConditionScreenState();
}

class _TermsAndConditionScreenState extends State<TermsAndConditionScreen> {
  static const platformNative = MethodChannel('flutter.native/helper');

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
    setState(() {
      // _responseFromNativeCode1=res;
    });
  }
  bool _isChecked = false;
@override
  void initState() {
    responseDeviceId();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''
By using this app, you agree to the following terms:

This app tracks your location during work hours for monitoring purposes.
Your location data will be stored securely and used only for work-related purposes.
Unauthorized use of the app is prohibited.
The app operates only during work hours as defined by your employer.
You may stop the tracking by logging out of the app.
Your location data may be shared with authorized personnel.
By using this app, you consent to the collection and use of your location data.
The app will not track your location outside of work hours.
You have the right to review and request the deletion of your location data.
Continued use of this app constitutes acceptance of these terms.
              ''',
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: _isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value!;
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    'I agree to the Terms and Conditions',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isChecked
                    ? () async {
                  print('hello');
                        // widget.accept!();
                        // permissionLocation();
                        if (Platform.isAndroid) {
                          permissionLocation();

                          if (await _checkPermissions()) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setBool('acceptTerms', true);
                            // PhoneTrackLocationScreen().launch(context, isNewTask: true);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EmployeeSearchScreen(),
                                ));
                          }
                        } else {
                          print('hello');
                          var permission = await Geolocator.requestPermission();
                          if (permission == LocationPermission.denied) {
                          } else if (permission == LocationPermission.whileInUse) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setBool('acceptTerms', true);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EmployeeSearchScreen(),
                                ));
                          }else if(permission == LocationPermission.always){
                            SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                            await prefs.setBool('acceptTerms', true);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EmployeeSearchScreen(),
                                ));
                          }
                        }
                      }
                    : null,
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermissions() async {
    await Permission.locationWhenInUse.request();
  }

  Future<bool> _checkPermissions() async {
    return await Permission.location.isGranted;
  }

  permissionBottomSheetDialog() {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        context: context,
        builder: (context) {
          return Stack(
            children: [
              Container(
                margin: EdgeInsets.only(
                    bottom: 7.h, top: 4.h, left: 5.w, right: 5.w),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Find my Phone location",
                            style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.black),
                          ),
                        ),
                      ),
                      Center(
                          child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                  "This application required background location permission"
                                  "in order to run properly.\nThis application collects location "
                                  "data enable phone location even when app is not open.\n"
                                  "This location data is used to track your  phone. You will"
                                  "get location of your phone only if you allowed background location"
                                  "permission.",
                                  style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black)))),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Container(
                        width: 30.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue)),
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Center(
                            child: Text(
                              "Cancel",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: 30.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue)),
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            if (Platform.isAndroid) {
                              responseLocationPermission();
                            } else {
                              print('object');

                              LocationPermission permission =
                                  await Geolocator.checkPermission();
                              if (permission == LocationPermission.denied) {
                                permission =
                                    await Geolocator.requestPermission();
                                if (permission == LocationPermission.denied) {
                                  // Permissions are denied, handle appropriately.
                                  return;
                                }
                                print("Location Permission: $permission");
                                if (permission ==
                                    LocationPermission.deniedForever) {
                                  // Permissions are permanently denied, handle appropriately.
                                  return;
                                }

                                // If permissions are granted, proceed to access the location.
                              }
                              // if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
                              //   await Permission.location.request();
                              print('object');
                              // }
                            }
                            // await Permission.location.request();

                            // if (AppString.showAds % 2 == 0) {
                            //   // admobeSetting.showInterstitialAds(
                            //   //     1, context, prefs!);
                            // } else {
                            //   admobeSetting.navigateScreenRequired(
                            //       1, context, prefs!);
                            // }
                            // AppString.showAds++;
                            //
                          },
                          child: Center(
                            child: Text(
                              "Allow",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        });
  }

  Future<void> responseLocationPermission() async {
    try {
      await platformNative.invokeMethod("locationPermission");
    } on PlatformException catch (e) {
      debugPrint("Failed to Invoke: '${e.message}'.");
    }
    setState(() {
      // _responseFromNativeCode1=res;
    });
  }

  permissionLocation() async {
    var status = await Permission.location.status;
    var statusWhile = await Permission.locationWhenInUse.status;
    if (statusWhile.isGranted) {
      responseLocationPermission();
    }
    if (status.isGranted) {
      debugPrint("isGranted");
    } else if (status.isDenied) {
      debugPrint("isDenied");
      if (Platform.isAndroid) {
        permissionBottomSheetDialog();
      } else {
        permissionBottomSheetDialog();
      }
      // PhoneTrackLocationScreen().launch(context, isNewTask: true);

      // We didn't ask for permission yet or the permission has been denied before but not permanently.
    } else if (status.isPermanentlyDenied) {
      showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                title: const Text("Location Permission"),
                content: const Text(
                    "Time Optimizer App want to access your current location"),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                  ),
                  CupertinoDialogAction(
                    child: const Text("Setting"),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      openAppSettings();
                    },
                  )
                ],
              ));

      // print("isPermanentlyDenied");
    } else if (status.isRestricted) {
      // print("isRestricted");
    }
  }
}
