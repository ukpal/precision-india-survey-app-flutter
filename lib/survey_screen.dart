// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sur_app/job_list_screen.dart';
import 'package:sur_app/logout.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sur_app/utility/app_url.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({Key? key}) : super(key: key);

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final lat_controller = TextEditingController();
  final long_controller = TextEditingController();
  final from_date = TextEditingController();
  final to_date = TextEditingController();
  var formattedDate = '';
  var now = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');
  bool isLoading = false;

  _SurveyScreenState() {
    formattedDate = formatter.format(now);
    // to_date.text=formattedDate;
  }

  Future<Position> _getGeoLocationPosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // await Geolocator.openLocationSettings();
      // return Future.error('Location services are disabled.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Turn on your location")));
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("token") ?? '';
  }

  getJobs(from_date, to_date) async {
    String token = await getPref();
    final response = await http.post(
      Uri.parse(AppUrl.jobScheduleUrl),
      body: {
        "from": from_date.toString(),
        "to": to_date.toString(),
      },
      headers: {
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      var resposne = jsonDecode(response.body);
      if (resposne['errorCode'] == "Success") {
        var jobs = resposne['jobs'];
        isLoading = false;
        if (jobs.length == 0) {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'No Jobs Available',
                style: TextStyle(color: Colors.red),
              ),
              content: const Text('You don\'t have any open jobs within the dates'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => JobListScreen(jobs: jobs,lat: lat_controller.text, long: long_controller.text,)));
        }
      } else {
        print(" ${resposne['message']}");
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xffA60C2B),
        title: Text("Survey Screen"),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    isLoading = true;
                  });
                  logout(context);
                },
                child: Icon(
                  Icons.logout,
                  size: 26.0,
                ),
              )),
        ],
      ),
      body: (isLoading)
          ? Center(
              child: CircularProgressIndicator(
              color: Color(0xffA60C2B),
            ))
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Date of Survey: " + formattedDate.toString(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Text(
                          "Location: ",
                          style: TextStyle(
                              fontSize: 25,
                              color: Color.fromARGB(185, 0, 0, 0),
                              fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            child: Icon(
                              Icons.location_pin,
                              size: 40,
                              color: Color(0xffFF574D),
                            ),
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });
                              Position position =
                                  await _getGeoLocationPosition(context);
                              // print('Lat: ${position.latitude} , Long: ${position.longitude}');
                              print(position.latitude);
                              setState(() {
                                isLoading = false;
                                lat_controller.text =
                                    position.latitude.toStringAsFixed(3);
                                long_controller.text =
                                    position.longitude.toStringAsFixed(3);
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    // ignore: prefer_const_literals_to_create_immutables
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextField(
                        controller: lat_controller,
                        readOnly: true,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder(),
                            labelText: 'latitude'),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextField(
                        controller: long_controller,
                        readOnly: true,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder(),
                            labelText: 'longitude'),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Text(
                      "Select Date:",
                      style: TextStyle(
                          fontSize: 25,
                          color: Color.fromARGB(185, 0, 0, 0),
                          fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextField(
                        controller: from_date,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                            labelText: 'from'),
                        style: TextStyle(fontSize: 18),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(
                                  2000), //DateTime.now() - not to allow to choose before today.
                              lastDate: DateTime(2101));

                          if (pickedDate != null) {
                            print(
                                pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            print(
                                formattedDate); //formatted date output using intl package =>  2021-03-16
                            //you can implement different kind of Date Format here according to your requirement

                            setState(() {
                              from_date.text =
                                  formattedDate; //set output date to TextField value.
                            });
                          } else {
                            print("Date is not selected");
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextField(
                        controller: to_date,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                            labelText: 'to'),
                        style: TextStyle(fontSize: 18),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(
                                  2000), //DateTime.now() - not to allow to choose before today.
                              lastDate: DateTime(2101));

                          if (pickedDate != null) {
                            print(
                                pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            print(
                                formattedDate); //formatted date output using intl package =>  2021-03-16
                            //you can implement different kind of Date Format here according to your requirement

                            setState(() {
                              to_date.text =
                                  formattedDate; //set output date to TextField value.
                            });
                          } else {
                            print("Date is not selected");
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 55,
                      
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Color(0xffFF574D),
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                            });

                            getJobs(from_date.text, to_date.text);
                          },
                          child: Text(
                            "Submit",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
