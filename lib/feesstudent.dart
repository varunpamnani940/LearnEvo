import 'dart:convert';
import 'package:dreamclass/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class feesstud extends StatefulWidget {
  String? CourseName ;
  @override
  State<StatefulWidget> createState() {
    return feesstudstate(CourseName);
  }

  feesstud(this.CourseName);
}
List student = [];
class feesstudstate extends State<feesstud> {
  String? Coursename;
  feesstudstate(this.Coursename);
  Future<void> getdata() async{
    String uri = "http://$ipAddress/flutter/getcoursefeesdata.php";
    var res = await http.post(Uri.parse(uri),body: {
      "coursename":Coursename
    });
    setState(() {
      print(res.body);
      student = jsonDecode(res.body);
    });
  }

  @override
  void initState() {
    super.initState();
    getdata();
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
                      itemCount: student.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {
                              print(student[index]["studentname"]);
                            },
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student[index]["studentname"],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Text("Discount: "),
                                    Text(student[index]["dicount"].toString()),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(" Recieable Fees: "),
                                    Text(student[index]["receiablefees"]),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Total Received Fees: "),
                                    Text(student[index]["receivedfees"]),
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
