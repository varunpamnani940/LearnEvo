import 'dart:convert';
import 'package:dreamclass/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class feesstud extends StatefulWidget {
  String? CourseName;
  @override
  State<StatefulWidget> createState() {
    return feesstudstate(CourseName);
  }

  feesstud(this.CourseName);
}

List student = [];

class feesstudstate extends State<feesstud> {
  String? Coursename;
  TextEditingController _feesController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  String _selectedPaymentMode = "Cash"; // Default value for payment mode
  List<String> paymentModes = ["Cash", "Cheque", "Online"]; // List of payment modes

  feesstudstate(this.Coursename);
  Future<void> getdata() async {
    String uri = "http://$ipAddress/flutter/getcoursefeesdata.php";
    var res = await http.post(Uri.parse(uri), body: {
      "coursename": Coursename
    });
    setState(() {
      print(res.body);
      student = jsonDecode(res.body);
    });
  }
  @override
  void initState() {
    super.initState();
    getdata();
  }

  // Function to show the dialog
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Here you can send the updated fees, date, and payment mode to the server
                String paidFees = _feesController.text;
                String paidDate = _dateController.text;
                String paymentMode = _selectedPaymentMode;
                print("Student ID: ${student[index]["receiableid"]}");
                print("Paid Fees: $paidFees");
                print("Date: $paidDate");
                print("Payment Mode: $paymentMode");

                // Reset the input fields
                _feesController.clear();
                _dateController.clear();

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
              height: 400,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(color: Colors.blue[700]),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              height: 700,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(120),
                  topLeft: Radius.circular(120),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(40),
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: student.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {
                              showAddFeesDialog(index);
                            },
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student[index]["studentname"],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Text("Discount: "),
                                    Text(student[index]["dicount"].toString()),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Recieable Fees: "),
                                    Text(student[index]["receiablefees"]),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Total Received Fees: "),
                                    Text(student[index]["receivedfees"]),
                                    Padding(
                                      padding: EdgeInsets.only(left: 60),
                                      child: Icon(
                                        Icons.add,
                                        size: 50,
                                      ),
                                    ),
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
