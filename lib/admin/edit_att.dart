import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../login.dart';

class EditAttendance extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditAttendanceState();
}

class _EditAttendanceState extends State<EditAttendance> {
  String? courseId;
  String? date;

  List student = [];
  List<String> absentIds = [];

  String? encodedAbsentIds;
  String? encodedStudentIds;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCourseDateDialog();
    });
  }

  Future<void> _showCourseDateDialog() async {
    TextEditingController dateController = TextEditingController();
    DateTime? selectedDate;
    List<Map<String, dynamic>> courseList = [];
    String? selectedCourseId;

    var res = await http.get(Uri.parse("http://$ipAddress/flutter/viewcourse.php"));
    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      courseList = data.map<Map<String, dynamic>>((item) => {
        'id': item['courseid'],
        'name': item['coursename'],
      }).toList();

      if (courseList.isNotEmpty) {
        selectedCourseId = courseList[0]['id'];
      }
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Course and Date"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Select Course"),
                value: selectedCourseId,
                onChanged: (value) {
                  selectedCourseId = value;
                },
                items: courseList.map((course) {
                  return DropdownMenuItem<String>(
                    value: course['id'],
                    child: Text(course['name']),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                    dateController.text =
                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                  }
                },
                child: Text("Pick Date"),
              ),
              if (selectedDate != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text("Selected Date: ${dateController.text}"),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedCourseId != null && selectedDate != null) {
                  setState(() {
                    courseId = selectedCourseId!;
                    date = "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
                    isLoading = true;
                  });

                  fetchStudentData();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select both course and date.")),
                  );
                }
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }
var hasAttendanceData;
  Future<void> fetchStudentData() async {
    final uri = "http://$ipAddress/flutter/edit_attendence.php";
    var res = await http.post(Uri.parse(uri), body: {
      "courseid": courseId,
      "date": date
    });

    print(date);
    print(res.body);

    var response = jsonDecode(res.body);

    setState(() {
      try{
        student = response["students"] ?? [];
        List<dynamic> attendance = response["attendance"];
        List<int> presentList = [];

        if (attendance.isNotEmpty && attendance[0] is List && attendance[0].isNotEmpty) {
          hasAttendanceData = true;
          presentList = List<int>.from(attendance[0][0]["present"]);
        }else {
          hasAttendanceData = false;
        }

        List<int> allStudentIds = student.map((e) => int.parse(e["studentid"])).toList();
        List<int> absent = allStudentIds.where((id) => !presentList.contains(id)).toList();

        absentIds = absent.map((e) => e.toString()).toList();
        isLoading = false;
      }
      catch(e){
      setState(() {
        isLoading = false;
      });
      }
      finally{
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void _onSelected(bool selected, String id) {
    setState(() {
      if (!selected) {
        absentIds.add(id);
      } else {
        absentIds.remove(id);
      }

      List<int> studentIds = student.map((s) => int.parse(s["studentid"])).toList();
      List<int> absentIntIds = absentIds.map(int.parse).toList();
      List<int> presentIds = studentIds.where((id) => !absentIntIds.contains(id)).toList();

      print("Present: $presentIds");
      print("Absent: $absentIntIds");

      final attendanceObject = [
        {
          "present": presentIds,
          "absent": absentIntIds,
        }
      ];
      print(attendanceObject);
      final jsonString = jsonEncode(attendanceObject);
      encodedStudentIds = base64Url.encode(utf8.encode(jsonString)); // only this needed now
    });
  }

  Future<void> updateAttendance() async {
    final uri = "http://$ipAddress/flutter/update_attendance.php";
    var res = await http.post(Uri.parse(uri), body: {
      "attendancedata": encodedStudentIds, // changed key name for clarity
      "date": date,
      "courseid": courseId
    });

    print(res.body);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Attendance updated successfully!"))
    );
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Edit Attendance",
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            backgroundColor: Colors.blue[700],
            leading: Material(
              color: Colors.blue[700],
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_circle_left_rounded,
                    color: Colors.white, size: 40),
              ),
            ),
            title: Row(
              children: [
                Text("Edit Attendance", style: TextStyle(color: Colors.white)),
                Material(
                  color: Colors.blue[700],
                  child: InkWell(
                    onTap: updateAttendance,
                    child: Padding(
                      padding: EdgeInsets.only(left: 90),
                      child: Icon(Icons.update, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            Container(
              height: 200,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(color: Colors.blue[700]),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              height: 900,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(120),
                  topLeft: Radius.circular(120),
                ),
              ),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : student.isEmpty
                  ? Center(child: Text("No students found for selected course."))
                  : !hasAttendanceData
                  ? Center(child: Text("No attendance record found for selected date."))
                  :Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: ListView.separated(
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: student.length,
                  itemBuilder: (context, i) {
                    String studentId = student[i]["studentid"];
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 100.0),
                            child: Text(student[i]["studentname"]),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                alignment: Alignment.topRight,
                                child: Checkbox(
                                  value: !absentIds.contains(studentId),
                                  onChanged: (val) {
                                    _onSelected(val!, studentId);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[300],
                        child: Text(studentId),
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
}
