import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:obat_5200411150/navbar/home.dart';
import 'package:obat_5200411150/navbar/setting.dart';
import 'package:obat_5200411150/navbar/troli.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavbarState();
}

class _NavbarState extends State<NavBar> {
  int _selectedIndex = 0;

  // Fungsi untuk mengubah halaman yang dipilih di BottomNavigationBar
  void _navigationBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Daftar halaman yang akan ditampilkan berdasarkan index
  final List<Widget> _pages = [
    HomePage(),
    Troli(),
    Setting(), // Pastikan halaman Setting dimasukkan di sini
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _pages[
            _selectedIndex], // Menampilkan halaman yang sesuai dengan index
        bottomNavigationBar: Container(
          color: Colors.green,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: GNav(
              gap: 30, // Jarak antara ikon
              activeColor: Colors.green, // Warna ikon yang aktif
              iconSize: 30, // Ukuran ikon
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 5), // Padding
              duration: const Duration(milliseconds: 300), // Durasi animasi
              tabBackgroundColor:
                  Colors.white, // Warna latar belakang tab yang aktif
              color: Colors.white,
              onTabChange: _navigationBar,
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Beranda',
                ),
                GButton(
                  icon: Icons.shopping_basket,
                  text: 'Keranjang',
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Akun',
                ),
              ],
            ),
          ),
        ));
  }
}
