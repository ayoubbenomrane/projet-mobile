import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ride_booked.dart'; // Import RideConfirmationPage
import 'driver_profile.dart'; // Import DriverProfilePage

class RideDetail extends StatefulWidget {
  final int rideId;
  final String token;

  RideDetail({required this.rideId, required this.token});

  @override
  _RideDetailPageState createState() => _RideDetailPageState();
}

class _RideDetailPageState extends State<RideDetail> {
  late Map<String, dynamic> ride = {};
  late Map<String, dynamic> driver = {};
  bool isLoading = true;
  Uint8List? driverProfilePicture;

  int? driverId; // Store driver ID to pass later

  @override
  void initState() {
    super.initState();
    print("Ride ID: ${widget.rideId}, Token: ${widget.token}");
    fetchRideDetails();
  }

  /// Fetch ride details
  Future<void> fetchRideDetails() async {
    final url = "https://wassalni-maak.onrender.com/carpool/${widget.rideId}";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          ride = data;
          driverId = data['owner_id']; // Get the driverId from the response
          isLoading = false;
        });
        fetchDriverDetails(driverId!);
      } else {
        print("Failed to load ride details");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching ride details: $e");
      setState(() => isLoading = false);
    }
  }

  /// Fetch driver details
  Future<void> fetchDriverDetails(int driverId) async {
    final url = "https://wassalni-maak.onrender.com/user/$driverId";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          driver = data;
          final base64Image = data['profilePicture'] ?? "";
          driverProfilePicture = base64Image.isNotEmpty
              ? base64Decode(base64Image)
              : null; // Decode image safely
        });
      } else {
        print("Failed to load driver details");
      }
    } catch (e) {
      print("Error fetching driver details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.redAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ride Details Section
            Text(
              formatDate(ride['time'] ?? ""),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total price for 1 passenger',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
                Text(
                  '${ride['price'] ?? 0} DT',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Timeline Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.redAccent,
                    ),
                    Container(
                      width: 2,
                      height: 50,
                      color: Colors.red,
                    ),
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.redAccent,
                    ),
                  ],
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride['departure'] ?? "",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 50),
                    Text(
                      ride['destination'] ?? "",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // Driver Section
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverProfilePage(
                      driverId: driverId!,
                    ),
                  ),
                );
              },
              child: Card(
                margin: EdgeInsets.all(16),
                color: Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: driverProfilePicture != null
                        ? MemoryImage(driverProfilePicture!)
                        : null,
                    child: driverProfilePicture == null
                        ? Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text(
                    "${driver['firstName']} ${driver['lastName']}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                  '${driver['rating'] ?? 0}/5 ratings',
                  style: TextStyle(color: Colors.grey),
                ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                ),
              ),
            ),
            Spacer(),
            

            // Request for Ride Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RideConfirmationPage(
                      token: widget.token,
                      driverId: driverId!, // Pass the driverId
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Request for Ride',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(String dateString) {
    if (dateString.isEmpty) return "Loading...";
    DateTime dateTime = DateTime.parse(dateString);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute}";
  }
}
