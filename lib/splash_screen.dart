// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sur_app/login_screen.dart';

import 'survey_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _loginId = 0;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _loginId = preferences.getInt("login_id") ?? 0;
    });
    if (_loginId == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SurveyScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      getPref();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Image(
              image: AssetImage('assets/images/logo.png'),
              height: 200,
              width: 250,
            ),
            CircularProgressIndicator(
              color: Color(0xffA60C2B),
            ),
          ],
        )),
      ),
    );
  }
}
