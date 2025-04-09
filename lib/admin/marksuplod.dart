import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
void  main()
{
  runApp(marksuplod());
}
class marksuplod extends StatefulWidget {
  @override
  State<marksuplod> createState() => _marksuplodState();
}

class _marksuplodState extends State<marksuplod> {
  String? selectedClass;
  String? selectedSubject;

  // Sample data for dropdowns
  final List<String> classes = ['Class 1', 'Class 2', 'Class 3'];
  final List<String> subjects = ['Math', 'Science', 'English'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Profile",
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            title: Text(
              "Profile",
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
                    // Handle back action
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
                height: 100,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(color: Colors.blue[700]),
              ),
              Container(
                height: 700,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80),
                    topRight: Radius.circular(80),
                  ),
                ),
                padding: EdgeInsets.all(50),
                child: Column(
                  children: [
                    // Dropdowns for Class and Subject
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedClass,
                              hint: Text('Select Class'),
                              isExpanded: true,
                              items: classes.map((className) {
                                return DropdownMenuItem<String>(
                                  value: className,
                                  child: Text(className),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedClass = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedSubject,
                              hint: Text('Select Subject'),
                              isExpanded: true,
                              items: subjects.map((subjectName) {
                                return DropdownMenuItem<String>(
                                  value: subjectName,
                                  child: Text(subjectName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedSubject = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                        icon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        icon: Icon(Icons.email_outlined),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Branch',
                        icon: Icon(Icons.account_tree_outlined),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        icon: Icon(Icons.phone_android_sharp),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Role',
                        icon: Icon(Icons.perm_contact_cal_outlined),
                      ),
                    ),
                    SizedBox(height: 10),
                    Theme(
                      data: ThemeData().copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        trailing: Icon(Icons.man_2, color: Colors.transparent),
                        title: Text('Update Password'),
                        leading: Icon(Icons.password),
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(0.01),
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Old Password',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(0.01),
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'New Password',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(0.01),
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Material(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          // Handle profile edit action
                        },
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                            child: Text(
                              "Edit Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
