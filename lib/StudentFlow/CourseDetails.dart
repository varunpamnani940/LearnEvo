import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../login.dart';
import 'dashboard_Student.dart';

class Coursedetail extends StatefulWidget {
  @override
  State<Coursedetail> createState() => _CourseState();
}

class _CourseState extends State<Coursedetail> {
  List course = [];
  bool isLoading = true;

  Future<void> getdata() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String uri = "http://$ipAddress/flutter/studentflowapis/getcoursedata.php";
    var res = await http.post(Uri.parse(uri),
        body: {"studentid": sp.getString("studentid").toString()});
    setState(() {
      course = jsonDecode(res.body);
      isLoading = false;
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
      title: "Course Details",
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            // AppBar with top margin
            Container(
              padding: EdgeInsets.only(top: 10), // Top margin
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                bottom: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentDashboard(),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Course Details",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Course Details
            Expanded(
              child: isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
                  : Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView.builder(
                  itemCount: course.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: ExpansionTile(
                        tilePadding:
                        EdgeInsets.symmetric(horizontal: 16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[200],
                          child: Text(
                            course[index]["courseid"],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          course[index]["coursename"],
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                        children: [
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                buildInfoRow(Icons.date_range,
                                    "Joining Date", course[index]["joindate"]),
                                buildInfoRow(Icons.attach_money,
                                    "Course Fees", course[index]["coursefees"]),
                                // buildInfoRow(
                                //     Icons.money_off_csred_rounded,
                                //     "Pending Fees",
                                //     course[index]["coursefees"]),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700]),
          SizedBox(width: 12),
          Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              )),
          Text(
            value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          )
        ],
      ),
    );
  }
}
