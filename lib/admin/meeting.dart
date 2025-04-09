import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({Key? key}) : super(key: key);

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  List meetings = [];

  @override
  void initState() {
    super.initState();
    fetchMeetings();
  }

  Future<void> fetchMeetings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('emailt');

    final response = await http.post(
      Uri.parse('http://$ipAddress/flutter/View_meeting_t.php'),
      body: {"email": email},
    );
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        meetings = jsonDecode(response.body);
      });
    }
  }

  Future<void> updateFollowUp(int meetingId, int newFollowUp) async {
    final res = await http.post(
      Uri.parse('http://$ipAddress/flutter/edit_meeting.php'),
      body: {
        "id": meetingId.toString(),
        "follow_up": newFollowUp.toString(),
      },
    );

    if (res.statusCode == 200 && res.body.trim() == "success") {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Follow-up updated")));
      fetchMeetings();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Update failed")));
    }
  }

  Widget followUpChip(int status) {
    return Chip(
      label: Text(
        status == 1 ? "Completed" : "Pending",
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: status == 1 ? Colors.green : Colors.orange,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meeting Follow-Ups"),
        centerTitle: true,
      ),
      body: meetings.isEmpty
          ? const Center(child: Text("No meetings found"))
          : ListView.builder(
        itemCount: meetings.length,
        itemBuilder: (context, index) {
          final meeting = meetings[index];
          int meetingId = int.parse(meeting['id']);
          int followUp = int.parse(meeting['follow_up']);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Date: ${meeting['date']}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Student Name: ${meeting['studentname']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text("Status: "),
                          followUpChip(followUp),
                        ],
                      ),
                      DropdownButton<int>(
                        value: followUp,
                        borderRadius: BorderRadius.circular(10),
                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text("Pending")),
                          DropdownMenuItem(value: 1, child: Text("Completed")),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            updateFollowUp(meetingId, value);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
