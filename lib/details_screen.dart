// ignore_for_file: prefer_const_constructors, avoid_print, body_might_complete_normally_nullable, prefer_typing_uninitialized_variables, must_be_immutable

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sur_app/logout.dart';
import 'package:sur_app/survey_screen.dart';
import 'package:sur_app/utility/app_url.dart';
// import 'login_screen.dart';

class DetailsScreen extends StatefulWidget {
  final Map data;
  var lat;
  var long;
  DetailsScreen({Key? key, required this.data, this.lat, this.long})
      : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool isLoading = false;
  Map details = {};
  List machines = [];
  final amount = TextEditingController();
  var machineId;

  @override
  void initState() {
    super.initState();
    details = widget.data['details'];
    machines = widget.data['machines'];
    // print(widget.data['details']);
    // print(widget.lat);
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
        "latitude": widget.lat.toString(),
        "longitude": widget.long.toString()
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
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: DropdownButtonFormField2(
                        decoration: InputDecoration(
                          //Add isDense true and zero Padding.
                          //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          //Add more decoration as you want here
                          //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                        ),
                        isExpanded: true,
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
                          machineId = value;
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
                        readOnly: true,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder(),
                            labelText: 'Estimation',
                            hintText: details['Estimation'],
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
                            labelText: 'Paid',
                            hintText: details['paidAmount'],
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
                            labelText: 'Balance',
                            hintText: details['Balance'],
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
                      padding: const EdgeInsets.only(top: 15.0),
                      child: SizedBox(
                        height: 58,
                        width: MediaQuery.of(context).size.width,
                        // ignore: deprecated_member_use
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Color(0xffFF574D),
                          onPressed: () {
                            // print(machineId);
                            if (machineId != null) {
                              if (amount.text == '') {
                                updateJobDetails(details['id'], machineId, 0);
                              } else {
                                updateJobDetails(
                                    details['id'], machineId, amount.text);
                              }
                              setState(() {
                                isLoading = true;
                              });
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
