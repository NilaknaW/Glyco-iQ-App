import 'package:flutter/material.dart';
import 'navigator/navigator.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glyco-iQ',
      theme: ThemeData(
        // primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Montserrat',
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
