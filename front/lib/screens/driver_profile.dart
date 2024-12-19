import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DriverProfilePage extends StatefulWidget {
  final int driverId; // Driver ID passed dynamically

  DriverProfilePage({required this.driverId});

  @override
  _DriverProfilePageState createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  String driverName = "Loading...";
  String phoneNumber = "N/A";
  Uint8List? profilePicture;
  double rating = 0.0;
  int evaluations = 0;
  List<dynamic> feedbacks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("Driver ID: ${widget.driverId}");
    fetchDriver();
    fetchFeedbacks();
  }

  /// Fetch driver details
  Future<void> fetchDriver() async {
    final url = "https://wassalni-maak.onrender.com/user/${widget.driverId}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Driver Data: $data");
        setState(() {
          driverName =
              "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
          phoneNumber = data['phoneNumber'] ?? "N/A";
          final base64Image = data['profilePicture'] ?? "";
          profilePicture = base64Image.isNotEmpty
              ? base64Decode(base64Image)
              : null; // Decode image safely
          rating = double.tryParse(data['rating'].toString()) ?? 0.0;
          evaluations = data['evaluations'] ?? 0;
        });
      } else {
        print(
            "Failed to load driver data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching driver data: $e");
    }
  }

  /// Fetch driver feedbacks
  Future<void> fetchFeedbacks() async {
    final feedbackUrl =
        "https://wassalni-maak.onrender.com/feedback/${widget.driverId}";
    try {
      final response = await http.get(Uri.parse(feedbackUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Feedback Data: $data");
        setState(() {
          feedbacks = data['feedbacks'] ?? [];
          isLoading = false; // Stop the loading spinner
        });
      } else {
        print("Failed to load feedbacks. Status code: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching feedbacks: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Driver Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Top Section with Profile Info
          Container(
            color: Colors.red,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: profilePicture != null
                      ? CircleAvatar(
                          radius: 48,
                          backgroundImage: MemoryImage(profilePicture!),
                        )
                      : CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.grey,
                          child:
                              Icon(Icons.person, size: 48, color: Colors.white),
                        ),
                ),
                SizedBox(height: 10),
                // Driver Name
                Text(
                  driverName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                // Ratings and Phone Number
                Text(
                  '⭐ $rating / 5 - $evaluations Ratings',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Phone number: $phoneNumber',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Feedbacks Section
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator()) // Show loader
                : feedbacks.isEmpty
                    ? Center(
                        child: Text(
                          "No feedbacks available",
                          style: TextStyle(color: Colors.grey, fontSize: 16.0),
                        ),
                      )
                    : ListView.builder(
                        itemCount: feedbacks.length,
                        itemBuilder: (context, index) {
                          final feedback = feedbacks[index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              leading: Icon(Icons.comment, color: Colors.red),
                              title: Text(
                                "Feedback ID: ${feedback['id']}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Rating: ${feedback['rating']} ⭐"),
                                  SizedBox(height: 4),
                                  Text(feedback['comment'] ?? "No comment"),
                                  SizedBox(height: 4),
                                  Text(
                                    "Date: ${feedback['created_at']}",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
