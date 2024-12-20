import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Troli extends StatefulWidget {
  const Troli({super.key});

  @override
  _TroliState createState() => _TroliState();
}

class _TroliState extends State<Troli> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Item> items = [];

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
            imageUrl: data['image'], // Add image URL here
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
        SnackBar(content: Text('${items[index].name} removed from cart!')),
      );
    } catch (e) {
      print('Error removing item: $e');
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
                        items[index]
                            .imageUrl, // Display the image from Firestore
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
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Align items to the edges
              children: [
                Text(
                  'Total: ${formatCurrency(total)}',
                  style: TextStyle(fontSize: 20),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pembayaran berhasil!')),
                    );
                  },
                  child: Text(
                    'BAYAR',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15), // Adjust padding as needed
                  ),
                ),
              ],
            ),
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
  final String imageUrl; // Add image URL field

  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl, // Include image URL in constructor
  });
}
