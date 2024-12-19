import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedbackScreen extends StatefulWidget {
  final String token; // Token parameter
  final int driverId; // Driver ID parameter

  const FeedbackScreen(
      {super.key, required this.token, required this.driverId});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0; // Initial rating value

  bool _isSubmitting = false; // To show loading spinner

  /// Post feedback to the server
  Future<void> submitFeedback() async {
    if (_rating == 0) {
      _showError("Please provide a rating.");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final url = Uri.parse("https://wassalni-maak.onrender.com/feedback");
    final feedbackData = {
      "rating": _rating,
      "comment": _commentController.text.trim(),
      "receiver_id": widget.driverId, // Driver ID as receiver
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(feedbackData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccess();
      } else {
        _showError("Failed to submit feedback. Try again.");
      }
    } catch (e) {
      _showError("An error occurred: $e");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// Show success message
  void _showSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Your feedback has been submitted successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to previous screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error message
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Rate Your Ride"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rate the Driver",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color:Colors.black),
            ),
            SizedBox(height: 16),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = index + 1; // Set rating 1-5
                    });
                  },
                  icon: Icon(
                    Icons.star,
                    color: index < _rating ? Colors.orange : Colors.grey,
                    size: 30,
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Write a Comment",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Submit Feedback",
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
