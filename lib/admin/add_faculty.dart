import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../login.dart';
import 'dashboard_admin.dart';

class Addfac extends StatefulWidget {
  @override
  _AddfacState createState() => _AddfacState();
}

class _AddfacState extends State<Addfac> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  int? studentm;
  int? teacherm;
  int? feesm;
  String? SelectedCollage;
  String? SelectedCourse;
  TextEditingController name = TextEditingController();
  TextEditingController pno = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController adh = TextEditingController();
  bool _isLoading = false;

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadData() async {

    setState(() {
      _isLoading = true; // Hide progress indicator
    });
    String? base64Image;
    if (_imageFile != null) {
      base64Image = base64Encode(_imageFile!.readAsBytesSync());
    }
    String uri = "http://$ipAddress/flutter/add_teacher.php";

    var res = await http.post(Uri.parse(uri), body: {
      "name": name.text,
      "pnumber": pno.text,
      "email": email.text,
      "student_manage_p": studentm.toString(),
      "fee_manage_p": feesm.toString(),
      "faculty_manage_p": teacherm.toString(),
      "adcard": adh.text,
      "image": base64Image,
    });

    setState(() {
      _isLoading = false; // Hide progress indicator
    });

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Teacher added successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      appBar: AppBar(
        title: Text("Add Teacher",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 30, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                _buildTextField(name, "Full Name", Icons.person),
                _buildTextField(pno, "Phone Number", Icons.phone, keyboardType: TextInputType.phone),
                _buildTextField(email, "Email Address", Icons.email, keyboardType: TextInputType.emailAddress),
                _buildTextField(adh, "Aadhar Card Number", Icons.confirmation_number),

                _buildDropdown("Student Manage Permission", studentm, (val) {
                  setState(() => studentm = val);
                }),
                _buildDropdown("Teacher Manage Permission", teacherm, (val) {
                  setState(() => teacherm = val);
                }),
                _buildDropdown("Fees Manage Permission", feesm, (val) {
                  setState(() => feesm = val);
                }),

                _buildImagePicker(),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : uploadData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Add Teacher", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue[700]),
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
        validator: (value) => value == null || value.isEmpty ? "Please enter $hint" : null,
      ),
    );
  }

  Widget _buildDropdown(String title, int? value, Function(int?) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonFormField<int>(
          value: value,
          hint: Text(title),
          decoration: InputDecoration(border: InputBorder.none),
          isExpanded: true,
          items: [
            DropdownMenuItem(value: 1, child: Text("Allow")),
            DropdownMenuItem(value: 0, child: Text("Deny")),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          GestureDetector(
            onTap: pickImage,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
              ),
              child: _imageFile == null
                  ? Icon(Icons.image, size: 50, color: Colors.grey)
                  : null,
            ),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: pickImage,
            child: Text("Upload Image", style: TextStyle(color: Colors.blue[700], fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
