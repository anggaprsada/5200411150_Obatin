import 'package:flutter/material.dart';
import 'package:obat_5200411150/page/payment/riwayat_pesanan.dart'; // Import the RiwayatPesanan page

class SuksesBayar extends StatelessWidget {
  const SuksesBayar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 300,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.check,
                  size: 100,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'SUKSES',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 100),
              // Wrap the button in a Container to add margin
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: 16.0), // Add horizontal margin
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to the RiwayatPesanan page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RiwayatPesanan(),
                      ),
                    );
                  },
                  child: Text('OKE'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.green,
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50), // Full width button
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
