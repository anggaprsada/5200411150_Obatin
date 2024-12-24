import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Susu extends StatefulWidget {
  const Susu({super.key});

  @override
  _SusuState createState() => _SusuState();
}

class _SusuState extends State<Susu> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<Map<String, dynamic>> products =
      []; // Change to dynamic to handle mixed types

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Format harga
  String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(amount);
  }

  // Fetch products from Firebase Realtime Database
  void _fetchProducts() async {
    try {
      final snapshot = await _databaseRef.child('kategori/susu').get();

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          final Map<String, dynamic> data =
              Map<String, dynamic>.from(snapshot.value as Map);

          setState(() {
            products = data.entries.map((entry) {
              return {
                'name': entry.value['nama']?.toString() ?? 'No Name',
                'price': entry.value['harga'] is int
                    ? entry.value['harga']
                    : int.tryParse(entry.value['harga'].toString()) ?? 0,
                'image': entry.value['gambar']?.toString() ??
                    'https://d3bbrrd0qs69m4.cloudfront.net/images/product/apotek_online_k24klik_20221130011655359225_indomilk-susu-steril-3.png',
              };
            }).toList();
          });
        } else {
          setState(() {
            products = [];
          });
        }
      } else {
        setState(() {
          products = [];
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _addToCart(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to add items to cart.')),
      );
      return;
    }

    try {
      final cartRef =
          _firestore.collection('users').doc(user.uid).collection('cart');
      final itemRef = cartRef.doc(product['name']);
      final docSnapshot = await itemRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        int currentQuantity = data['quantity'] ?? 0;
        await itemRef.update({'quantity': currentQuantity + 1});
      } else {
        await itemRef.set({
          'name': product['name'],
          'price': product['price'],
          'quantity': 1,
          'image': product['image'], // Add the image URL here
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product['name']} ditambahkan ke keranjang!')),
      );
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
          final cardWidth = (constraints.maxWidth / crossAxisCount) - 20;
          final cardHeight = cardWidth * 1.2;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              // Allow scrolling
              child: Column(
                children: [
                  GridView.builder(
                    physics:
                        NeverScrollableScrollPhysics(), // Disable scrolling
                    shrinkWrap:
                        true, // Allow GridView to take only the space it needs
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: cardWidth / cardHeight,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: AspectRatio(
                                aspectRatio: 1.6,
                                child: Image.network(
                                  product['image']!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      formatCurrency(
                                          product['price']), // Format the price
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _addToCart(product);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Add to Cart',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
