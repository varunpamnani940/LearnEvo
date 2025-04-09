import 'dart:convert';
import 'dart:io';
import 'package:dreamclass/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class InsertUserPage extends StatefulWidget {
  @override
  _InsertUserPageState createState() => _InsertUserPageState();
}

class _InsertUserPageState extends State<InsertUserPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAdmins();
  }
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool auth = false;
  File? _image;
  String? base64Image;
  bool isLoading = false;



  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        base64Image = base64Encode(_image!.readAsBytesSync());
      });
    }
  }

  Future<void> insertUser() async {
    if (base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an image")),
      );
      return;
    }
    setState(() => isLoading = true);

    String uri = "http://$ipAddress/flutter/add_admin.php";
    var response = await http.post(Uri.parse(uri), body: {
      "image": base64Image!,
      "email": emailController.text,
      "pwd": passwordController.text,
      "name": nameController.text,
      "auth": auth ? "1" : "0",
    });
    await fetchAdmins();

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.statusCode == 200 ? "User inserted successfully!" : "Failed to insert user.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
    return AppBar(
      backgroundColor: Colors.blueAccent,
      elevation: 0,
      title: Text("Insert Admin", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text("New Admin", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                ),
                SizedBox(height: 10),
                _buildImagePicker(),
                _buildTextField("Name", Icons.person, nameController),
                _buildTextField("Email", Icons.email, emailController, TextInputType.emailAddress),
                _buildTextField("Password", Icons.lock, passwordController, TextInputType.text, ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Enable Auth", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    Switch(
                      value: auth,
                      onChanged: (value) => setState(() => auth = value),
                      activeColor: Colors.blueAccent,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Center(child: _buildSubmitButton()),
                SizedBox(height: 20),
                _buildAdminList(),

              ],

            ),
          ),
        ),
      ),
    );
  }
  List admins = [];
  Future<void> fetchAdmins() async {
    String uri = "http://$ipAddress/flutter/list_admin.php";
    var response = await http.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      setState(() {
        admins = json.decode(response.body);
      });
    }
  }

  Widget _buildAdminList() {
    return admins.isEmpty
        ? Center(child: Text("No Admins Available"))
        : ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: admins.length,
      itemBuilder: (context, index) {
        var admin = admins[index];
        String formattedEmail = admin['email'].replaceAll("@gmail.com", "gmail").replaceAll('.', '_');
        String imageUrl = "http://$ipAddress/flutter/admin_image/$formattedEmail.jpg";

        return Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(imageUrl),
              onBackgroundImageError: (_, __) => Icon(Icons.person, size: 40, color: Colors.grey),
            ),
            title: Text(admin['name'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(admin['email']),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => confirmDelete(admin['id']),
            ),
          ),
        );
      },
    );
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Admin"),
          content: Text("Are you sure you want to delete this admin?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                deleteAdmin(id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
  Future<void> deleteAdmin(String id) async {
    String uri = "http://$ipAddress/flutter/delete_admin.php";

    var response = await http.post(Uri.parse(uri), body: {
      "id": id,
    });

    if (response.statusCode == 200) {
     await  fetchAdmins(); // Refresh the admin list
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Admin deleted successfully!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete admin.")));
    }
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _image != null
              ? Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover)
              : Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: pickImage,
          icon: Icon(Icons.image),
          label: Text("Pick Image"),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, [TextInputType keyboardType = TextInputType.text, bool obscureText = false]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[100],
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent), borderRadius: BorderRadius.circular(12)),
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: insertUser,
      child: Text("Insert Admin", style: TextStyle(fontSize: 16)),
    );
  }
}
