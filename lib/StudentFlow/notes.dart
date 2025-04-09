import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../login.dart';
import 'dashboard_Student.dart';
class Notes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NotesState();
  }
}

class NotesState extends State<Notes> {
  List CourseData = [];
  List SubjectData = [];
  List NotesData = [];
  String? selectSubject;
  String? selectItem;
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> getCourseData() async {
    setState(() {
      isLoading = true;
    });
    String uri = "http://$ipAddress/flutter/viewcourse.php";
    var res = await http.post(Uri.parse(uri));
    setState(() {
      CourseData = jsonDecode(res.body);
      isLoading = false;
    });
  }

  Future<void> getSubjectData() async {
    setState(() {
      isLoading = true;
    });
    String uri = "http://$ipAddress/flutter/viewsubject.php";
    var res = await http.post(Uri.parse(uri), body: {"courseod": selectItem});
    setState(() {
      SubjectData = jsonDecode(res.body);
      selectSubject = null;
      isLoading = false;
    });
  }

  Future<void> getNotes() async {
    setState(() {
      isLoading = true;
    });
    String uri = "http://$ipAddress/flutter/studentflowapis/getnotes.php";
    var res = await http.post(Uri.parse(uri), body: {
      "courseid": selectItem,
      "subjectid": selectSubject
    });

    if (res.statusCode == 200) {
      setState(() {
        NotesData = jsonDecode(res.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to load notes');
    }
  }

  Future<void> openPdfFromBase64(String base64String) async {
    final decodedBytes = base64Decode(base64String);
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/temp.pdf';
    final file = File(filePath);
    await file.writeAsBytes(decodedBytes);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(filePath: filePath),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getCourseData();
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
            Text("Previous Notes",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900])),
            Divider(color: Colors.blue[900]),
            ...NotesData.map((note) => ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(note["notes_name"] ?? "Unnamed Note"),
              subtitle: Text("Uploaded on: ${note["date"]}"),
              trailing: IconButton(
                icon: Icon(Icons.download, color: Colors.green),
                onPressed: () {
                  String base64Pdf = note['fileBase64'];
                  openPdfFromBase64(base64Pdf);
                },
              ),
            ))
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Note's ",
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(75.0),
          child: AppBar(
            title: Text(
              "Note's",
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext) => StudentDashboard()));
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
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                height: 50,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(color: Colors.blue[700]),
              ),
              Container(
                height: 800,
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40))),
                padding: EdgeInsets.all(1),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        if (isLoading)
                          Center(child: CircularProgressIndicator())
                        else ...[
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 5,
                                  margin: EdgeInsets.only(right: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        contentPadding:
                                        EdgeInsets.symmetric(vertical: 5),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      value: selectItem,
                                      hint: Text("Select Course"),
                                      items: CourseData.map((e) {
                                        return DropdownMenuItem<String>(
                                          child: Text(e['coursename']),
                                          value: e['courseid'],
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectItem = newValue;
                                          getSubjectData();
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a course';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  elevation: 5,
                                  margin: EdgeInsets.only(left: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value: selectSubject,
                                      hint: Text("Select Subject"),
                                      items: SubjectData.isEmpty
                                          ? []
                                          : SubjectData.map((e) {
                                        return DropdownMenuItem<String>(
                                          child: Text(e['subjectname']),
                                          value: e['subjectid'],
                                        );
                                      }).toList(),
                                      onChanged: SubjectData.isEmpty
                                          ? null
                                          : (newValue) {
                                        setState(() {
                                          selectSubject = newValue;
                                          getNotes();
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a subject';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          _buildNotesList(),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String filePath;

  PDFViewerScreen({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        backgroundColor: Colors.blue[700],
      ),
      body: Center(
        child: PDFView(
          filePath: filePath,
        ),
      ),
    );
  }
}
