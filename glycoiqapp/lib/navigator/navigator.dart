import 'package:flutter/material.dart';
import '/pages/monitor_pg.dart';
import '/pages/history_pg.dart';
import '/pages/support_pg.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // create navigator
  int _currentIndex = 0;
  final List<Widget> _pages = <Widget>[
    // add pages here
    const MonitorPage(),
    const HistoryPage(),
    const SupportPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glyco-iQ',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
        leading: Image.asset('assets/icons/icon.png', fit: BoxFit.contain),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            label: 'Monitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call_end_outlined),
            label: 'Support',
          ),
        ],
      ),
    );
  }
}
