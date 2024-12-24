import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:obat_5200411150/page/payment/pesanan.dart'; // Import the Pesanan widget

class Troli extends StatefulWidget {
  const Troli({super.key});

  @override
  _TroliState createState() => _TroliState();
}

class _TroliState extends State<Troli> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Item> items = [];
  String selectedDeliveryMethod = 'Antar'; // Default to 'Antar'
  int shippingCost = 10000; // Set the shipping cost

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  void _fetchCartItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();
      setState(() {
        items = snapshot.docs.map((doc) {
          final data = doc.data();
          return Item(
            id: doc.id,
            name: data['name'],
            price: (data['price'] is int)
                ? data['price']
                : int.tryParse(data['price'].toString()) ?? 0,
            quantity: data['quantity'],
            imageUrl: data['image'],
          );
        }).toList();
      });
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  int get total {
    return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  int get totalWithShipping {
    return total + shippingCost; // Total including shipping
  }

  void updateQuantity(int index, int change) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    setState(() {
      items[index].quantity += change;
      if (items[index].quantity < 0) {
        items[index].quantity = 0;
      }
    });

    try {
      final itemRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(items[index].id);
      await itemRef.update({'quantity': items[index].quantity});
    } catch (e) {
      print('Error updating quantity in Firestore: $e');
    }
  }

  String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(amount);
  }

  void removeItem(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(items[index].id)
          .delete();

      setState(() {
        items.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${items[index].name} terhapus dari keranjang!')),
      );
    } catch (e) {
      print('Error removing item: $e');
    }
  }

  void selectDeliveryMethod(String method) {
    setState(() {
      selectedDeliveryMethod = method; // Update selected method
      // Set shipping cost based on delivery method
      shippingCost = method == 'Pick up' ? 0 : 10000; // Set to 0 for Pick up
    });
  }

  Future<void> saveOrderHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    // Create a unique ID based on the current date and time
    String orderId = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    // Prepare the order data
    List<Map<String, dynamic>> orderItems = items.map((item) {
      return {
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
      };
    }).toList();

    String deliveryStatus = selectedDeliveryMethod == 'Pick up'
        ? 'Ambil pesanan di apotek'
        : 'Selesaikan pembayaran';

    String delivery = selectedDeliveryMethod == 'Pick up' ? 'PICK UP' : 'ANTAR';

    // Create the order data
    Map<String, dynamic> orderData = {
      'items': orderItems,
      'totalPrice': total,
      'shippingCost': shippingCost,
      'totalWithShipping': totalWithShipping,
      'status': 'belum dibayarkan',
      'deliveryStatus': deliveryStatus,
      'delivery' : delivery,
      'createdAt': FieldValue.serverTimestamp(), // Timestamp for the order
    };

    try {
      // Save the order data to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('riwayat_pesanan')
          .doc(orderId) // Use the orderId as the document ID
          .set(orderData);

      // Optionally, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pesanan berhasil disimpan!')),
      );

      // Clear the cart after saving the order
      await clearCart();

      // Navigate to the Pesanan page with the order ID
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Pesanan(id: orderId)), // Pass the orderId
      );
    } catch (e) {
      print('Error saving order history: $e');
    }
  }

  Future<void> clearCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      // Clear all items in the cart
      for (var item in items) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(item.id)
            .delete();
      }

      setState(() {
        items.clear(); // Clear the local cart items
      });
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang saya'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white70,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Image.network(
                        items[index].imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(items[index].name),
                      subtitle: Text(formatCurrency(items[index].price)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () => updateQuantity(index, -1),
                          ),
                          Text('${items[index].quantity}'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => updateQuantity(index, 1),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            // Check if the cart is empty
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Keranjang Anda Kosong',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              )
            else ...[
              // Display delivery options and total costs if the cart is not empty
              Column(
                children: [
                  Text(
                    'Opsi pengiriman',
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            selectDeliveryMethod('Pick up');
                          },
                          child: Text('Pick up'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedDeliveryMethod == 'Pick up'
                                ? Colors.green
                                : Colors.white,
                            foregroundColor: selectedDeliveryMethod == 'Pick up'
                                ? Colors.white
                                : Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                      SizedBox(width: 8), // Add some space between buttons
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            selectDeliveryMethod('Antar');
                          },
                          child: Text('Antar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedDeliveryMethod == 'Antar'
                                ? Colors.green
                                : Colors.white,
                            foregroundColor: selectedDeliveryMethod == 'Antar'
                                ? Colors.white
                                : Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pesanan: ${formatCurrency(total)}'),
                  Text('Ongkir: ${formatCurrency(shippingCost)}'),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${formatCurrency(totalWithShipping)}',
                    style: TextStyle(fontSize: 20),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save order history and navigate to the Pesanan page
                      await saveOrderHistory();
                    },
                    child: Text(
                      'BAYAR',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class Item {
  final String id;
  final String name;
  final int price;
  int quantity;
  final String imageUrl;

  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });
}
