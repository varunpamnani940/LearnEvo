import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart'; // Assuming you get ipAddress from here

class TeacherMeetingScreen extends StatefulWidget {
  @override
  _TeacherMeetingScreenState createState() => _TeacherMeetingScreenState();
}

class _TeacherMeetingScreenState extends State<TeacherMeetingScreen> {
  List<Map<String, dynamic>> teachers = [];
  List<Map<String, dynamic>> pastMeetings = [];

  String? selectedTeacher;
  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    fetchTeachers();
    fetchPreviousMeetings();
  }
  Future<void> fetchPreviousMeetings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? studentId = prefs.getString("studentid");

    if (studentId == null) return;

    final response = await http.post(
      Uri.parse('http://$ipAddress/flutter/view_meeting.php'),
      body: {
        "student_id": studentId,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> meetings = jsonDecode(response.body);

      setState(() {
        pastMeetings = meetings.map<Map<String, dynamic>>((meeting) {
          DateTime dateTime = DateTime.parse(meeting['date']);
          return {
            'teacher': meeting['td_name'],
            'subject': meeting['td_email'],
            'date': dateTime,
            'status': meeting['follow_up'] == '1' ? 'Completed' : 'Pending',
          };
        }).toList();
      });
    }
  }


  Future<void> fetchTeachers() async {
    final response = await http.get(Uri.parse('http://$ipAddress/flutter/get_teachers.php'));
    if (response.statusCode == 200) {
      List<dynamic> teacherList = jsonDecode(response.body);
      setState(() {
        teachers = List<Map<String, dynamic>>.from(teacherList);
      });
    }
  }

  Future<void> _pickDateTime() async {
    DateTime currentDateTime = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDateTime,
      firstDate: currentDateTime,
      lastDate: currentDateTime.add(Duration(days: 30)),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: currentDateTime.hour, minute: currentDateTime.minute),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitMeetingRequest() async {
    if (selectedTeacher != null && selectedDateTime != null) {
      final selected = teachers.firstWhere((t) => t['td_name'] == selectedTeacher);
      String teacherId = selected['td_id'];
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateTime!);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? studentId = prefs.getString("studentid")?.trim();

      if (studentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Student ID not found.")),
        );
        return;
      }

      final response = await http.post(
        Uri.parse("http://$ipAddress/flutter/insert_meeting.php"),
        body: {
          "teacherid": teacherId,
          "date": formattedDate,
          "student_id": studentId,
        },
      );
      print(response.body);

      final json = jsonDecode(response.body);

      if (json['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meeting request sent successfully!')),
        );
        setState(() {
          selectedTeacher = null;
          selectedDateTime = null;
          fetchPreviousMeetings();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: ${json['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a teacher and a valid meeting time')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Meeting with Teacher',style: TextStyle( color: Colors.white),),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set a Meeting with Your Teacher',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),

                    DropdownButton<String>(
                      value: selectedTeacher,
                      hint: Text('Select Teacher'),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTeacher = newValue;
                        });
                      },
                      items: teachers.map((teacher) {
                        return DropdownMenuItem<String>(
                          value: teacher['td_name'],
                          child: Text('${teacher['td_name']} (${teacher['td_email']})'),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _pickDateTime,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        selectedDateTime == null
                            ? 'Select Meeting Time'
                            : 'Selected Time: ${DateFormat('yMMMd').format(selectedDateTime!)} at ${DateFormat('jm').format(selectedDateTime!)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    SizedBox(height: 20),

                    Center(
                      child: ElevatedButton(
                        onPressed: _submitMeetingRequest,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Submit Request',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            Text(
              'Previous Meetings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: pastMeetings.length,
              itemBuilder: (context, index) {
                final meeting = pastMeetings[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${meeting['teacher']} (${meeting['subject']})',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Date: ${DateFormat('yMMMd').format(meeting['date'])} at ${DateFormat('jm').format(meeting['date'])}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: meeting['status'] == 'Completed' ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            meeting['status'],
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )

          ],
        ),
      ),
    );
  }
}
