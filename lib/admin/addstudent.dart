import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../login.dart';
import 'bhulk_student.dart';

class AddStudent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddStudentState();
  }
}

class AddStudentState extends State<AddStudent> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  List collagedata = [];
  List CourseData = [];
  List card = [];
  bool isLoading = true;

  String? SelectedCollage;
  String? SelectedCourse;
  String Card_uid = "";

  TextEditingController name = TextEditingController();
  TextEditingController pno = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController adh = TextEditingController();
  TextEditingController ppno = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController cardid = TextEditingController();
  TextEditingController discount = TextEditingController();

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  Future<void> getcard() async {
    String uri = "http://$ipAddress/flutter/studentcard.php";
    var res = await http.post(Uri.parse(uri));
    setState(() {
      card = jsonDecode(res.body);
      Card_uid = card[0];
      print(Card_uid);
    });
  }

  Future<void> getData() async {
    await Future.wait([
      getcollageid(),
      getcourse(),
      getcard(),
    ]);
    setState(() {
      isLoading = false;
    });
  }



  Future<void> getcollageid() async {
    String uri = "http://$ipAddress/flutter/viewcollage.php";
    var res = await http.post(Uri.parse(uri), body: {});
    setState(() {
      collagedata = jsonDecode(res.body);
    });
  }

  Future<void> getcourse() async {
    String uri = "http://$ipAddress/flutter/viewcourse.php";
    var res = await http.post(Uri.parse(uri), body: {});
    setState(() {
      CourseData = jsonDecode(res.body);
    });
  }

  Future<void> uploadData() async {
   setState(() {
     isLoading = true;
   });
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String? base64Image;
    if (_imageFile != null) {
      base64Image = base64Encode(_imageFile!.readAsBytesSync());
    }

    String uri = "http://$ipAddress/flutter/addstudent.php";
    var res = await http.post(Uri.parse(uri), body: {
      "name": name.text,
      "password": password.text,
      "pnumber": pno.text,
      "email": email.text,
      "collageid": SelectedCollage,
      "adcard": adh.text,
      "ppno": ppno.text,
      "coursename": SelectedCourse,
      "card": cardid.text,
      "image": base64Image,
      "dicsount": discount.text,
    });

    if (res.statusCode == 200) {
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Student added successfully!"),
          backgroundColor: Colors.green,
        ),

      );
     setState(() {
       isLoading = false;
     });

      // Clear the form
      setState(() {
        name.clear();
        password.clear();
        pno.clear();
        email.clear();
        adh.clear();
        ppno.clear();
        discount.clear();
        cardid.clear();
        _imageFile = null;
        SelectedCollage = null;
        SelectedCourse = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add student!"),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }


  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 600;
    if (isLargeScreen) {
      return  BulkUploadScreen();
    }
    return Scaffold(
      backgroundColor: Colors.blue[700],
      appBar: AppBar(
        title: Text("Add Student",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField("Name", Icons.person, name),
                _buildTextField("Phone Number", Icons.phone, pno,
                    isNumeric: true),
                _buildTextField_card("Card", Icons.card_membership_sharp, cardid,
                    isNumeric: true),
                _buildTextField("Email", Icons.email, email),
                _buildDropdownField_c("Select Collage", SelectedCollage,
                    collagedata, (val) {
                      setState(() => SelectedCollage = val);
                    }),
                _buildDropdownField("Select Course", SelectedCourse,
                    CourseData, (val) {
                      setState(() => SelectedCourse = val);
                    }),
                _buildTextField(
                    "Adhar Card Number", Icons.credit_card, adh),
                _buildTextField("Parent's Phone Number", Icons.phone,
                    ppno, isNumeric: true),
                _buildTextField(
                    "Discount", Icons.discount, discount, isNumeric: true),
                _buildImagePicker(),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
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
  Widget _buildTextField_card(String hint, IconData icon,
      TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () {
          setState(() {
            getcard();
            cardid.text = Card_uid;
          });
        },
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(icon, color: Colors.blue),
          hintText: hint,
        ),
      ),
    );
  }


  Widget _buildDropdownField(String hint, String? value, List data,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        hint: Text(hint),
        items: data.map((e) {
          return DropdownMenuItem<String>(
            value: e['courseid'].toString(),
            child: Text(e['coursename'].toString()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownField_c(String hint, String? value, List data,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        hint: Text(hint),
        items: data.map((e) {
          return DropdownMenuItem<String>(
            value: e['collageid'].toString(),
            child: Text(e['collagename'].toString()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        if (_imageFile != null)
          Image.file(_imageFile!, height: 100, width: 100, fit: BoxFit.cover)
        else
          Icon(Icons.image, size: 50, color: Colors.grey),
        TextButton(onPressed: pickImage, child: Text("Upload Image")),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: uploadData,
      child: Text("Add Student"),
    );
  }
}
