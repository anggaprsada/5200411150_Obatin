import 'package:flutter/material.dart';
import 'package:obat_5200411150/auth/getstarted.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Call the logout function
            await _logout(context);
          },
          child: Text('LOG OUT'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            backgroundColor: Colors.red, // Change color to indicate logout
          ),
        ),
      ),
    );
  }
  

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Clear login status

    // Navigate to GetStart page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GetStart()),
    );
  }
}
