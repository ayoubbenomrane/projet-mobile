import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding and decoding
import 'welcome.dart';

class OfferRidePage extends StatefulWidget {
  final String token; // Token parameter added

  const OfferRidePage({super.key, required this.token});

  @override
  State<OfferRidePage> createState() => _OfferRidePageState();
}

class _OfferRidePageState extends State<OfferRidePage> {
  // Variables to store the selected date and time
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Variables to store user inputs
  final TextEditingController priceController = TextEditingController();
  int? selectedPassengers;
  String? selectedDeparture;
  String? selectedDestination;

  // Predefined list of locations
  final List<String> locations = [
    'Tunis',
    'Ariana',
    'Ben Arous',
    'Manouba',
    'Nabeul',
    'Zaghouan',
    'Bizerte',
    'Béja',
    'Jendouba',
    'Kef',
    'Siliana',
    'Sousse',
    'Monastir',
    'Mahdia',
    'Kairouan',
    'Kasserine',
    'Sidi Bouzid',
    'Sfax',
    'Gabès',
    'Medenine',
    'Tataouine',
    'Gafsa',
    'Tozeur',
    'Kebili',
  ];

  // Method to pick a date
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // Method to pick a time
  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  // Method to send POST request
  Future<void> _offerRide() async {
    // Validate inputs
    if (selectedDeparture == null ||
        selectedDestination == null ||
        selectedDate == null ||
        selectedTime == null ||
        selectedPassengers == null ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the fields.')),
      );
      return;
    }

    // Combine date and time into a single DateTime object
    final dateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    // Prepare request data
    Map<String, dynamic> requestData = {
      "departure": selectedDeparture,
      "time": dateTime.toIso8601String(),
      "destination": selectedDestination,
      "seats_available": selectedPassengers,
      "price": int.tryParse(priceController.text) ?? 0,
    };

    final url = Uri.parse('https://wassalni-maak.onrender.com/carpool');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}', // Add token here
        },
        body: jsonEncode(requestData),
      );
      print(jsonEncode(requestData));

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride offered successfully!')),
        );

        // Navigate to the WelcomeScreen and pass the token
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomeScreen(token: widget.token),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to offer ride: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.redAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Offer a ride',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Departure Dropdown
            DropdownButtonFormField<String>(
              items: locations
                  .map((location) => DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDeparture = value;
                });
              },
              value: selectedDeparture,
              hint: const Text('Select Departure',style: TextStyle(color: Colors.black),),
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Destination Dropdown
            DropdownButtonFormField<String>(
              items: locations
                  .map((location) => DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDestination = value;
                });
              },
              value: selectedDestination,
              hint: const Text('Select Destination',style: TextStyle(color: Colors.black)),
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Date and Time section
            Row(
              children: [
                // Date Picker
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Select Date',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Time Picker
                GestureDetector(
                  onTap: _pickTime,
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        selectedTime != null
                            ? selectedTime!.format(context)
                            : 'Select Time',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 40, color: Colors.grey),

            // Number of Passengers
            ListTile(
              leading: const Icon(Icons.people, color: Colors.grey),
              title: const Text('Number Of Passengers'),
              trailing: DropdownButton<int>(
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedPassengers = value;
                  });
                },
                value: selectedPassengers,
                hint: const Text('Select',style: TextStyle(color: Colors.black)),
              ),
            ),

            // Price Per Seat
            const Divider(height: 20, color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.grey),
              title: const Text('Price per seat'),
              trailing: SizedBox(
                width: 80,
                child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '0.00',
                  ),
                ),
              ),
            ),
            // Offer a Ride Button
            Center(
              child: ElevatedButton(
                onPressed: _offerRide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Offer a ride',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}