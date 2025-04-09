import 'package:flutter/material.dart';

class AdminPermissionPage extends StatefulWidget {
  @override
  _AdminPermissionPageState createState() => _AdminPermissionPageState();
}

class _AdminPermissionPageState extends State<AdminPermissionPage> {
  List<Map<String, dynamic>> teachers = [
    {'name': 'John Doe', 'profile': 'assets/profile1.png', 'permissions': [true, false, true, false, true, false, false]},
    {'name': 'Jane Smith', 'profile': 'assets/profile2.png', 'permissions': [false, true, false, true, false, true, true]},
  ];

  List<String> permissionLabels = ['View', 'Edit', 'Delete', 'Manage Courses', 'Manage Attendance', 'Manage Fees', 'Device Manager'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Teacher Permissions')),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search Teacher...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: teachers.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(teachers[index]['profile']),
                            ),
                            title: Text(teachers[index]['name']),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(permissionLabels.length, (i) {
                                return Row(
                                  children: [
                                    Text(permissionLabels[i]),
                                    Switch(
                                      value: teachers[index]['permissions'][i],
                                      onChanged: (val) {
                                        setState(() {
                                          teachers[index]['permissions'][i] = val;
                                        });
                                      },
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Save permissions logic here
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AdminPermissionPage(),
  ));
}