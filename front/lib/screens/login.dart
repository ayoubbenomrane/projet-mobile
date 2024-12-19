import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding
import 'welcome.dart'; // Import the WelcomeScreen file

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; // Loading indicator
  String? _errorMessage; // Error message

  // Function to handle login using form-data
  Future<void> _handleLogin() async {
    final String apiUrl = 'https://wassalni-maak.onrender.com/user/login';
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create form-data request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['username'] = email; // Send email as username
      request.fields['password'] = password;

      print('Request Fields: ${request.fields}'); // Debug form-data payload

      // Send the request
      final response = await request.send();

      // Convert response to a readable format
      final responseBody = await http.Response.fromStream(response);

      print('Response Status: ${response.statusCode}'); // Debug status
      print('Response Body: ${responseBody.body}'); // Debug response body

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody.body);
        print('Response Data: $data'); // Debug full response

        // Define the token locally here
        final String? token = data['access_token'];

        if (token != null) {
          // Navigate to the WelcomeScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomeScreen(token: token), // Pass token
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Login succeeded but access token is missing.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
      print('Error: $e'); // Debug error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
  title: Center( // Added title property
    child: Text(
      'Login',
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email Input Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Password Input Field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Error Message Display
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 16),

            // Log In Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Log In',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
