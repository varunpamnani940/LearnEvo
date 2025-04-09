import 'dart:convert';
import 'package:dreamclass/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FeesHistoryScreen extends StatefulWidget {
  @override
  _FeesHistoryScreenState createState() => _FeesHistoryScreenState();
}

class _FeesHistoryScreenState extends State<FeesHistoryScreen> {
  List<Map<String, dynamic>> feesData = [];
  String studentName = "";
  String courseName = "";
  bool isLoading = true; // Added for loading indicator

  @override
  void initState() {
    super.initState();
    fetchStudentDetails();
    fetchFeesHistory();
  }

  Future<void> fetchStudentDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      studentName = prefs.getString('student_name') ?? 'Unknown';
      courseName = prefs.getString('course_name') ?? 'Unknown';
    });
  }

  Future<void> fetchFeesHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = "http://$ipAddress/flutter/get_fees_history.php";
    var response = await http.post(Uri.parse(apiUrl), body: {
      "id": prefs.getString("student_id")
    });

    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        feesData = List<Map<String, dynamic>>.from(json.decode(response.body));
        isLoading = false; // Data is loaded
      });
    } else {
      setState(() {
        isLoading = false; // Stop loading even if request fails
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fees Payment History",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentDetails(),
            SizedBox(height: 10),
            Expanded(child: _buildFeesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDetails() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Student: $studentName",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Course: $courseName",
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildFeesList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator()); // Show loader
    }

    return feesData.isEmpty
        ? Center(child: Text("No Payment History Available"))
        : ListView.builder(
      itemCount: feesData.length,
      itemBuilder: (context, index) {
        var fee = feesData[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: Icon(Icons.payment, color: Colors.blue[700]),
            title: Text("Amount: ₹${fee["amount"]}",
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Text(
                "Date: ${fee["date"]} | Method: ${fee["method"]}",
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            trailing: Text(
              "Fees ID: ${fee["feesid"]}",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        );
      },
    );
  }
}
