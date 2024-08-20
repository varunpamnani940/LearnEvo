import 'dart:convert';
import 'package:dreamclass/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Fees extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FeesState();
  }
}

class FeesState extends State<Fees> {
  List data = [];

  Future<void> getData() async {
    String uri = "http://$ipAddress/flutter/getcoursefeesdata.php"; // Use your actual IP address or local server
    try {
      var res = await http.post(Uri.parse(uri));
      if (res.statusCode == 200) {
        setState(() {
          data = jsonDecode(res.body);
        });
      } else {
        // Handle the error if the response isn't successful
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
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(120),
                  topLeft: Radius.circular(120),
                ),
              ),
              child: Column(
                children: [
                  // Add a top section if needed, such as a header or title
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(40),
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Card(

                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(data[index]["courseid"]),
                            ),
                            title: Text(data[index]["coursename"]),
                          )
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
