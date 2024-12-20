import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:obat_5200411150/auth/getstarted.dart';
import 'package:obat_5200411150/firebase_options.dart';
// import 'package:obat_5200411150/navbar/navbar.dart';

void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     runApp(MyApp());
   }

   class MyApp extends StatelessWidget {
     const MyApp({super.key});

     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         debugShowCheckedModeBanner: false,
         home: GetStart(),
       );
     }
   }
