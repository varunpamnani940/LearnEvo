import 'dart:convert';
import 'package:dreamclass/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'feesdetails.dart';

class feesstud extends StatefulWidget {
  final String? CourseName;

  feesstud(this.CourseName);

  @override
  State<StatefulWidget> createState() {
    return feesstudstate(CourseName);
  }
}

class feesstudstate extends State<feesstud> {
  String? Coursename;
  TextEditingController _feesController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  String _selectedPaymentMode = "Cash"; // Default value for payment mode
  List<String> paymentModes = ["Cash", "Cheque", "Online"]; // List of payment modes
  List student = [];
  List filteredStudents = [];

  feesstudstate(this.Coursename);
  String paidFees = "";
  String paidDate = "";
  String paymentMode = "";

  Future<void> getdata() async {
    String uri = "http://$ipAddress/flutter/getcoursefeesdata.php";
    var res = await http.post(Uri.parse(uri), body: {
      "coursename": Coursename
    });
    final SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      sp.setString("coursename", Coursename!);
      print(res.body);
      student = jsonDecode(res.body);
      filteredStudents = student; // Initially show all students
    });
  }

  Future<void> updatefees(int index) async {
    String uri = "http://${ipAddress}/flutter/updatefees.php";
    var res = await http.post(Uri.parse(uri), body: {
      "receiableid": student[index]["receiableid"],
      "date": paidDate,
      "fees": paidFees,
      "paymentmethod": paymentMode
    });
  }

  @override
  void initState() {
    super.initState();
    getdata();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents() {
    setState(() {
      filteredStudents = student
          .where((s) => s["studentname"]
          .toLowerCase()
          .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void show(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Choose option"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Material(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          showAddFeesDialog(index);
                        },
                        child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Text(
                                "Add New",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15),
                              ),
                            )),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 10),
                    child: Material(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      feesdetail()));
                        },
                        child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: Text(
                                "Payment History",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15),
                              ),
                            )),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void showAddFeesDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Fees Payment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _feesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount Paid",
                ),
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: "Date",
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text =
                      "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                    });
                  }
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Payment Mode",
                ),
                value: _selectedPaymentMode,
                items: paymentModes.map((String mode) {
                  return DropdownMenuItem<String>(
                    value: mode,
                    child: Text(mode),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPaymentMode = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  paidFees = _feesController.text;
                  paidDate = _dateController.text;
                  paymentMode = _selectedPaymentMode;
                });
                await updatefees(index);
                await getdata();
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
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
              height: 100,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(color: Colors.blue[700]),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              height:700,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(120),
                  topLeft: Radius.circular(120),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top:40,left: 30,right: 30,bottom: 10 ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: "Search by student name",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top:10,left: 20,right: 20,bottom: 10 ),
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {
                              show(index);
                            },
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      filteredStudents[index]["studentname"],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 100),
                                      child: Icon(
                                        Icons.add,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Text("Discount: "),
                                    Text(filteredStudents[index]["dicount"]
                                        .toString()),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Receivable Fees: "),
                                    Text(filteredStudents[index]
                                    ["receiablefees"]),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Total Received Fees: "),
                                    Text(filteredStudents[index]
                                    ["receivedfees"]),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
