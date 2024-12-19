import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              // Add logout logic here
              print('Logout clicked');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.red,
              child: CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage('assets/jotaro.jpeg'),
              ),
            ),
            SizedBox(height: 20),
            // Name and Email
            Text(
              'Zaineb Chaabane',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'zaineb.chaabane@supcom.tn',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 40),
            // Complain Option
            ListTile(
              leading: Icon(Icons.error_outline, color: Colors.black),
              title: Text(
                'Complain',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                // Add complain logic here
                print('Complain clicked');
              },
            ),
            Divider(),
            // Help and Support Option
            ListTile(
              leading: Icon(Icons.help_outline, color: Colors.black),
              title: Text(
                'Help and Support',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                // Add help and support logic here
                print('Help and Support clicked');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Your rides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Publish',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
