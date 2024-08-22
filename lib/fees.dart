import 'dart:convert';
import 'package:dreamclass/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'feesstudent.dart';

class Fees extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FeesState();
  }
}

class FeesState extends State<Fees> {
  List data = [];
  List<Map<String, dynamic>> courseTotalsList = [];
  Map<String, Map<String, int>> courseTotals = {};

  Future<void> getData() async {
    String uri = "http://$ipAddress/flutter/getcoursefeesdata.php"; // Replace with your actual IP address or server
    try {
      var res = await http.post(Uri.parse(uri));
      if (res.statusCode == 200) {
        setState(() {
          data = jsonDecode(res.body);

          // Clear the list and map before recalculating
          courseTotalsList.clear();
          courseTotals.clear();

          for (var student in data) {
            String courseName = student['coursename'];

            // Ensure conversion from String to int for discount, receivable fees, and received fees
            int discount = int.tryParse(student['dicount']) ?? 0;
            int receivableFees = int.tryParse(student['receiablefees']) ?? 0;
            int receivedFees = int.tryParse(student['receivedfees']) ?? 0; // Correct key 'receivedfees'

            // If the course is already in the map, update the totals
            if (courseTotals.containsKey(courseName)) {
              courseTotals[courseName]!['totalDiscount'] =
                  courseTotals[courseName]!['totalDiscount']! + discount;
              courseTotals[courseName]!['totalReceivableFees'] =
                  courseTotals[courseName]!['totalReceivableFees']! + receivableFees;
              courseTotals[courseName]!['totalReceivedFees'] =
                  courseTotals[courseName]!['totalReceivedFees']! + receivedFees;
            } else {
              // Otherwise, initialize the course totals
              courseTotals[courseName] = {
                'totalDiscount': discount,
                'totalReceivableFees': receivableFees,
                'totalReceivedFees': receivedFees,
              };
            }
          }

          // Convert the courseTotals map into a dynamic list of maps
          courseTotals.forEach((course, totals) {
            courseTotalsList.add({
              'courseName': course,
              'totalDiscount': totals['totalDiscount'],
              'totalReceivableFees': totals['totalReceivableFees'],
              'totalReceivedFees': totals['totalReceivedFees'],
            });
          });

          print(courseTotalsList);
        });
      } else {
        print("Failed to load data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Course Fees",
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              height: 400,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(color: Colors.blue[700]),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              height: 700,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(120),
                  topLeft: Radius.circular(120),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(40),
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: courseTotalsList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {
                              print(courseTotalsList[index]["courseName"]);
                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>feesstud(courseTotalsList[index]["courseName"])));
                            },
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  courseTotalsList[index]["courseName"],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Text("Total Discount: "),
                                    Text(courseTotalsList[index]["totalDiscount"].toString()),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Total Receivable Fees: "),
                                    Text(courseTotalsList[index]["totalReceivableFees"].toString()),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Total Received Fees: "),
                                    Text(courseTotalsList[index]["totalReceivedFees"].toString()),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
