import 'package:flutter/material.dart';
import 'package:obat_5200411150/page/Category/hotProduct.dart';
import 'package:obat_5200411150/page/Category/susu.dart';
import 'package:obat_5200411150/page/Category/vitamin.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'Hot Product';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'images/logo.png', // Path ke gambar
              height: 150, // Atur tinggi gambar sesuai kebutuhan
              fit: BoxFit.contain, // Atur cara gambar ditampilkan
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = 'Hot Product';
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedCategory == 'Hot Product'
                          ? Colors.green
                          : Colors.white,
                      border: Border.all(
                        color: selectedCategory == 'Hot Product'
                            ? Colors.green
                            : Colors.green.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      'Hot Product',
                      style: TextStyle(
                        color: selectedCategory == 'Hot Product'
                            ? Colors.white
                            : Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = 'Susu';
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedCategory == 'Susu'
                          ? Colors.green
                          : Colors.white,
                      border: Border.all(
                        color: selectedCategory == 'Susu'
                            ? Colors.green
                            : Colors.green.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      'Susu',
                      style: TextStyle(
                        color: selectedCategory == 'Susu'
                            ? Colors.white
                            : Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = 'Vitamin';
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedCategory == 'Vitamin'
                          ? Colors.green
                          : Colors.white,
                      border: Border.all(
                        color: selectedCategory == 'Vitamin'
                            ? Colors.green
                            : Colors.green.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      'Vitamin',
                      style: TextStyle(
                        color: selectedCategory == 'Vitamin'
                            ? Colors.white
                            : Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),

          // Expanded container for the AnimatedSwitcher to fill the screen
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: selectedCategory == 'Vitamin'
                  ? Vitamin() // Display Vitamin widget
                  : selectedCategory == 'Hot Product'
                      ? HotProduct() // Display Hot Product widget
                      : selectedCategory == 'Susu'
                          ? Susu() // Display Susu widget
                          : Container(), // Placeholder if no category is selected
            ),
          ),
        ],
      ),
    );
  }
}
