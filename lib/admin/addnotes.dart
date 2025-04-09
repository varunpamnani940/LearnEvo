import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

import '../login.dart';

class AddNotes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddNotesState();
}

class AddNotesState extends State<AddNotes> {
  List courses = [];
  List subjects = [];
  String? selectedCourse;
  String? selectedSubject;
  List notes = [];
  String? base64Pdf;
  final _formKey = GlobalKey<FormState>();
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    fetchCourses();
    fetchPreviousNotes();
    requestStoragePermissions();
    requestStoragePermission();
  }

  Future<void> fetchCourses() async {
    String uri = "http://$ipAddress/flutter/viewcourse.php";
    var res = await http.get(Uri.parse(uri));
    if (res.statusCode == 200) {
      setState(() {
        courses = jsonDecode(res.body);
      });
    }
  }
  List previousNotes = [];
  Future<void> requestStoragePermission() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }
    if (await Permission.photos.isDenied) {
      await Permission.photos.request();
    }
    if (await Permission.videos.isDenied) {
      await Permission.videos.request();
    }
  }

  Future<void> fetchPreviousNotes() async {
    String uri = "http://$ipAddress/flutter/view_all_notes.php";
    var res = await http.get(Uri.parse(uri));
    if (res.statusCode == 200) {
      setState(() {
        previousNotes = jsonDecode(res.body);
        notes = previousNotes;
        print(previousNotes);
      });
    }
  }
  TextEditingController name = TextEditingController();
  Future<void> fetchSubjects(String courseId) async {
    String uri = "http://$ipAddress/flutter/viewsubject.php";
    var res = await http.post(Uri.parse(uri), body: {"courseod": courseId});
    print(res.body);
    if (res.statusCode == 200) {
      setState(() {
        subjects = jsonDecode(res.body);
      });
    }
  }

  Future<void> selectPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      File file = File(result.files.single.path!);
      List<int> fileBytes = await file.readAsBytes();
      setState(() {
        base64Pdf = base64Encode(fileBytes);
      });
    }
  }

  Future<void> uploadNotes() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (base64Pdf == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please select a PDF file")));
        return;
      }
      setState(() {
        isUploading = true;
      });
      String uri = "http://$ipAddress/flutter/addnotes.php";
      var res = await http.post(Uri.parse(uri), body: {
        "name": name.text,
        "courseid": selectedCourse,
        "subjectid": selectedSubject,
        "file": base64Pdf,
      });
      fetchPreviousNotes();
      print(res.body);
      if (jsonDecode(res.body)["noteuploaded"] == "true") {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Notes Uploaded Successfully")));
      }
      setState(() {
        isUploading = false;
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
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      child: Container(
        color: Colors.blue[700],
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        child: Row(
          children: [
            IconButton(icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context)),
            SizedBox(width: 10),
            Text("Add Notes", style: TextStyle(fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
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
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Upload New Notes", style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900])),
                  Divider(color: Colors.blue[900]),
                  _buildTextField("Name", Icons.person, name),
                  _buildDropdown(
                      "Select Course", selectedCourse, courses, (value) {
                    setState(() {
                      selectedCourse = value;
                      fetchSubjects(selectedCourse!);
                    });
                  }),
                  _buildDropdown_s(
                      "Select Subject", selectedSubject, subjects, (value) {
                    setState(() {
                      selectedSubject = value;
                    });
                  }),
                  SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: selectPDF, child: Text("Select PDF")),
                  SizedBox(height: 10),
                  Center(
                    child:_buildSubmitButton(),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildNotesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List data,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField(
        value: value,
        hint: Text(hint),
        items: data.map((item) {
          return DropdownMenuItem(
              value: item["courseid"], child: Text(item["coursename"]));
        }).toList(),
        onChanged: (value) => onChanged(value as String?),

        validator: (value) => value == null ? 'Please select $hint' : null,
      ),
    );
  }

  Widget _buildDropdown_s(String hint, String? value, List data,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField(
        value: value,
        hint: Text(hint),
        items: data.map((item) {
          return DropdownMenuItem(
              value: item["subjectid"], child: Text(item["subjectname"]));
        }).toList(),
        onChanged: (value) => onChanged(value as String?),

        validator: (value) => value == null ? 'Please select $hint' : null,
      ),
    );
  }
  Future<void> requestStoragePermissions() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }

    if (await Permission.manageExternalStorage.isDenied &&
        await Permission.manageExternalStorage.isPermanentlyDenied == false) {
      await Permission.manageExternalStorage.request();
    }

    // For Android 13+ (Scoped Storage)
    if (await Permission.photos.isDenied) {
      await Permission.photos.request();
    }
    if (await Permission.videos.isDenied) {
      await Permission.videos.request();
    }
    if (await Permission.audio.isDenied) {
      await Permission.audio.request();
    }
  }
  Future<void> downloadFile(String url, String fileName, context) async {
    // Request permissions
    await requestStoragePermissions();

    try {
      Directory? directory;

      if (Platform.isAndroid) {
        if (await Permission.manageExternalStorage.isGranted) {
          // For Android 10+ with MANAGE_EXTERNAL_STORAGE
          directory = Directory('/storage/emulated/0/Download');
        } else {
          // Use scoped storage location for Android 10+
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);

        Dio dio = Dio();
        var response = await dio.download(url, filePath);

        if (response.statusCode == 200) {
          print('File downloaded to $filePath');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Downloaded to $filePath')),
          );
          OpenFile.open(filePath);
        } else {
          print('Failed to download file');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to download file')),
          );
        }
      }
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    }
  }
  Widget _buildTextField(String hint, IconData icon,
      TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(icon, color: Colors.blue),
          hintText: hint,
        ),
      ),
    );
  }
  Future<void> editNote(String id, String name,  {String? base64Pdf}) async {
    String uri = "http://$ipAddress/flutter/edit_notes.php";
    print(uri);
    print(base64Pdf);
    var res = await http.post(Uri.parse(uri), body: {
      "id": id,
      "name": name,
      "file": base64Pdf ?? "", // Send an empty string if no file is uploaded
    });
    print(res.body);
    if (jsonDecode(res.body)["noteupdated"] == "true") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Note Updated Successfully")),
      );
      fetchPreviousNotes(); // Refresh the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to Update Note")),
      );
    }
  }
  void showEditDialog(Map note) {
    TextEditingController nameController = TextEditingController(text: note["notes_name"]);
    String? selectedCourse = note["courseid"];
    String? selectedSubject = note["subjectid"];
    String? base64Pdf;
   setState(() {
     fetchSubjects(selectedCourse!);
   });

    Future<void> selectPDF() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        File file = File(result.files.single.path!);
        List<int> fileBytes = await file.readAsBytes();
        base64Pdf = base64Encode(fileBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PDF Selected: ${file.path.split('/').last}")),
        );
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Note Name'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: selectPDF,
                  child: Text("Change PDF"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty

                   ) {
                  editNote(
                    note["noteid"],
                    nameController.text,
                    base64Pdf: base64Pdf, // Pass PDF file if changed
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
  Future<void> deleteNote(String id) async {
    String uri = "http://$ipAddress/flutter/delete_note.php";
    var res = await http.post(Uri.parse(uri), body: {
      "id": id,
    });
    print(res.body);

    if (jsonDecode(res.body)["notedeleted"] == "true") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Note Deleted Successfully")),
      );
      fetchPreviousNotes(); // Refresh notes list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to Delete Note")),
      );
    }
  }

  Widget _buildNotesList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Previous Notes", style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900])),
            Divider(color: Colors.blue[900]),
            ...notes.map((note) =>
                ListTile(
                  leading:  Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: Text(note["notes_name"] ?? "Unnamed Note"),
                  subtitle: Text("Uploaded on: ${note["date"]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // DOWNLOAD BUTTON
                      IconButton(
                        icon: Icon(Icons.download, color: Colors.green),
                        onPressed: () {
                          String fileUrl = "http://$ipAddress/flutter/${note['link']}";
                          String fileName = note['link'].split('/').last;
                          print(fileUrl);
                          downloadFile(fileUrl, fileName,context
                          );
                        },
                      ),
                      // EDIT BUTTON
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showEditDialog(note),
                      ),
                      // DELETE BUTTON
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Delete Note"),
                              content: Text("Are you sure you want to delete this note?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await deleteNote(note["noteid"]);
                                  },
                                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),


                    ],
                  ),

                )
            )
          ],
        ),
      ),
    );
  }


  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: isUploading ? null : uploadNotes,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.blue[900],
      ),
      child: isUploading
          ? CircularProgressIndicator(color: Colors.white)
          : Text("Upload Notes", style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}