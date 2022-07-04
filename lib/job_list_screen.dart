// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables, avoid_print, must_be_immutable, prefer_const_constructors_in_immutables

// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sur_app/details_screen.dart';
import 'package:sur_app/logout.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sur_app/utility/app_url.dart';

class JobListScreen extends StatefulWidget {
  final List jobs;
  JobListScreen({Key? key, required this.jobs}) : super(key: key);
  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  bool isLoading = false;
  var j = [];
  var lat='';
  var long='';

  @override
  void initState() {
    super.initState();
    j = widget.jobs;
    // print(widget.lat);
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("token") ?? '';
  }

  getJobDetails(jobId) async {
    String token = await getPref();
    final response = await http.post(
      Uri.parse(AppUrl.jobDetailsUrl),
      body: {
        "job_id": jobId.toString(),
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
        // var details = resposne['details'];
        isLoading = false;
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DetailsScreen(data: resposne)));
      } else {
        print(" ${resposne['message']}");
      }
    } else {}
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: Color(0xffA60C2B),
        title: Text("Job List"),
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
                child: Center(child: Text("LOGOUT")),
              )),
        ],
      ),
      body: (isLoading)
          ? Center(
              child: CircularProgressIndicator(
              color: Color(0xffA60C2B),
            ))
          : ListView.builder(
              itemCount: j.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding:
                      const EdgeInsets.only(top: 15.0, left: 10, right: 10),
                  child: GestureDetector(
                    child: Container(
                      // height: 100,
                      decoration: BoxDecoration(
                          color: Color(0xffFF574D),
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              j[index]['Client_name'].toString(),
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                j[index]['Client_contactNo'].toString(),
                                style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(186, 255, 255, 255)),
                              ),
                            ),
                            Text(
                              j[index]['location']['locality'].toString(),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      // print(j[index]['id']);
                      setState(() {
                        isLoading = true;
                      });
                      getJobDetails(j[index]['id']);
                    },
                  ),
                );
              }),
    );
  }
}


