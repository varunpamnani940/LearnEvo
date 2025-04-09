import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../login.dart';

class ResponsivePage extends StatefulWidget {
  @override
  _ResponsivePageState createState() => _ResponsivePageState();
}

class _ResponsivePageState extends State<ResponsivePage> {
  List<dynamic> courseData = [];
  String? selectedCourse;
 // Replace with actual IP address

  @override
  void initState() {
    super.initState();
    getCourse();
  }

  Future<void> getCourse() async {
    String uri = "http://$ipAddress/flutter/get_examp.php";
    var res = await http.post(Uri.parse(uri), body: {});
    setState(() {
      courseData = jsonDecode(res.body);
      if (courseData.isNotEmpty) {
        WidgetsBinding.instance!.addPostFrameCallback((_) => _showCourseDialog(context));

      }
    });
  }
  void _launchURL() async {
    String url = "https://docs.google.com/spreadsheets/d/1gIEdfbevqR8EQROdhxi23NFqZyXTiZuS4ItBwVFc41c/edit?gid=0#gid=0"; // Replace with your actual URL structure
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  void _showCourseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Exam"),
          content: DropdownButtonFormField<String>(
            value: selectedCourse,
            items: courseData.map<DropdownMenuItem<String>>((course) {
              return DropdownMenuItem<String>(
                value: course["id"],
                child: Text(course["exam_name"]),
              );
            }).toList(),
            onChanged: (value) {
              setState(() async{
                selectedCourse = value;
                 get_data(value!);

              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            ),
          ),
        );
      },
    );
  }
  Future<void> get_data(String exam_id)async {
   String url = "http://51.20.10.147/flutter/get_result_data.php";
   var res = await http.post(Uri.parse(url),body: {
     "exam_id":exam_id,
   });
   _launchURL();
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Scaffold(
            body: Center(
              child: AlertDialog(
                title: Text("Notice"),
                content: Text("Kindly open this in the web interface for better experience."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: Text("Web Interface")),
            body: Center(
              child: Text("Select a course from the popup dialog."),
            ),
          );
        }
      },
    );
  }
}
