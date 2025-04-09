import 'dart:async';
import 'dart:convert';
import 'package:dreamclass/admin/teacher.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../login.dart';
import 'AddCourse.dart';
import 'addstudent.dart';
import 'addsubject.dart';
import 'profile.dart';
import 'resultUpload.dart';
import 'att.dart';
import 'DeviceManager.dart';
import 'transfer.dart';
import 'permision.dart';
import 'addExam.dart';
import 'fees.dart';
import 'inquiry.dart';
import 'removestudent.dart';
import 'addnotes.dart';
import 'add_faculty.dart';
import 'stats.dart';
import 'Availablestudent.dart';
import '../main.dart';

class AdminDashboardWeb extends StatefulWidget {
  @override
  _AdminDashboardWebState createState() => _AdminDashboardWebState();
}

class _AdminDashboardWebState extends State<AdminDashboardWeb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text("LearnEvo Central (Web)", style: TextStyle(color: Colors.white)),
        elevation: 4,
      ),
      body: Row(
        children: [
          Expanded(flex: 1, child: _buildSidebar()),
          Expanded(flex: 4, child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: Colors.blue[700],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: 24),
          _buildDrawerItem(Icons.account_circle, "Profile", ProfilePage()),
          _buildDrawerItem(Icons.help_center, "Inquiry", Inquiry()),
          _buildDrawerItem(Icons.school, "Add Student", AddStudent()),
          _buildDrawerItem(Icons.book, "Add Course", AddCourse()),
          _buildDrawerItem(Icons.delete, "Remove Student", Removestudent()),
          _buildDrawerItem(Icons.subject, "Add Subject", AddSubject()),
          _buildDrawerItem(Icons.assignment, "Results", ResponsivePage()),
          _buildDrawerItem(Icons.access_time, "Attendance", att()),
          _buildDrawerItem(Icons.people, "Available Student", Availablestudent()),
          _buildDrawerItem(Icons.devices, "Device Management", DeviceManager()),
          _buildDrawerItem(Icons.sync, "Student Transfer", Transfer()),
          _buildDrawerItem(Icons.security, "Teacher List", TeacherListPage()),
          _buildDrawerItem(Icons.event, "Add Exam", AddExam()),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.white),
            title: Text("Logout", style: TextStyle(color: Colors.white)),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove("teacher");
              prefs.remove("studentid");
              prefs.remove("email");
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: LiveAttendanceWidget(),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
    );
  }
}
class LiveAttendanceWidget extends StatefulWidget {
  @override
  _LiveAttendanceWidgetState createState() => _LiveAttendanceWidgetState();
}

class _LiveAttendanceWidgetState extends State<LiveAttendanceWidget> {
  List<Map<String, dynamic>> attendanceData = [];
  Timer? _timer;
  bool isLoading = false;
  String? errorMessage;
  bool showTodayOnly = true;

  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    String url = "http://51.20.10.147/flutter/get_att.php";

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          attendanceData = jsonData.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load data: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching data: $e";
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  TextStyle _headerStyle() => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.blue.shade900,
  );

  TextStyle _cellStyle() => TextStyle(
    fontSize: 16,
    color: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final filteredData = showTodayOnly
        ? attendanceData.where((entry) {
      final fullDate = entry['date'] ?? '';
      final datePart = fullDate.split(" ").first;
      return datePart == todayDate;
    }).toList()
        : attendanceData;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Live Attendance Records",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                Row(
                  children: [
                    Text("Today Only", style: TextStyle(fontSize: 16)),
                    Switch(
                      value: showTodayOnly,
                      onChanged: (val) {
                        setState(() {
                          showTodayOnly = val;
                        });
                      },
                    ),
                    isLoading
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                        : IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.blue.shade700,
                        size: 28,
                      ),
                      onPressed: fetchData,
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20),

            /// Error or Empty State
            if (errorMessage != null)
              Center(
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (filteredData.isEmpty)
              Center(
                child: Text(
                  "No records found",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              )

            /// Data Table
            else
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints:
                        BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          headingRowColor:
                          MaterialStateProperty.all(Colors.blue.shade100),
                          dataRowColor:
                          MaterialStateProperty.all(Colors.white),
                          columnSpacing: 32,
                          horizontalMargin: 24,
                          columns: [
                            DataColumn(
                                label: Expanded(
                                    child: Text("Student ID",
                                        style: _headerStyle()))),
                            DataColumn(
                                label: Expanded(
                                    child: Text("Student Name",
                                        style: _headerStyle()))),
                            DataColumn(
                                label: Expanded(
                                    child: Text("Course",
                                        style: _headerStyle()))),
                            DataColumn(
                                label: Expanded(
                                    child: Text("Date", style: _headerStyle()))),
                            DataColumn(
                                label: Expanded(
                                    child:
                                    Text("Time", style: _headerStyle()))),
                          ],
                          rows: filteredData.map((entry) {
                            String fullDateTime = entry['date'] ?? "";
                            List<String> split = fullDateTime.split(" ");
                            String datePart =
                            split.isNotEmpty ? split[0] : "N/A";
                            String timePart =
                            split.length > 1 ? split[1] : "N/A";

                            return DataRow(cells: [
                              DataCell(Text(entry['student_id'] ?? "N/A",
                                  style: _cellStyle())),
                              DataCell(Text(entry['studentname'] ?? "N/A",
                                  style: _cellStyle())),
                              DataCell(Text(entry['coursename'] ?? "N/A",
                                  style: _cellStyle())),
                              DataCell(Text(datePart, style: _cellStyle())),
                              DataCell(Text(timePart, style: _cellStyle())),
                            ]);
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}