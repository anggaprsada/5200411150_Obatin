import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:obat_5200411150/page/payment/riwayat_pesanan.dart';
import 'package:obat_5200411150/page/payment/sukses_bayar.dart'; // Import the success page

class Pesanan extends StatefulWidget {
  final String id; // ID of the order from riwayat_pesanan

  const Pesanan({super.key, required this.id});

  @override
  _PesananState createState() => _PesananState();
}

class _PesananState extends State<Pesanan> {
  int total = 0; // Initialize total amount
  List<Map<String, dynamic>> items = []; // List to hold order items
  String? selectedPaymentMethod;
  String? delivery = '';
  String deliveryStatus = ''; // Initialize delivery status

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails(); // Fetch the order details based on the order ID
  }

  Future<void> _fetchOrderDetails() async {
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Use the current user's ID
          .collection('riwayat_pesanan')
          .doc(widget.id) // Use the passed ID
          .get();

      if (doc.exists) {
        setState(() {
          delivery = doc.data()?['delivery'] ?? '';
          total = doc.data()?['totalWithShipping'] ?? 0; // Fetch total amount
          items = List<Map<String, dynamic>>.from(
              doc.data()?['items'] ?? []); // Fetch items
          deliveryStatus =
              doc.data()?['deliveryStatus'] ?? ''; // Fetch delivery status
        });
      } else {
        print('Order not found');
      }
    } catch (e) {
      print('Error fetching order details: $e');
    }
  }

  Future<void> _updateOrderStatus(String status, String paymentMethod) async {
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Use the current user's ID
          .collection('riwayat_pesanan')
          .doc(widget.id) // Use the passed ID
          .update({
        'status': status, // Update status
        'deliveryStatus': deliveryStatus, // Update delivery status
        'paymentMethod': paymentMethod // Add payment method
      });
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Metode Pembayaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Pesanan:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            // Display order items
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text('Jumlah: ${item['quantity']}'),
                    trailing: Text('Rp ${item['price']}'),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Text('Metode Pengiriman: $delivery',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Pilih Metode Pembayaran:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            // QRIS Option
            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(
                  horizontal: 8, vertical: 8), // Reduced vertical margin
              child: ListTile(
                title: Image.asset(
                  'images/qris.png', // Path to the image
                  height: 20, // Set the height of the image as needed
                  fit: BoxFit.contain, // Set how the image should be displayed
                ),
                leading: Radio<String>(
                  value: 'qris',
                  groupValue: selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentMethod = value;
                    });
                  },
                  activeColor: Colors.black, // Set the active color to black
                ),
                tileColor: selectedPaymentMethod == 'qris'
                    ? Colors.green
                    : null, // Change to green if selected
              ),
            ),
            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(
                  horizontal: 8, vertical: 8), // Reduced vertical margin
              child: ListTile(
                title: Text('TUNAI'),
                leading: Radio<String>(
                  value: 'cash',
                  groupValue: selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentMethod = value;
                    });
                  },
                  activeColor: Colors.black, // Set the active color to black
                ),
                tileColor: selectedPaymentMethod == 'cash'
                    ? Colors.green
                    : null, // Change to green if selected
              ),
            ),
            // Cash Option

            // Spacer(),
            // Pay Button
            SizedBox(height: 10),
            Text(
              'Total: Rp $total', // Display total amount
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // Handle payment action
                if (selectedPaymentMethod != null) {
                  if (selectedPaymentMethod == 'cash') {
                    if (deliveryStatus == 'Ambil pesanan di apotek') {
                      deliveryStatus = 'Ambil pesanan di apotek';
                    } else if (deliveryStatus == 'Selesaikan pembayaran') {
                      deliveryStatus = 'Driver sedang dalam perjalanan';
                    }

                    await _updateOrderStatus('Pembayaran Cash',
                        'CASH'); // Update status and payment method
                    // Navigate back to the order history
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RiwayatPesanan()),
                    );
                  } else if (selectedPaymentMethod == 'qris') {
                    if (deliveryStatus == 'Ambil pesanan di apotek') {
                      deliveryStatus = 'Segera Ambil pesanan anda';
                    } else if (deliveryStatus == 'Selesaikan pembayaran') {
                      deliveryStatus = 'Driver sedang dalam perjalanan';
                    }
                    await _updateOrderStatus('dibayarkan',
                        'QRIS'); // Update status and payment method
                    // Navigate to the success page for QRIS payment
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SuksesBayar(), // Navigate to success page
                      ),
                    );
                  }
                } else {
                  // Show a message if no payment method is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Silakan pilih metode pembayaran.')),
                  );
                }
              },
              child: Text(
                'BAYAR',
                style:
                    TextStyle(color: Colors.white), // Set text color to white
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green, // Set button background color to green
                minimumSize: Size(double.infinity, 50), // Full width button
              ),
            ),

            Spacer(),
          ],
        ),
      ),
    );
  }
}
