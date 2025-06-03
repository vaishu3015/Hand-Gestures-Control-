import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  bool isEditing = false;
  String? imageUrl;
  String phone = "";
  String dob = "";
  String address = "";

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      phone = prefs.getString('phone') ?? "";
      dob = prefs.getString('dob') ?? "";
      address = prefs.getString('address') ?? "";
      imageUrl = prefs.getString('profileImage');
      phoneController.text = phone;
      dobController.text = dob;
      addressController.text = address;
    });
  }

  Future<void> _saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', phoneController.text);
    await prefs.setString('dob', dobController.text);
    await prefs.setString('address', addressController.text);
    if (imageUrl != null) await prefs.setString('profileImage', imageUrl!);

    setState(() {
      phone = phoneController.text;
      dob = dobController.text;
      address = addressController.text;
      isEditing = false;
    });
  }

  void _cancelEditing() {
    setState(() {
      isEditing = false;
      phoneController.text = phone;
      dobController.text = dob;
      addressController.text = address;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageUrl = pickedFile.path;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: Text('Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: imageUrl != null
                        ? FileImage(File(imageUrl!))
                        : AssetImage('assets/default_avatar.png') as ImageProvider,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Personal Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Divider(),
                      _buildInfoRow(Icons.phone, "Phone: $phone"),
                      _buildInfoRow(Icons.calendar_today, "Date of Birth: $dob"),
                      _buildInfoRow(Icons.location_on, "Address: $address"),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (isEditing) ...[
                _buildEditableField(Icons.phone, "Phone", phoneController),
                _buildEditableField(Icons.calendar_today, "Date of Birth", dobController),
                _buildEditableField(Icons.location_on, "Address", addressController),
                SizedBox(height: 20),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isEditing ? _saveProfileData : () {
                      setState(() { isEditing = true; });
                    },
                    child: Text(isEditing ? "Save" : "Edit"),
                  ),
                  SizedBox(width: 10),
                  if (isEditing)
                    ElevatedButton(
                      onPressed: _cancelEditing,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text("Cancel"),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEditableField(IconData icon, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
