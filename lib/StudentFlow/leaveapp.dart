import 'package:dreamclass/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LeaveApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LeaveAppState();
}

class LeaveAppState extends State<LeaveApp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  List<DateTime> _dateList = [];

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _endDate = null;
        _dateList.clear();
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select start date first.')));
      return;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _generateDateList();
      });
    }
  }

  void _generateDateList() {
    if (_startDate != null && _endDate != null) {
      _dateList = [];
      for (var i = _startDate!;
      i.isBefore(_endDate!);
      i = i.add(Duration(days: 1))) {
        _dateList.add(i);
      }
      _dateList.add(_endDate!);
    }

    List<String> _finalDate = _dateList.map((date) {
      return DateFormat('yyyy-MM-dd').format(date);
    }).toList();
    print(_finalDate);
  }

  Future<void> _sendLeaveData({
    required String studentId,
    required String reason,
    required String fromDate,
    required String toDate,
  }) async {
    var url = Uri.parse("http://$ipAddress/flutter/studentflowapis/leave_app.php"); // 🔁 Replace with your actual URL

    try {
      var response = await http.post(
        url,
        body: {
          'student_id': studentId,
          'Leave_reason': reason,
          'from_date': fromDate,
          'to_date': toDate,
        },
      );

      if (response.statusCode == 200) {
        print("Response: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Leave Application Submitted Successfully!")),
        );
        _reasonController.clear();
        setState(() {
          _startDate = null;
          _endDate = null;
          _dateList.clear();
        });
      } else {
        print("Server error: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong!")),
      );
    }
  }

  void _submitLeaveApplication()  async{
    if (_formKey.currentState?.validate() ?? false) {
      final SharedPreferences studentid = await SharedPreferences.getInstance();
      String? studentId = studentid.getString("studentid")?.trim(); // 🔁 Replace with SharedPreferences if needed
      String reason = _reasonController.text;
      String from = DateFormat('yyyy-MM-dd').format(_startDate!);
      String to = DateFormat('yyyy-MM-dd').format(_endDate!);

      _sendLeaveData(
        studentId: studentId!,
        reason: reason,
        fromDate: from,
        toDate: to,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Leave Application",
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 50, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Leave Application",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apply for Leave',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _reasonController,
                          decoration: InputDecoration(
                            labelText: 'Reason for Leave',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please provide a reason for the leave.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectStartDate(context),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: TextEditingController(
                                      text: _startDate != null
                                          ? DateFormat('yyyy-MM-dd')
                                          .format(_startDate!)
                                          : '',
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Start Date',
                                      hintText: 'Select Start Date',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (_startDate == null) {
                                        return 'Please select a start date.';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectEndDate(context),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: TextEditingController(
                                      text: _endDate != null
                                          ? DateFormat('yyyy-MM-dd')
                                          .format(_endDate!)
                                          : '',
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'End Date',
                                      hintText: 'Select End Date',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (_endDate == null) {
                                        return 'Please select an end date.';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitLeaveApplication,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Submit Leave Application',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
