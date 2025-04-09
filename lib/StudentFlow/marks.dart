import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MarksPage extends StatefulWidget {
  @override
  _MarksPageState createState() => _MarksPageState();
}

class _MarksPageState extends State<MarksPage> {
  String? selectedExamId;
  List<Map<String, dynamic>> exams = [];
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> subjectMarks = [];
  String? selectedCourseId;
  bool isLoading = true;

  String ipAddress = "51.20.10.147"; // Replace with your actual IP

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final sp = await SharedPreferences.getInstance();
    String uri = "http://$ipAddress/flutter/studentflowapis/getcoursedata.php";
    final res = await http.post(Uri.parse(uri), body: {
      "studentid": sp.getString("studentid").toString(),
    });

    if (res.statusCode == 200) {
      final List decoded = jsonDecode(res.body);
      setState(() {
        courses = decoded.cast<Map<String, dynamic>>();
        isLoading = false;
      });
      _showCourseDialog(); // Show dialog on load
    }
  }

  Future<void> _fetchExams(String courseId) async {
    String uri = "http://$ipAddress/flutter/get_examp.php";
    final res = await http.post(Uri.parse(uri), body: {
      "courseid": courseId,
    });

    if (res.statusCode == 200) {
      final List decoded = jsonDecode(res.body);
      setState(() {
        exams = decoded.map<Map<String, dynamic>>((e) {
          return {
            "examId": e["id"],
            "examName": e["exam_name"],
            "subjectList": e["subject_list"],
            "overallTotal": int.parse(e["overall_total_marks"] ?? "0")
          };
        }).toList();
      });
    }
  }

  void _showCourseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Course"),
        content: courses.isEmpty
            ? Text("No courses found")
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: courses.map((course) {
            return ListTile(
              title: Text(course["coursename"]),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  selectedCourseId = course["courseid"];
                  selectedExamId = null;
                  subjectMarks.clear();
                });
                _fetchExams(course["courseid"]);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _selectExam(Map<String, dynamic> exam) async {
    final sp = await SharedPreferences.getInstance();
    final studentId = sp.getString("studentid") ?? "";
    final examId = exam["examId"];

    final marksUri = "http://$ipAddress/flutter/view_marks.php";
    final res = await http.post(Uri.parse(marksUri), body: {
      "exam_id": examId.toString(),
      "student_id": studentId,
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data["success"]) {
        final base64String = data["subject_marks"];
        final decodedString = utf8.decode(base64.decode(base64String));
        final Map<String, dynamic> marksMap = jsonDecode(decodedString);

        final decodedSubjectList = jsonDecode(utf8.decode(base64.decode(exam["subjectList"])));

        List<Map<String, dynamic>> subjects = [];

        for (String subjectId in decodedSubjectList.keys) {
          if (decodedSubjectList[subjectId] == true && marksMap.containsKey(subjectId)) {
            final subjectName = await _getSubjectName(subjectId);
            subjects.add({
              "subjectId": subjectId,
              "subjectName": subjectName,
              "marks": marksMap[subjectId],
              "outOf": 100,
            });
          }
        }

        setState(() {
          selectedExamId = examId;
          subjectMarks = subjects;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No marks found for this exam")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching marks")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Student Marks")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Student Marks"),
        actions: [
          IconButton(
            icon: Icon(Icons.school),
            onPressed: _showCourseDialog,
            tooltip: "Change Course",
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: selectedExamId == null
            ? _buildExamSelection()
            : _buildMarksDetail(subjectMarks),
      ),
    );
  }

  Widget _buildExamSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Exam",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
        Divider(color: Colors.blue[900]),
        ...exams.map((exam) => Card(
          child: ListTile(
            title: Text(exam["examName"]),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              _selectExam(exam);
            },
          ),
        )),
      ],
    );
  }
  Future<String> _getSubjectName(String subjectId) async {
    String uri = "http://$ipAddress/flutter/get_subject_name.php";
    final res = await http.post(Uri.parse(uri), body: {
      "subject_id": subjectId,
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data["success"] == true) {
        return data["subject_name"];
      }
    }
    return "Subject $subjectId"; // Fallback
  }
  Widget _buildMarksDetail(List<Map<String, dynamic>> marksList) {
    int totalObtained = marksList.fold(0, (sum, item) => sum + (item["marks"] as int));

    // Get total from selected exam
    int totalMax = 0;
    if (selectedExamId != null) {
      final selectedExam = exams.firstWhere((exam) => exam["examId"] == selectedExamId);
      totalMax = selectedExam["overallTotal"] ?? 0;
    }

    double percentage = totalMax > 0 ? (totalObtained / totalMax) * 100 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () {
            setState(() {
              selectedExamId = null;
              subjectMarks.clear();
            });
          },
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          label: Text("Back to Exams", style: TextStyle(color: Colors.blue)),
        ),
        SizedBox(height: 10),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Marks Details",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900])),
                Divider(color: Colors.blue[900]),
                ...marksList.map((subject) => ListTile(
                  leading: Icon(Icons.book, color: Colors.blue),
                  title: Text(subject["subjectName"]),
                  subtitle:
                  Text("Marks: ${subject["marks"]}"),
                )),
                Divider(color: Colors.grey),
                ListTile(
                  title: Text("Total Marks",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text("$totalObtained / $totalMax"),
                ),
                ListTile(
                  title: Text("Percentage",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text("${percentage.toStringAsFixed(2)}%"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}