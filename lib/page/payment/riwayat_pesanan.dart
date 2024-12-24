import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:obat_5200411150/navbar/navbar.dart';
import 'package:obat_5200411150/page/payment/pesanan.dart';

class RiwayatPesanan extends StatefulWidget {
  const RiwayatPesanan({super.key});

  @override
  _RiwayatPesananState createState() => _RiwayatPesananState();
}

class _RiwayatPesananState extends State<RiwayatPesanan> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Order> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('riwayat_pesanan')
          .get();

      setState(() {
        orders = snapshot.docs.map((doc) {
          final data = doc.data();
          return Order(
            id: doc.id, // Get the document ID
            items: List<Map<String, dynamic>>.from(data['items']),
            totalPrice: data['totalPrice'],
            shippingCost: data['shippingCost'],
            totalWithShipping: data['totalWithShipping'],
            status: data['status'],
            delivery: data['delivery'] ?? 'Status tidak tersedia',
            deliveryStatus: data['deliveryStatus'] ??
                'Status tidak tersedia', // Handle null value
            paymentMethod: data['paymentMethod'] ??
                'Belum melakukan pembayaran', // Fetch payment method
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          );
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching order history: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showOrderOptions(Order order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('PESANAN BELUM DIBAYARKAN'), // Updated title
          content: Text('Apa yang ingin Anda lakukan dengan pesanan ini?'),
          actions: [
            TextButton(
              onPressed: () {
                _cancelOrder(order);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('BATALKAN PESANAN'), // Updated button text
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Set text color to red
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Pesanan(id: order.id)), // Navigate to payment page
                );
              },
              child: Text('BAYAR'), // Updated button text
              style: TextButton.styleFrom(
                foregroundColor: Colors.green, // Set text color to green
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('KEMBALI'), // New button text
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Set text color to black
              ),
            ),
          ],
        );
      },
    );
  }

  void _showOrderOptions1(Order order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('RIWAYAT PESANAN'), // Updated title
          content: Text('Apa yang ingin Anda lakukan dengan pesanan ini?'),
          actions: [
            TextButton(
              onPressed: () {
                _cancelOrder(order);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('BATALKAN PESANAN'), // Updated button text
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Set text color to red
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('KEMBALI'), // New button text
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Set text color to black
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelOrder(Order order) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Update the order status to "dibatalkan"
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('riwayat_pesanan')
          .doc(order.id) // Use the order ID
          .update({'status': 'dibatalkan'});

      // Refresh the order history
      _fetchOrderHistory();
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  void _confirmDeleteOrder(Order order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Riwayat Pesanan'),
          content:
              Text('Apakah Anda yakin ingin menghapus riwayat pesanan ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('KEMBALI'), // New button text
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Set text color to black
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteOrder(order);
                Navigator.of(context).pop();
              },
              child: Text('HAPUS'), // Updated button text
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Set text color to red
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteOrder(Order order) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('riwayat_pesanan')
          .doc(order.id) // Use the order ID
          .delete(); // Delete the order

      // Refresh the order history
      _fetchOrderHistory();
    } catch (e) {
      print('Error deleting order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Pesanan'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => NavBar()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(child: Text('Tidak ada riwayat pesanan.'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return GestureDetector(
                      onLongPress: () {
                        _confirmDeleteOrder(
                            order); // Show delete confirmation on long press
                      },
                      onTap: () {
                        if (order.status == 'belum dibayarkan') {
                          _showOrderOptions(order);
                        } else if (order.status == 'dibatalkan') {
                        } else {
                          _showOrderOptions1(order);
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pesanan #${index + 1}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              ...order.items.map((item) {
                                return Text(
                                  '${item['name']} - ${item['quantity']} x ${formatCurrency(item['price'])}',
                                );
                              }).toList(),
                              SizedBox(height: 8),
                              Divider(),
                              Text(
                                  'Ongkir: ${formatCurrency(order.shippingCost)}'),
                              Text(
                                  'Total Harga Pesanan: ${formatCurrency(order.totalPrice)}'), // Display total price
                              Text(
                                  'Total Harga yang dibayarkan: ${formatCurrency(order.totalWithShipping)}'),
                              SizedBox(height: 8),
                              Text('Tanggal: ${formatDate(order.createdAt)}'),
                              Text('Pengiriman: ${order.delivery}'),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Status pembayaran :'),
                                  Text(
                                    '${order.status}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: order.status == 'dibatalkan'
                                          ? Colors.red
                                          : order.status == 'belum dibayarkan'
                                              ? Colors.orange
                                              : order.status == 'dibayarkan'
                                                  ? Colors.green
                                                  : Colors
                                                      .grey, // Default color
                                    ),
                                  ),
                                ],
                              ),
                              // Display payment method only if not canceled
                              if (order.status != 'dibatalkan') ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Metode Pembayaran:'),
                                    Text(
                                      '${order.paymentMethod ?? 'Tidak ada metode pembayaran'}', // Display payment method
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .grey, // Optional color for payment method
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              // Display delivery status only if not canceled
                              if (order.status != 'dibatalkan') ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Status pengiriman:'),
                                    Text(
                                      '${order.deliveryStatus ?? 'Tidak ada status pengiriman'}', // Display delivery status
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .grey, // Optional color for delivery status
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String formatCurrency(int amount) {
    return 'Rp. ${amount.toString()}'; // Adjust this to your currency formatting
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}'; // Format date as needed
  }
}

class Order {
  final String id; // Add an ID field for the order
  final List<Map<String, dynamic>> items;
  final int totalPrice;
  final int shippingCost;
  final int totalWithShipping;
  final String status;
  final String delivery;
  final String deliveryStatus; // Add delivery status field
  final String paymentMethod; // Add payment method field
  final DateTime createdAt;

  Order({
    required this.id, // Include ID in the constructor
    required this.items,
    required this.totalPrice,
    required this.shippingCost,
    required this.totalWithShipping,
    required this.status,
    required this.delivery,
    required this.deliveryStatus, // Include delivery status in the constructor
    required this.paymentMethod, // Include payment method in the constructor
    required this.createdAt,
  });
}
