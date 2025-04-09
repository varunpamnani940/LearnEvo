import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_admin.dart';
import '../login.dart';

class Inquiry extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return InquiryState();
  }
}

class InquiryState extends State<Inquiry> {
  final _formKey = GlobalKey<FormState>();
  String? selectCourseId;
  List courseData = [];
  List inquiries = [];
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  bool isLoading = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchCourses();
    fetchInquiries();
  }

  Future<void> fetchCourses() async {
    setState(() => isLoading = true);
    String uri = "http://$ipAddress/flutter/viewcourse.php";
    var res = await http.post(Uri.parse(uri));
    setState(() {
      courseData = jsonDecode(res.body);
      isLoading = false;
    });
  }

  Future<void> fetchInquiries() async {
    setState(() => isLoading = true);
    String uri = "http://$ipAddress/flutter/view_inquiry.php";
    var res = await http.get(Uri.parse(uri));
    setState(() {
      inquiries = jsonDecode(res.body);
      isLoading = false;
    });
  }

  Future<void> uploadInquiry() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => isSubmitting = true);
      String uri = "http://$ipAddress/flutter/inquiry.php";
      var res = await http.post(Uri.parse(uri), body: {
        "courseid": selectCourseId,
        "studentName": studentNameController.text,
        "phonenumber": phoneNumberController.text,
      });
      setState(() => isSubmitting = false);
      if (jsonDecode(res.body)["inserted"] == "true") {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Inquiry Added")));
        _formKey.currentState?.reset();
        setState(() => selectCourseId = null);
        fetchInquiries(); // Refresh inquiries after adding
      }
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
            Text("Add Inquiry", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
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
            Text("New Inquiry", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            Divider(color: Colors.blue[900]),
            _buildInquiryForm(),
            SizedBox(height: 20),
            Text("Existing Inquiries", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            Divider(color: Colors.blue[900]),
            _buildInquiryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInquiryForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCourseDropdown(),
              _buildTextField("Student Name", Icons.person, studentNameController),
              _buildTextField("Phone Number", Icons.phone, phoneNumberController, isNumeric: true),
              SizedBox(height: 10),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
  List<String> followUpOptions = ["Pending", "Completed", "In Progress"];
  void _showEditDialog(Map<String, dynamic> inquiry, int index) {
    TextEditingController nameController =
    TextEditingController(text: inquiry["studentname"]);
    TextEditingController phoneController =
    TextEditingController(text: inquiry["phonenum"]);
    TextEditingController courseController =
    TextEditingController(text: inquiry["courseid"]);

    List<String> followUpOptions = ["Pending", "Completed", "In Progress"];
    String selectedFollowUp = followUpOptions.contains(inquiry["followup"])
        ? inquiry["followup"]
        : followUpOptions.first; // Default to the first item if null or invalid

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Inquiry"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Student Name"),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedFollowUp, // This ensures a valid value is selected
                decoration: InputDecoration(labelText: "Follow-Up Status"),
                items: followUpOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFollowUp = value!;
                  });
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
              onPressed: () {
                setState(() {

                   update_list(  inquiries[index]['inquiryid'].toString(),nameController.text, phoneController.text , selectedFollowUp );


                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
  Future<void> update_list(String index,String name,String phone , String folow ) async {
    setState(() => isLoading = true);
    String uri = "http://$ipAddress/flutter/edit_inquiry.php";
    var res = await http.post(Uri.parse(uri), body: {
      "id": index,
      "name": name,
      "phonenumber": phone,
      "followup" : folow

    });
    print(res.body);
    print(index);
    jsonDecode(res.body);
    if(jsonDecode(res.body)['updated']=="true"){
      int listIndex = inquiries.indexWhere((inquiry) => inquiry["inquiryid"].toString() == index);
      if (listIndex != -1) {
        // ✅ Update the correct item in the list
        inquiries[listIndex]["studentname"] = name;
        inquiries[listIndex]["phonenum"] = phone;
        inquiries[listIndex]["followup"] = folow;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Inquiry Updated")));
    }
    setState(()   {
      fetchCourses();
      isLoading = false;
    });
  }
  Widget _buildInquiryList() {
    return inquiries.isEmpty
        ? Center(child: Text("No inquiries found."))
        : ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: inquiries.length,
      itemBuilder: (context, index) {
        var inquiry = inquiries[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            title: Text(inquiry["studentname"] ?? "Unknown"),
            subtitle: Text("Phone: ${inquiry["phonenum"]}\nCourse ID: ${inquiry["courseid"]}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                     _showEditDialog(inquiry, index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteDialog(inquiry["inquiryid"].toString(), index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> _deleteInquiry(String inquiryId, int index) async {
    String uri = "http://$ipAddress/flutter/delete_inquiry.php";
    var res = await http.post(Uri.parse(uri), body: {"id": inquiryId});

    print("Deleted Inquiry ID: $inquiryId");
    print("Deleted Inquiry ID: $index");
    print("API Response: ${res.body}");
    var resp = jsonDecode(res.body);
    if (res.statusCode == 200 && resp['deleted'] == 'true' ) {
      setState(() {
        inquiries.removeAt(index); // ✅ Remove from list
      });

      // ✅ Show Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Inquiry deleted successfully!"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      print("Error deleting inquiry");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete inquiry. Try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  void _showDeleteDialog(String inquiryId, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Inquiry"),
          content: Text("Are you sure you want to delete this inquiry?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _deleteInquiry(inquiryId, index);
              },
              child: Text("Delete"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue.shade400)),
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
        validator: (value) => value!.isEmpty ? 'Please enter $hint' : null,
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return DropdownButtonFormField(
      value: selectCourseId,
      hint: Text("Select Course"),
      items: courseData.map((course) {
        return DropdownMenuItem(
          value: course["courseid"],
          child: Text(course["coursename"]),
        );
      }).toList(),
      onChanged: (value) => setState(() => selectCourseId = value.toString()),
      validator: (value) => value == null ? 'Please select a course' : null,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: isSubmitting ? null : uploadInquiry,
      child: isSubmitting ? CircularProgressIndicator(color: Colors.white) : Text(" Inquiry"),
    );
  }
}
