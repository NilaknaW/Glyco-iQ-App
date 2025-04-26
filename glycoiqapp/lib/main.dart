import 'package:flutter/material.dart';
import 'navigator/navigator.dart';
import 'package:splash_master/splash_master.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // print('Initializing SplashMaster...');
  // SplashMaster.initialize();
  // print('Resuming SplashMaster...');
  // SplashMaster.resume();
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
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
