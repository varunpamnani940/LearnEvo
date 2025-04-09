import 'dart:convert';
import 'package:dreamclass/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import "package:pdf/pdf.dart";
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
class studentfees extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return studentfeesState();
  }
}

class studentfeesState extends State<studentfees> {
  List data = [];
  List<Map<String, dynamic>> courseTotalsList = [];
  List<Map<String, dynamic>> filteredCourseTotalsList = [];
  Map<String, Map<String, int>> courseTotals = {};
  TextEditingController _searchController = TextEditingController();

  Future<void> generateReceipt(String courseName, int totalDiscount, int totalReceivableFees, int totalReceivedFees) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header: Institute Name
                pw.Center(
                  child: pw.Text(
                    "LearnEvo  Academy",
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Divider(),

                // Receipt Title
                pw.Center(
                  child: pw.Text(
                    "FEE RECEIPT",
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Student & Course Details
                pw.Text("Course Name: $courseName", style: pw.TextStyle(fontSize: 14)),
                pw.Text("Receipt Date: ${DateTime.now().toLocal()}"),
                pw.SizedBox(height: 10),

                // Fee Breakdown Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text("Description", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text("Amount", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    tableRow("Total Fees", totalReceivableFees),
                    tableRow("Discount", totalDiscount),
                    tableRow("Amount Paid", totalReceivedFees),
                    tableRow("Pending Fees", totalReceivableFees - totalReceivedFees),
                  ],
                ),

                pw.SizedBox(height: 30),

                // Signature Section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Authorized Signatory", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Student Signature", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),

                pw.SizedBox(height: 10),
                pw.Divider(),

                // Footer
                pw.Center(
                  child: pw.Text(
                    "Thank you for your payment!",
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final output = await getExternalStorageDirectory();
    final file = File("${output!.path}/$courseName-Receipt.pdf");

    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);
  }

// Helper Function to Create Table Rows
  pw.TableRow tableRow(String title, int amount) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.all(8),
          child: pw.Text(title),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.all(8),
          child: pw.Text("₹ $amount"),
        ),
      ],
    );
  }
  Future<void> getData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String uri = "http://$ipAddress/flutter/studentflowapis/getfeesdata.php"; // Replace with your actual IP address or server
    try {
      var res = await http.post(Uri.parse(uri),body: {
        "studentid": sp.getString("studentid")
      });
      if (res.statusCode == 200) {
        print("ss");
        setState(() {
          print(res.body);
          data = jsonDecode(res.body);
          print(data);

          // Clear the list and map before recalculating
          courseTotalsList.clear();
          courseTotals.clear();

          for (var student in data) {
            String courseName = student['coursename'];

            // Ensure conversion from String to int for discount, receivable fees, and received fees
            int discount = int.tryParse(student['dicount']) ?? 0;
            int receivableFees = int.tryParse(student['receiablefees']) ?? 0;
            int receivedFees = int.tryParse(student['receivedfees']) ?? 0;

            // If the course is already in the map, update the totals
            if (courseTotals.containsKey(courseName)) {
              courseTotals[courseName]!['totalDiscount'] =
                  courseTotals[courseName]!['totalDiscount']! + discount;
              courseTotals[courseName]!['totalReceivableFees'] =
                  courseTotals[courseName]!['totalReceivableFees']! + receivableFees;
              courseTotals[courseName]!['totalReceivedFees'] =
                  courseTotals[courseName]!['totalReceivedFees']! + receivedFees;
            } else {
              // Otherwise, initialize the course totals
              courseTotals[courseName] = {
                'totalDiscount': discount,
                'totalReceivableFees': receivableFees,
                'totalReceivedFees': receivedFees,
              };
            }
          }

          // Convert the courseTotals map into a dynamic list of maps
          courseTotals.forEach((course, totals) {
            courseTotalsList.add({
              'courseName': course,
              'totalDiscount': totals['totalDiscount'],
              'totalReceivableFees': totals['totalReceivableFees'],
              'totalReceivedFees': totals['totalReceivedFees'],
            });
          });

          // Initially, the filtered list will be the same as the full list
          filteredCourseTotalsList = List.from(courseTotalsList);

          print(courseTotalsList);
        });
      } else {
        print("Failed to load data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getData();

    // Add a listener to the search field
    _searchController.addListener(() {
      filterCourses();
    });
  }

  void filterCourses() {
    setState(() {
      filteredCourseTotalsList = courseTotalsList.where((course) {
        return course['courseName']
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    });
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
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.only(top: 30,left: 30,right: 30,bottom: 10),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by Course Name',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(left: 40,right: 40,bottom: 20),
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: filteredCourseTotalsList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {
                              print(filteredCourseTotalsList[index]["courseName"]);

                            },
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  filteredCourseTotalsList[index]["courseName"],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Text(" Discount: "),
                                    Text(filteredCourseTotalsList[index]["totalDiscount"].toString()),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Total Pending Fees: "),
                                    Text(filteredCourseTotalsList[index]["totalReceivableFees"].toString()),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Total Paid Fees: "),
                                    Text(filteredCourseTotalsList[index]["totalReceivedFees"].toString()),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    generateReceipt(
                                      filteredCourseTotalsList[index]["courseName"],
                                      filteredCourseTotalsList[index]["totalDiscount"],
                                      filteredCourseTotalsList[index]["totalReceivableFees"],
                                      filteredCourseTotalsList[index]["totalReceivedFees"],
                                    );
                                  },
                                  icon: Icon(Icons.download),
                                  label: Text("Download Receipt"),
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
