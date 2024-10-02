import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ResultsUploadPage extends StatefulWidget {
  @override
  _ResultsUploadPageState createState() => _ResultsUploadPageState();
}

class _ResultsUploadPageState extends State<ResultsUploadPage> {
  List<String> _students = ["John Doe", "Jane Smith", "Alice Johnson"];
  String? _selectedStudent;
  String? _uploadedFilePath;

  void _uploadFile() async {
    // Allow the user to select a file
    String? filePath = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'], // Allow only CSV or Excel files
    ).then((result) {
      if (result != null) {
        return result.files.single.path;
      }
      return null;
    });

    if (filePath != null) {
      setState(() {
        _uploadedFilePath = filePath;
      });
    }
  }

  void _submitResults() {
    // Logic to submit the results
    if (_uploadedFilePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Results uploaded successfully for $_selectedStudent!')),
      );
      // Reset the state
      setState(() {
        _uploadedFilePath = null;
        _selectedStudent = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload a file before submitting.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Selection Dropdown
            Text(
              "Select Student:",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Choose a student',
              ),
              value: _selectedStudent,
              items: _students.map((student) {
                return DropdownMenuItem<String>(
                  value: student,
                  child: Text(student),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStudent = value;
                });
              },
            ),
            SizedBox(height: 20),

            // File Upload Button
            Text(
              "Upload Results File:",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _uploadFile,
              child: Text('Choose File'),
            ),
            if (_uploadedFilePath != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Uploaded File: ${_uploadedFilePath!.split('/').last}',
                  style: TextStyle(color: Colors.green),
                ),
              ),

            Spacer(),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _submitResults,
                child: Text('Upload Results'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
