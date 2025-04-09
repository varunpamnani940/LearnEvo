import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class BulkUploadScreen extends StatefulWidget {
  @override
  _BulkUploadScreenState createState() => _BulkUploadScreenState();
}

class _BulkUploadScreenState extends State<BulkUploadScreen> {
  bool _isLoading = true;
  final String apiUrl = "http://51.20.10.147/flutter/bhulk_student_pload.php";
  final String spreadsheetUrl = "https://docs.google.com/spreadsheets/d/12O7B006akC707xkGifsqZMKhCHuxWWpgGU6JrVGOhAo/edit?gid=0#gid=0";

  @override
  void initState() {
    super.initState();
    _startUpload();
  }

  Future<void> _startUpload() async {
    try {
      final response = await http.post(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // Upload successful
        await _launchSpreadsheet();
      } else {
        _showError("Upload failed. Please try again.");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchSpreadsheet() async {
    if (await canLaunch(spreadsheetUrl)) {
      await launch(spreadsheetUrl);
    } else {
      _showError("Could not launch spreadsheet.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Uploading Students"),
        centerTitle: true,
      ),
      body: Center(
        child: _isLoading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Uploading, please wait..."),
          ],
        )
            : Icon(Icons.check_circle, color: Colors.green, size: 80),
      ),
    );
  }
}
