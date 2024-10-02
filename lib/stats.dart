import 'package:flutter/material.dart';

class StudentStatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard - Student Statistics"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Text(
              "Student Statistics",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Statistics Cards Row (Including fees received and receivable)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatisticsCard("Total Students", "250", Colors.blueAccent),
                _buildStatisticsCard(
                    "Average Attendance", "85%", Colors.greenAccent),
                _buildStatisticsCard("Fees Received", "₹500,000", Colors.purpleAccent),
                _buildStatisticsCard("Fees Receivable", "₹100,000", Colors.orangeAccent),
              ],
            ),
            SizedBox(height: 20),

            // Graph Section (Placeholder)
            Expanded(
              child: _buildChartSection(),
            ),

            SizedBox(height: 20),

            // Student Data Table (Now includes fee-related columns)
            _buildStudentDataTable(),
          ],
        ),
      ),
    );
  }

  // Widget for building statistic cards
  Widget _buildStatisticsCard(String title, String value, Color color) {
    return Card(
      elevation: 5,
      color: color,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder for the chart/graph section
  Widget _buildChartSection() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text("Chart Placeholder - Add Graphs Here"),
      ),
    );
  }

  // DataTable for showing student stats (Now includes fee-related data)
  Widget _buildStudentDataTable() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text("ID")),
            DataColumn(label: Text("Name")),
            DataColumn(label: Text("Attendance")),
            DataColumn(label: Text("Performance")),
            DataColumn(label: Text("Fees Received")),
            DataColumn(label: Text("Fees Receivable")),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text("1")),
              DataCell(Text("John Doe")),
              DataCell(Text("90%")),
              DataCell(Text("Excellent")),
              DataCell(Text("₹50,000")),
              DataCell(Text("₹10,000")),
            ]),
            DataRow(cells: [
              DataCell(Text("2")),
              DataCell(Text("Jane Smith")),
              DataCell(Text("85%")),
              DataCell(Text("Good")),
              DataCell(Text("₹45,000")),
              DataCell(Text("₹5,000")),
            ]),
            // Add more student rows here
          ],
        ),
      ),
    );
  }
}
