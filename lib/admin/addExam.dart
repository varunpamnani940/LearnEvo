import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../login.dart';

class AddExam extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddExamState();
  }
}

class AddExamState extends State<AddExam> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController examTypeController = TextEditingController();
  TextEditingController totalMarksController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  List<Map<String, dynamic>> examList = [];
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> subjects = [];
  String? selectedCourse;
  Map<String, bool> selectedSubjects = {};
  String? encodedSubjects;
  int? total_subj ;

  @override
  void initState() {
    super.initState();
    fetchCourses();
    fetchExams();
  }

  Future<void> fetchCourses() async {
    String uri = "http://$ipAddress/flutter/viewcourse.php";
    var res = await http.get(Uri.parse(uri));
    print(res.body);
    if (res.statusCode == 200) {
      setState(() {
        courses = List<Map<String, dynamic>>.from(json.decode(res.body));
      });
    }
  }

  Future<void> fetchSubjects(String courseId) async {
    String uri = "http://$ipAddress/flutter/viewsubject.php";
    var res = await http.post(Uri.parse(uri), body: {
      "courseod": courseId
    });
    print(res.body);
    if (res.statusCode == 200) {
      setState(() {
        subjects = List<Map<String, dynamic>>.from(json.decode(res.body));
        selectedSubjects = {for (var subject in subjects) subject["subjectid"]: false};
      });
    }
  }

  Future<void> uploadData() async {
    String uri = "http://$ipAddress/flutter/add_exam.php";
    int selectedCount = selectedSubjects.values.where((value) => value == true).length;
    int totalMarks = int.tryParse(totalMarksController.text) ?? 0; // Ensure it's an integer

    int overallTotalMarks = selectedCount * (totalMarks); // Safe multiplication

    print("Overall Total Marks: $overallTotalMarks");
    List<String> selectedSubjectIds = selectedSubjects.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    var res = await http.post(Uri.parse(uri), body: {
      "name": examTypeController.text,
      "marks": totalMarksController.text,
      "date": dateController.text,
      "courseid": selectedCourse,
      "subjects": encodedSubjects,
      'o_total_m':overallTotalMarks.toString()
    });

    if (res.statusCode == 200) {
      fetchExams();
      print(res.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Exam Added Successfully")));
    }
    print(res.body);
  }

  Future<void> fetchExams() async {
    String uri = "http://$ipAddress/flutter/get_examp.php";
    var res = await http.get(Uri.parse(uri));

    if (res.statusCode == 200) {
      setState(() {
        examList = List<Map<String, dynamic>>.from(json.decode(res.body));
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat("yyyy-MM-dd").format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Container(
        color: Colors.blue[700],
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 10),
            Text(
              "Add Exam",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add a New Exam", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
              Divider(color: Colors.blue[900]),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField("Exam Type", Icons.edit, examTypeController),
                      _buildTextField("Total Marks", Icons.calculate, totalMarksController, isNumeric: true),
                      _buildDateField(),
                      _buildCourseDropdown(),
                      if (selectedCourse != null) _buildSubjectsCheckbox(),
                      SizedBox(height: 10),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),
              _buildPreviousExams(),
            ],
          ),
        ),
      ),
    );
  }
  void _confirmDeleteDialog(String? subjectId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Subject"),
        content: Text("Are you sure you want to delete this subject?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              deleteSubject(subjectId!);
              Navigator.pop(context);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }
  Future<void> deleteSubject(String subjectId) async {
    String uri = "http://$ipAddress/flutter/delete_exam.php";
    var res = await http.post(Uri.parse(uri), body: {
      "device_id": subjectId,
    });

    print("Raw response: ${res.body}"); // Debugging line

    try {
      var response = jsonDecode(res.body);
      print("Decoded response: $response"); // Debugging line

      if (response['status'] == "success") {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Subject Deleted Successfully")),

        );
      await   fetchExams();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete subject")),
        );
      }
    } catch (e) {
      print("Error decoding JSON: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid JSON response")),
      );
    }
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue.shade400)),
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
        validator: (value) => value!.isEmpty ? 'Please enter $hint' : null,
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: dateController,
      readOnly: true,
      decoration: InputDecoration(
        hintText: "Select Date",
        prefixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildCourseDropdown() {
    return DropdownButtonFormField(
      value: selectedCourse,
      hint: Text("Select Course"),
      items: courses.map((course) {
        return DropdownMenuItem(
          value: course["courseid"],
          child: Text(course["coursename"]),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCourse = value.toString();
          fetchSubjects(selectedCourse!);
          print(selectedCourse);
        });
      },
    );
  }

  Widget _buildSubjectsCheckbox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: subjects.map((subject) {
        return CheckboxListTile(
          title: Text(subject["subjectname"]),
          value: selectedSubjects[subject["subjectid"]],
          onChanged: (bool? value) {
            setState(() {
              selectedSubjects[subject["subjectid"]] = value!;
              encodedSubjects = base64Encode(utf8.encode(jsonEncode(selectedSubjects)));
              print(selectedSubjects);
              print(encodedSubjects);

              total_subj = selectedSubjects.values.where((value) => value == true).length;
              print(total_subj);
            });

          },
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          uploadData();
        }
      },
      child: Text("Add Exam"),
    );
  }

  Widget _buildPreviousExams() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Previous Exams",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue[900],
            ),
          ),
          Divider(color: Colors.blue[900]),
          examList.isEmpty
              ? Center(child: Text("No exams added yet", style: TextStyle(fontSize: 14)))
              : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // Prevents double scrolling issue
            itemCount: examList.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(
                    examList[index]["exam_name"] ?? "",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "Marks: ${examList[index]["exam_total_marks"]}  |  Date: ${examList[index]["exam_date"]}",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  trailing:  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _confirmDeleteDialog(examList[index]["id"]);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
