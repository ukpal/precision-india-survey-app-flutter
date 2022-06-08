// ignore_for_file: prefer_const_constructors, avoid_print, body_might_complete_normally_nullable, prefer_typing_uninitialized_variables, must_be_immutable, non_constant_identifier_names, prefer_const_constructors_in_immutables

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sur_app/logout.dart';
import 'package:sur_app/survey_screen.dart';
import 'package:sur_app/utility/app_url.dart';
import 'package:geolocator/geolocator.dart';
// import 'login_screen.dart';

class DetailsScreen extends StatefulWidget {
  final Map data;

  DetailsScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final lat_controller = TextEditingController();
  final long_controller = TextEditingController();
  bool isLoading = false;
  Map details = {};
  List machines = [];
  final amount = TextEditingController();
  final remarks = TextEditingController();
  String? machineId;
  var jobCompleteStatus = 1;

  @override
  void initState() {
    super.initState();
    details = widget.data['details'];
    machines = widget.data['machines'];
    machineId = (details['machine_id'] == null)
        ? '3'
        : details['machine_id'].toString();
    // machineId = details['machine_id'].toString();
    lat_controller.text = details['latitude'] ?? '';
    long_controller.text = details['longitude'] ?? '';
    amount.text=0.toString();
    // print(widget.data['machines']);
    // print(widget.lat);
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Turn on your location")));
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

  updateJobDetails(jobId, machineId, amount) async {
    String token = await getPref();
    final response = await http.post(
      Uri.parse(AppUrl.updateJobDetailsUrl),
      body: {
        "id": jobId.toString(),
        "machine_id": machineId.toString(),
        "amount": amount.toString(),
        "latitude": lat_controller.text.toString(),
        "longitude": long_controller.text.toString(),
        "job_complete_status": jobCompleteStatus.toString(),
        "remarks": remarks.text.toString()
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
        showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => WillPopScope(
            onWillPop: () => Future.value(false),
            child: AlertDialog(
              title: const Text('Congratulation'),
              content: const Text('Survey Details updated'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SurveyScreen())),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: Color(0xffA60C2B),
        title: Text("Job Details"),
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
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
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
                                    position.latitude.toStringAsFixed(5);
                                long_controller.text =
                                    position.longitude.toStringAsFixed(5);
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
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
                      padding: const EdgeInsets.only(top: 10.0),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: DropdownButtonFormField2(
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        isExpanded: true,
                        value: machineId.toString(),
                        hint: const Text(
                          'Select Machine',
                          style: TextStyle(fontSize: 18),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black45,
                        ),
                        iconSize: 30,
                        buttonHeight: 50,
                        buttonPadding:
                            const EdgeInsets.only(left: 10, right: 10),
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        items: machines
                            .map((item) => DropdownMenuItem<String>(
                                  value: item['id'].toString(),
                                  child: Text(
                                    item['name'].toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          machineId = value.toString();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder(),
                            labelText: 'Client',
                            hintText: details['Client_name'],
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder(),
                            labelText: 'Client Phone',
                            hintText: details['Client_contactNo'],
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder(),
                            labelText: 'Client Email',
                            hintText: details['client_email'],
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder(),
                            labelText: 'State',
                            hintText: (details['location']['state'] == null)
                                ? ''
                                : details['location']['state']['states_name'],
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder(),
                            labelText: 'District',
                            hintText: (details['location']['district'] == null)
                                ? ''
                                : details['location']['district']
                                    ['district_name'],
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder(),
                            labelText: 'City',
                            hintText: (details['location']['city'] == null)
                                ? ''
                                : details['location']['city']['city_name'],
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder(),
                            labelText: 'Locality',
                            hintText: details['location']['locality'],
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder(),
                            labelText: 'Surveyor',
                            hintText: details['surveyor_name'],
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder(),
                            labelText: 'Helper 1',
                            hintText: details['helper_name1'],
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder(),
                            labelText: 'Helper 2',
                            hintText: details['helper_name2'],
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder(),
                            labelText: 'Driver',
                            hintText: details['driver_name'],
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: TextField(
                        controller: amount,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          border: OutlineInputBorder(),
                          labelText: 'Amount Received',
                          hintText: 'amount received',
                          // floatingLabelBehavior: FloatingLabelBehavior.always
                        ),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: TextField(
                        maxLines: 3,
                        controller: remarks,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          border: OutlineInputBorder(),
                          // labelText: 'Remarks',
                          hintText: 'enter your remarks here',
                          // floatingLabelBehavior: FloatingLabelBehavior.always
                        ),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Job Status:",
                          style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(185, 0, 0, 0),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        children: [
                          Radio(
                            value: 1,
                            groupValue: jobCompleteStatus,
                            onChanged: (value) {
                              setState(() {
                                jobCompleteStatus = value as int;
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                          Text(
                            'Running',
                            style: TextStyle(fontSize: 18),
                          ),
                          Radio(
                            value: 0,
                            groupValue: jobCompleteStatus,
                            onChanged: (value) {
                              setState(() {
                                jobCompleteStatus = value as int;
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                          Text('Complete', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: SizedBox(
                        height: 58,
                        width: MediaQuery.of(context).size.width,
                        // ignore: deprecated_member_use
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Color(0xffFF574D),
                          onPressed: () {
                            print(amount.toString());
                            if (machineId != '3') {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: (jobCompleteStatus == 1)
                                      ? Text('selected job status: Running')
                                      : Text('selected job status: Complete'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () =>
                                          Navigator.pop(context, 'OK'),
                                    ),
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        setState(() {
                                          Navigator.pop(context);
                                          isLoading = true;
                                        });
                                        updateJobDetails(details['id'],
                                              machineId, amount.text);
                                        // if (amount.text == '') {
                                        //   updateJobDetails(
                                        //       details['id'], machineId, 0);
                                        // } else {
                                        //   updateJobDetails(details['id'],
                                        //       machineId, amount.text);
                                        // }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text(
                                    'Error',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  content: Text('Select A Machine'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'OK'),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Text(
                            "Submit",
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
