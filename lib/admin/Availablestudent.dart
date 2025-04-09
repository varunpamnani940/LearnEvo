import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'dashboard_admin.dart';
import 'EditStudent.dart';
import '../login.dart';

class Availablestudent extends StatefulWidget {
  @override
  State<Availablestudent> createState() => AvailablestudentState();
}

class AvailablestudentState extends State<Availablestudent> {
  List student = [];
  List<Map<String, dynamic>> CourseData = [];
  List<String> courseNames = [];
  List filteredStudents = [];
  String selectedCourse = 'All Courses';
  String selectedYear = 'All Years';
  String selectedDepartment = 'All Departments';
  String searchQuery = '';
  bool isLoading = true; // ✅ Add Loading State
  void showEditStudentDialog(int index) {
    TextEditingController nameController = TextEditingController(text: filteredStudents[index]["studentname"]);
    TextEditingController emailController = TextEditingController(text: filteredStudents[index]["email"]);
    TextEditingController phoneController = TextEditingController(text: filteredStudents[index]["phonenumber"]);
    TextEditingController parentPhoneController = TextEditingController(text: filteredStudents[index]["Parentphonenumber"]);

    File? _imageFile;
    final ImagePicker _picker = ImagePicker();

    Future<void> pickImage() async {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }

    TextEditingController cardid = TextEditingController(text: filteredStudents[index]["carduid"]);
    String Card_uid = "";
    List card = [];
    Future<void> getcard() async {
      String uri = "http://$ipAddress/flutter/studentcard.php";
      var res = await http.post(Uri.parse(uri));
      var result = jsonDecode(res.body);

      setState(() {
        card = result;
        if (card.isNotEmpty) {
          Card_uid = card[0];
          cardid.text = Card_uid;
        }
      });
    }

    Future<void> updateStudent() async {
      String uri = "http://$ipAddress/flutter/update_student.php";

      String? base64Image;
      if (_imageFile != null) {
        List<int> imageBytes = await _imageFile!.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      var response = await http.post(Uri.parse(uri), body: {
        'studentid': filteredStudents[index]['studentid'],
        'studentname': nameController.text,
        'email': emailController.text,
        'phonenumber': phoneController.text,
        'Parentphonenumber': parentPhoneController.text,
        'studimage': base64Image ?? '',
        "carduid":cardid.text// send empty string if no image selected
      });
      print(response.body);

      if (response.statusCode == 200) {
        // Navigator.pop(context);
        getstudentdata(); // Refresh UI
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Student updated successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed')));
      }
    }


    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Edit Student"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await pickImage();
                      setState(() {}); // Refresh image preview
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : NetworkImage("http://$ipAddress/flutter/studentimage/${filteredStudents[index]["studentid"]}.jpg") as ImageProvider,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(Icons.edit, size: 20),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Student Name"),
                  ),
                  TextFormField(
                    controller: cardid,
                    readOnly: true,
                    onTap: () async {
                      await getcard(); // fetch and assign card
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.credit_card, color: Colors.blue),
                      hintText: "Tap to fetch card UID",
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Email"),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: "Phone Number"),
                  ),
                  TextField(
                    controller: parentPhoneController,
                    decoration: InputDecoration(labelText: "Parent Phone Number"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await updateStudent();
                  Navigator.pop(context);
                },
                child: Text("Save"),
              ),
            ],
          );
        });
      },
    );
  }


  Future<void> getData() async {
    try {
      String uri = "http://$ipAddress/flutter/viewcourse.php";
      var res = await http.post(Uri.parse(uri), body: {});
      setState(() {
        CourseData = jsonDecode(res.body).cast<Map<String, dynamic>>();
        // Add 'All Courses' option to the beginning of the list
        courseNames = ['All Courses'] + CourseData.map((course) => course['coursename'] as String).toList();
        print(CourseData);
        print(courseNames);
        setState(() {
          isLoading = false; // Even on error, remove loading state
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> getstudentdata() async {
    String uri = "http://$ipAddress/flutter/getallstudentdata.php";
    var res = await http.post(Uri.parse(uri), body: {});
    setState(() {
      student = jsonDecode(res.body);
      filteredStudents = student; // Initialize filteredStudents with all students
      print(student);
    });
  }

  void filterStudents() {
    setState(() {
      filteredStudents = student.where((s) {
        final matchesCourse = selectedCourse == 'All Courses' || s['coursename'] == selectedCourse;
        final matchesYear = selectedYear == 'All Years' || s['year'] == selectedYear;
        final matchesDepartment = selectedDepartment == 'All Departments' || s['department'] == selectedDepartment;
        final matchesSearchQuery = searchQuery.isEmpty || s['studentname'].toLowerCase().contains(searchQuery.toLowerCase());
        return matchesCourse && matchesYear && matchesDepartment && matchesSearchQuery;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getstudentdata();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Available Students",
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            title: Text(
              "Available Students",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: Colors.blue[700],
            leading: Container(
              child: Material(
                color: Colors.blue[700],
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context, MaterialPageRoute(builder: (context) => admin_dashboard()));
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
        body: isLoading // ✅ Show Loading Indicator
            ? Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ) : SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                height: 100,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(color: Colors.blue[700]),
              ),
              Container(
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80),
                    topRight: Radius.circular(80),
                  ),
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                            filterStudents();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by student name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    // DropDown Buttons in a Row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedCourse,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedCourse = newValue!;
                                  filterStudents();
                                });
                              },
                              underline: SizedBox(),
                              items: courseNames.map<DropdownMenuItem<String>>((courseName) {
                                return DropdownMenuItem<String>(
                                  value: courseName,
                                  child: Text(courseName),
                                );
                              }).toList(),
                              isExpanded: true,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedYear,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedYear = newValue!;
                                  filterStudents();
                                });
                              },
                              underline: SizedBox(),
                              items: <String>['All Years', '2021', '2022', '2023', '2024']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              isExpanded: true,
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                    // Student List
                    ListView.builder(
                      padding: EdgeInsets.all(0),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        String studentId = filteredStudents[index]["studentid"]; // Extract student ID
                        String imageUrl = "http://$ipAddress/flutter/studentimage/$studentId.jpg"; // Construct URL
                        return Padding(
                          padding: EdgeInsets.all(5.0),
                          child: ListTile(
                            tileColor: Colors.white,
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[300], // Placeholder background color
                              child: ClipOval(
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/images/loading_2.gif', // Local loading animation
                                  image: "http://$ipAddress/flutter/studentimage/${filteredStudents[index]["studentid"]}.jpg",
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                  imageErrorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.person, size: 40, color: Colors.grey); // Default icon on error
                                  },
                                ),
                              ),
                            ),
                            // trailing: Material(
                            //   child: InkWell(
                            //     child: Icon(Icons.message_outlined),
                            //     onTap: () {
                            //
                            //     },
                            //   ),
                            // ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    showEditStudentDialog(index);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.message, color: Colors.blue),
                                  onPressed: () {
                                    showStudentDialog(index);
                                  },
                                ),
                              ],
                            ),
                            title: Text(
                              filteredStudents[index]["studentname"],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(filteredStudents[index]["coursename"]),
                            onTap: () {
                              // Implement onTap action
                            },
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void showStudentDialog(index) {
    TextEditingController messageController = TextEditingController();
    Future<void> send_email () async{
      String uri = "http://51.20.10.147/flutter/Sendmsg_to_student.php";
      var res = await http.post(Uri.parse(uri),
      body: {
        "student_id":filteredStudents[index]["studentname"],
        "course_name":filteredStudents[index]["coursename"],
        "message":messageController.text,
        "email":filteredStudents[index]["email"]
      });

    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Student Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[300], // Placeholder background color
                child: ClipOval(
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/loading_2.gif', // Local loading animation
                    image: "http://$ipAddress/flutter/studentimage/${filteredStudents[index]["studentid"]}.jpg",
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: 40, color: Colors.grey); // Default icon on error
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text("Name: ${filteredStudents[index]['studentname']}", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Course: ${filteredStudents[index]['coursename']}"),
              SizedBox(height: 10),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: "Enter your message",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Implement sending message logic here
                await send_email();
                Navigator.pop(context);
              },
              child: Text("Send"),
            ),
          ],
        );
      },
    );
  }


}
