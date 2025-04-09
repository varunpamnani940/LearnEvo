import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../login.dart';
import 'dashboard_admin.dart';
import 'package:http/http.dart' as http;

class DeviceManager extends StatefulWidget {
  const DeviceManager({super.key});

  @override
  State<DeviceManager> createState() => _DeviceManagerState();
}

class _DeviceManagerState extends State<DeviceManager> {
  TextEditingController deviceNameController = TextEditingController();
  String deviceToken = "";
  String? selectedMode;
  List<Map<String, dynamic>> list_device = [];

  @override
  void initState() {
    super.initState();
    generateDeviceToken();
    fetch_device();
  }

  void generateDeviceToken() {
    const String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    final Random rnd = Random();
    setState(() {
      deviceToken = String.fromCharCodes(
        Iterable.generate(10, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
      );
    });
  }
  Future<void> fetch_device() async {
    String uri = "http://$ipAddress/flutter/list_device.php";
    var res = await http.get(Uri.parse(uri));

    if (res.statusCode == 200) {
      setState(() {
        list_device = List<Map<String, dynamic>>.from(json.decode(res.body));
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
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAppBar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Container(
        color: Colors.blue[700],
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 10),
            Text(
              "Device Manager",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
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
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add a New Device", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            Divider(color: Colors.blue[900]),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField("Device Name", Icons.devices, deviceNameController),
                    _buildTokenField(),
                    _buildModeDropdown(),
                    SizedBox(height: 10),
                    _buildSubmitButton(),

                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildPreviousdevice()
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue.shade400)),
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  Widget _buildTokenField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue.shade400)),
          hintText: "Device Token",
          prefixIcon: Icon(Icons.vpn_key),
          suffixIcon: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: generateDeviceToken,
          ),
        ),
        controller: TextEditingController(text: deviceToken),
      ),
    );
  }
  Future<void> deleteDevice(String deviceId) async {
    String uri = "http://$ipAddress/flutter/delete_device.php";

    var res = await http.post(
      Uri.parse(uri),
      body: {"device_id": deviceId},
    );
    print(res.body);

    if (res.statusCode == 200) {
      var response = json.decode(res.body);
      if (response["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Device deleted successfully")));
        fetch_device(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete device")));
      }
    }
  }
  Future<void> editDevice(String deviceId, String name, String token, String mode) async {
    String uri = "http://$ipAddress/flutter/edit_device.php";

    var res = await http.post(
      Uri.parse(uri),
      body: {
        "device_id": deviceId,
        "device_mode": mode,
      },
    );

    if (res.statusCode == 200) {
      var response = json.decode(res.body);
      if (response["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response["message"])));
        fetch_device(); // Refresh device list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response["message"])));
      }
    }
  }



  Widget _buildModeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedMode,
      hint: Text("Select Device Mode"),
      items: ["Attendance", "Register"].map((mode) {
        return DropdownMenuItem(
          value: mode,
          child: Text(mode),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedMode = value;
        });
      },
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue.shade400)),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (deviceNameController.text.isEmpty || selectedMode == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please fill all fields")),
          );
        } else {
          insertDevice( deviceNameController.text,  deviceToken,  selectedMode!);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text("Device Added Successfully")),
          // );

        }
      },
      child: Text("Add Device"),
    );
  }
  void showDeleteDialog(String deviceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Device"),
        content: Text("Are you sure you want to delete this device?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              deleteDevice(deviceId);
              Navigator.pop(context); // Close dialog after deletion
            },
            child: Text("Delete", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> insertDevice(String name, String type, String status) async {
    final url = Uri.parse("http://$ipAddress/flutter/device_add.php");

    try {
      final response = await http.post(
        url,
        body: {
          "name": name,
          "key": type,
          "mode": status,
        },
      );
      print(response.body);
      final result = jsonDecode(response.body);
      if (result["recordInserted"] == "true") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Device deleted successfully")));
        await fetch_device();
        print(" ${result["message"]}");
      } else {
        print(" Error: ${result["message"]}");
      }
    } catch (e) {
      print(" Request failed: $e");
    }
  }
  void _confirmDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Subject"),
        content: Text("Are you sure you want to delete this  Device all the automatic system associated to this device will stop working and you need contact Admin For Setting  up  new Device"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              deleteDevice(id);
              Navigator.pop(context);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }


  void showEditDialog(Map<String, dynamic> device) {
    TextEditingController editController = TextEditingController(text: device['devicename']);
    String editMode = device['devicemode'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Device"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              DropdownButtonFormField<String>(
                value: (editMode != null && ["Attendance", "Register"].contains(editMode)) ? editMode : "Attendance", // Default to "Attendance"
                decoration: InputDecoration(
                  labelText: "Device Mode",
                  border: OutlineInputBorder(),
                ),
                items: ["Attendance", "Register"].map((String mode) {
                  return DropdownMenuItem<String>(
                    value: mode,
                    child: Text(mode),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      editMode = newValue;
                      print(editMode);
                    });
                  }
                },
              ),

            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String uri = "http://$ipAddress/flutter/edit_device.php";
               var res =  await http.post(Uri.parse(uri), body: {
                  "id": device['deviceid'],
                  "devicemode": editMode,
                });
               print(res.body);
                if (res.statusCode == 200) {
                  var response = json.decode(res.body);
                  if (response["status"] == "success") {

                   await fetch_device();
                   Navigator.pop(context);// Refresh device list
                  } else {

                  }
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

Widget _buildPreviousdevice() {
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.blue[50],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Previous Exams",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.blue[900],
          ),
        ),
        Divider(color: Colors.blue[900]),
        list_device.isEmpty
            ? Center(child: Text("No exams added yet", style: TextStyle(fontSize: 14)))
            : ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(), // Prevents double scrolling issue
          itemCount: list_device.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(
                  list_device[index]["device_name"] ?? "",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  "Device Token: ${list_device[index]["devicetoekn"]}  |  "
                      "Mode: ${list_device[index]["devicemode"] == '0' ? 'Register Mode' : 'Attendance Mode'}",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => showEditDialog(list_device[index]),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        var deviceId = list_device[index]["deviceid"];
                        print(deviceId);

                        if (deviceId == null) {
                          print("Error: Device ID is null for index $index");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: Device ID not found")),
                          );
                          return;
                        }

                        _confirmDeleteDialog(deviceId.toString());
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
}
