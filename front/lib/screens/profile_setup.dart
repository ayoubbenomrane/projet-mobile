import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'welcome.dart'; // Import the WelcomeScreen

class ProfileSetupScreen extends StatefulWidget {
  final Map<String, String>? userData;

  ProfileSetupScreen({required this.userData});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _birthdateController = TextEditingController();

  XFile? profileAvatarImage;
  String? _firstName;
  String? _lastName;
  String? _phoneNumber;
  String? _birthDay;
  String? _profilePicture;
  String? _gender;

  // Image Picker to select profile picture
  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        profileAvatarImage = image;
        _profilePicture = base64Encode(bytes);
      });
    }
  }

  // Combine user data and send POST request
  Future<void> _saveProfileData() async {
    // Merge signup data and profile details
    final Map<String, dynamic> data = {
      ...?widget.userData,
      'firstName': _firstName ?? '',
      'lastName': _lastName ?? '',
      'phoneNumber': _phoneNumber ?? '',
      'birthDay': _birthDay ?? '',
      'gender': _gender ?? '',
      'profilePicture': _profilePicture ?? '',
    };

    final url = Uri.parse('https://wassalni-maak.onrender.com/user/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response body to extract token
        final responseBody = jsonDecode(response.body);
        final String token = responseBody['token'] ?? '';

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );

        // Navigate to WelcomeScreen and pass the token
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyApp(),
          ),
        );
      } else {
        _showError(
            'Failed to save profile. Status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Exception: $e");
      _showError('An error occurred. Please check your connection.');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.redAccent),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          // Added title property
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Optional: Set color for better visibility
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: profileAvatarImage != null
                        ? FileImage(File(profileAvatarImage!.path))
                        : null,
                    child: profileAvatarImage == null
                        ? const Icon(Icons.add_a_photo,
                            size: 30, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'First Name'),
                  onChanged: (value) => _firstName = value,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  onChanged: (value) => _lastName = value,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _birthdateController,
                  decoration: const InputDecoration(
                    labelText: 'Birthdate',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _birthDay = DateFormat('yyyy-MM-dd').format(pickedDate);
                        _birthdateController.text = _birthDay!;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (value) => _gender = value,
                  validator: (value) =>
                      value == null ? 'Please select your gender' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => _phoneNumber = value,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveProfileData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 16),
                  ),
                  child: const Text(
                    'Save Profile',
                    style: TextStyle(color: Colors.white),
                    
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
