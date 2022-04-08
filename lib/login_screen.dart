// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, avoid_print, deprecated_member_use, avoid_unnecessary_containers

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sur_app/utility/app_url.dart';
// import 'package:sur_app/utility/app_url.dart';
import 'survey_screen.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final username_controller = TextEditingController();
  final password_controller = TextEditingController();
  bool isLoading = false;

  login(username, password) async {
    // print('email: ' + email + ' password: ' + password);
    final response = await http.post(
      Uri.parse(AppUrl.loginUrl),
      body: {
        "username": username.toString(),
        "password": password.toString(),
      },
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      var resposne = jsonDecode(response.body);
      if (resposne['errorCode'] == "Success") {
        Map<String, dynamic> user = resposne;
        savePref(user);
        isLoading = false;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SurveyScreen()));
      } else {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text(
              'Error',
              style: TextStyle(color: Colors.red),
            ),
            content: Text(resposne['message']),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        print(" ${resposne['message']}");
      }
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text(
            'Server Error',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text('Please try again later'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  savePref(user) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // preferences.setString("emp_name", user['emp_name']);
    preferences.setString("token", user['token']);
    // preferences.setInt("emp_id", user['emp_id']);
    // preferences.setInt("user_id", user['user_id']);
    preferences.setInt("login_id", user['login_id']);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: (isLoading)
              ? Center(
                  child: CircularProgressIndicator(
                    color: Color(0xffA60C2B),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Image(
                          image: AssetImage('assets/images/logo.png'),
                          height: 200,
                          width: 250,
                        ),
                      ),
                      Text(
                        "Sign Into Your Account",
                        style: TextStyle(
                            fontSize: 30,
                            color: Color.fromARGB(185, 0, 0, 0),
                            fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextField(
                          controller: username_controller,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'username',
                              suffixIcon: Icon(Icons.mail)),
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextField(
                          controller: password_controller,
                          obscureText: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'password',
                              suffixIcon: Icon(Icons.lock)),
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SizedBox(
                          height: 55,
                          width: MediaQuery.of(context).size.width,
                          child: RaisedButton(
                            textColor: Colors.white,
                            color: Color(0xffFF574D),
                            onPressed: () {
                              var username = username_controller.text;
                              var password = password_controller.text;
                              if (username != '' && password != '') {
                                login(username, password);
                                setState(() {
                                  isLoading = true;
                                });
                              }
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )),
    );
  }
}
