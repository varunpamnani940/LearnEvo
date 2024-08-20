import 'dart:convert';
import 'package:dreamclass/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_Student.dart';
class atten extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return attenstate();
  }
}
class attenstate extends State<atten>{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Attendence Details",
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(150.0),
              child: AppBar(
                title: Text(
                  "Attendence Details",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700),
                ),
                backgroundColor: Colors.blue[700],
                leading: Container(
                  child: Material(
                    color: Colors.blue[700],
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StudentDashboard()));
                      },
                      child: Icon(
                        Icons.arrow_circle_left_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: Stack(
              children: [
                Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(color: Colors.blue[700]),
                ),
                Container(
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(80),
                            topRight: Radius.circular(80))),
                    child:Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CustomCalendar(),
                    )
                )
              ],
            )));
  }
}




class CustomCalendar extends StatefulWidget {
  @override
  _CustomCalendarState createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  Future<void> getdata() async{
    final SharedPreferences studentid  = await SharedPreferences.getInstance();
    String uri = "http://${ipAddress}/flutter/StudentFlowapis/getattendence.php";
    var res =  await http.post(Uri.parse(uri),body: {
      "studentid":studentid.getString("studentid")
    });
    setState(() {
      Map<String, dynamic> data = jsonDecode(res.body);
      print(data);
      setState(() {
        Map<String, dynamic> data = jsonDecode(res.body);
        data.forEach((key, value) {
          DateTime date = DateTime.parse(key);
          if (value == 'p') {
            presentDates.add(DateTime(date.year, date.month, date.day));
          } else if (value == 'a') {
            absentDates.add(DateTime(date.year, date.month, date.day));
          }
        });
      });

    });
  }

  // Example lists for present and absent dates
  List<DateTime> presentDates = [];

  List<DateTime> absentDates = [];
  List<DateTime> leaveDates = [
    DateTime(2024,08,10),
  ];
  @override
  void initState() {
    getdata();
    super.initState();
  }
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildDaysOfWeek(),
        _buildDateGrid(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _focusedDate = DateTime(
                _focusedDate.year,
                _focusedDate.month - 1,
              );
            });
          },
        ),
        Text(
          DateFormat.yMMMM().format(_focusedDate),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () {
            setState(() {
              _focusedDate = DateTime(
                _focusedDate.year,
                _focusedDate.month + 1,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildDaysOfWeek() {
    final daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: daysOfWeek.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateGrid() {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final numDaysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final totalItems = numDaysInMonth + firstWeekday;

    return GridView.builder(
      shrinkWrap: true,
      itemCount: totalItems,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemBuilder: (context, index) {
        if (index < firstWeekday) {
          return Container();
        }
        final day = index - firstWeekday + 1;
        final date = DateTime(_focusedDate.year, _focusedDate.month, day);

        // Check if the date is in the present or absent list
        Color backgroundColor;
        if (presentDates.any((d) => isSameDate(d, date))) {
          backgroundColor = Colors.green;
        } else if (absentDates.any((d) => isSameDate(d, date))) {
          backgroundColor = Colors.red;
        }else if (leaveDates.any((d) => isSameDate(d, date))) {
          backgroundColor = Colors.yellow;}
        else {
          backgroundColor = _selectedDate == date ? Colors.blue : Colors.transparent;
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(4),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: _selectedDate == date ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to check if two dates are the same
  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
