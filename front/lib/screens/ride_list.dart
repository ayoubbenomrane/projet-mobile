import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ride_detail.dart';
import 'package:intl/intl.dart';

// RideCard Widget
class RideCard extends StatelessWidget {
  final String timeStart;
  final String departure;
  final String destination;
  final String price;
  final String driverName;
  final String? driverProfilePicture;
  final int totalSeats;
  final int seatsAvailable;
  final Function() onTap;

  const RideCard({
    super.key,
    required this.timeStart,
    required this.departure,
    required this.destination,
    required this.price,
    required this.driverName,
    
    this.driverProfilePicture,
    this.totalSeats = 4,
    required this.seatsAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time and Price
              Row(
                children: [
                  Text(
                    timeStart,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Departure and Destination
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    departure,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    destination,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Seats Available
              Row(
                children: [
                  for (int i = 1; i <= totalSeats; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Icon(
                        Icons.airline_seat_recline_normal,
                        size: 20,
                        color: i <= seatsAvailable ? Colors.red : Colors.grey,
                      ),
                    ),
                ],
              ),
              const Divider(height: 20, thickness: 1),
              // Driver Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: driverProfilePicture != null
                        ? MemoryImage(base64Decode(driverProfilePicture!))
                        : const AssetImage('assets/placeholder.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    driverName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// RideListPage Widget
class RideListPage extends StatefulWidget {
  final String departure;
  final String destination;
  final int? seats;
  final DateTime? date;
  final String token; // Token parameter

  const RideListPage({
    super.key,
    required this.departure,
    required this.destination,
    this.seats,
    this.date,
    required this.token,
  });

  @override
  _RideListPageState createState() => _RideListPageState();
}

class _RideListPageState extends State<RideListPage> {
  List<dynamic> rides = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCarpools();
  }

  // Fetch rides and driver details
  Future<void> fetchCarpools() async {
    final String url = 'https://wassalni-maak.onrender.com/carpool?'
        'departure=${widget.departure}&destination=${widget.destination}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> carpoolData =
            json.decode(response.body)['carpools'];

        // Fetch driver details for each ride
        for (var ride in carpoolData) {
          final driverResponse = await http.get(
            Uri.parse(
                'https://wassalni-maak.onrender.com/user/${ride['owner_id']}'),
            headers: {'Authorization': 'Bearer ${widget.token}'},
          );

          if (driverResponse.statusCode == 200) {
            ride['driver'] = json.decode(driverResponse.body);
          }
        }

        setState(() {
          rides = carpoolData;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load rides');
      }
    } catch (e) {
      print("Error fetching rides: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load rides. Please try again.')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text('${widget.departure} to ${widget.destination}'),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: rides.length,
              itemBuilder: (context, index) {
                final ride = rides[index];
                final driver = ride['driver'] ?? {};
                return RideCard(
                  timeStart: formatDate(ride['time']),
                  departure: ride['departure'] ?? '',
                  destination: ride['destination'] ?? '',
                  price: '${ride['price'] ?? 0} DT/Person',
                  driverName:
                      '${driver['firstName'] ?? 'Unknown'} ${driver['lastName'] ?? ''}',
                  driverProfilePicture: driver['profilePicture'],
                  seatsAvailable: ride['seats_available'] ?? 0,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RideDetail(
                          rideId: ride['id'],
                          token: widget.token,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // Format date and time
  String formatDate(String dateTime) {
    if (dateTime.isEmpty) return "Unknown Time";
    final DateTime parsedDate = DateTime.parse(dateTime);
    return "${DateFormat('MMM dd, yyyy').format(parsedDate)} - ${DateFormat('hh:mm a').format(parsedDate)}";
  }
}
