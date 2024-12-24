import 'package:flutter/material.dart';
import 'package:obat_5200411150/navbar/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:obat_5200411150/auth/login.dart';
import 'package:obat_5200411150/auth/register.dart';

class GetStart extends StatelessWidget {
  const GetStart({super.key});

  @override
  Widget build(BuildContext context) {
    // Call the checkLoginStatus method and pass the context
    _checkLoginStatus(context);

    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/logo1.png',
              width: 300, // Adjust the width as needed
              height: 150, // Adjust the height as needed
            ),
            SizedBox(height: 100),
            Text(
              'Mulai dengan daftar atau masuk',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Register()),
                );
              },
              child: Text(
                'DAFTAR',
                style: TextStyle(color: Colors.green),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: Text(
                'MASUK',
                style: TextStyle(color: Colors.green),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkLoginStatus(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');

    if (isLoggedIn == true) {
      // Jika sudah login, arahkan ke Navbar
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavBar()),
      );
    }
  }
}
