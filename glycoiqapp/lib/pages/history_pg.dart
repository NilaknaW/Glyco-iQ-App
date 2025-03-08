import 'package:flutter/material.dart';
import '../database_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  void loadHistory() async {
    final data = await DatabaseHelper().getHistory();
    setState(() => history = data);
  }

  //insert random data for glucose level
  // void addHistory(String date, String time, String glucose_level) async {
  //   await DatabaseHelper().insertGlucose(date, time, glucose_level);
  //   loadHistory();
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            graphBlock(),
            shareBlock(),
            historyBlock(),
          ],
        ),
      ),
    );
  }

  Widget graphBlock() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: const Card.filled(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(title: Center(child: Text('Past Week'))),
            Placeholder(
              fallbackHeight: 200,
            ) // add graph here
          ],
        ),
      ),
    );
  }

  Widget shareBlock() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card.filled(
        child: Column(
          children: [
            const ListTile(title: Center(child: Text('Share'))),
            shareButton(const Text('Share'), const Icon(Icons.share)),
            shareButton(const Text('Download'), const Icon(Icons.download)),
          ],
        ),
      ),
    );
  }

  Widget shareButton(Text text, Icon icon) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
      child: FilledButton(
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [text, icon],
        ),
      ),
    );
  }

  Widget historyBlock() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card.filled(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const ListTile(title: Center(child: Text('History'))),
            historyLogs(),
          ],
        ),
      ),
    );
  }

  Widget historyLogs() {
    // return the list of logs
    return Column(
      children: [
        const ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date'),
              Text('Glucose Level'),
            ],
          ),
        ),
        for (var record in history)
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(record['date']),
                Text(record['glucose']),
              ],
            ),
          ),
      ],
    );
  }
}
