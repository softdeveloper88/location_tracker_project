import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_project/phone_track_location_screen.dart';
import 'package:test_project/terms_and_condition_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SplashScreens extends StatefulWidget {
  const SplashScreens({Key? key}) : super(key: key);

  @override
  _SplashScreensState createState() => _SplashScreensState();
}

class _SplashScreensState extends State<SplashScreens> {
  SharedPreferences? prefs;
  bool termsAccepted = false;

  Future<void> sharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    termsAccepted = prefs!.getBool("acceptTerms") ?? false;
  }

  @override
  void initState() {
    sharedPreferences();

    Future.delayed(const Duration(seconds: 4), () {
      String barcode = prefs!.getString("barcode") ?? '';

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) =>
      //       termsAccepted
      //           ? MainScreen()
      //           : TermsAndConditionScreen(),
      //     ));
      // if (!termsAccepted && !prefs!.containsKey("email")) {
      //   showTermsDialog();
      //   pageRoutPushReplacement(context,
      //       const LoginScreen()); // here will be replace intro screen later
      // } else if (termsAccepted && !prefs!.containsKey("email")) {
      //   pageRoutPushReplacement(context, const LoginScreen());
      // } else if (termsAccepted && prefs!.containsKey("email")) {
      //   pageRoutPushReplacement(context, const DashboardScreen());
      // }else{
      //   pageRoutPushReplacement(context, const LoginScreen());
      //
      // }
      if (termsAccepted && barcode !='') {
        Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>

                      PhoneTrackLocationScreen(),
                ));
        // PhoneTrackLocationScreen().launch(context,isNewTask: true);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const PhoneTrackLocationScreen()),
        // );
      } else {
        // TermsAndConditionScreen().launch(context,isNewTask: true);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>

                  TermsAndConditionScreen(),
            ));
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => TermsAndConditionScreen()),
        // );
      } });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                 'assets/images/app_logo.png',
                  height: 40.w,
                  width: 50.w,
                ),
              ),
              Text("Time Optimizer",
                  style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.blue,
                      fontWeight: FontWeight.w900)),
              // Text("Find your location ",
              //     style: GoogleFonts.poppins(
              //         fontSize: 8.sp,
              //         color: Colors.black,
              //         fontWeight: FontWeight.w500)),
            ],
          )),
    );
  }
}


