// ignore_for_file: prefer_const_constructors

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

logout(context) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.clear();
  Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
}
