import 'package:flutter/material.dart';
import 'package:obat_5200411150/auth/getstarted.dart';
import 'package:obat_5200411150/page/payment/riwayat_pesanan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Akun Saya'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Card for History (Riwayat)
            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8), // Reduced vertical margin
              child: ListTile(
                title: Text('RIWAYAT PESANAN'),
                leading: Icon(Icons.history),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RiwayatPesanan()),
                  );
                },
              ),
            ),
            // Card for Logout
            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8), // Reduced vertical margin
              child: ListTile(
                title: Text('LOG OUT', style: TextStyle(color: Colors.red)),
                leading: Icon(Icons.logout, color: Colors.red),
                onTap: () async {
                  // Call the logout function
                  await _logout(context);
                },
              ),
            ),
          ],
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
