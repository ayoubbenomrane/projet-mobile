import 'package:flutter/material.dart';

class PhoneVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phone Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Enter the code you’ve just received',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge), // Updated for new TextTheme
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => OTPBox()),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/setPassword');
              },
              child: Text('Verify Code'),
            ),
            TextButton(
              onPressed: () {},
              child: Text('Didn’t receive code? Resend again'),
            ),
          ],
        ),
      ),
    );
  }
}

class OTPBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 50,
      child: TextField(
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: TextInputType.number,
        maxLength: 1,
      ),
    );
  }
}
