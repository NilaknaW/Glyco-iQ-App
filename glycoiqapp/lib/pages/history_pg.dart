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
    // here we will fetch data from the database
    // List data = [
    //   {'date': '2022-01-01', 'glucose': '100'},
    //   {'date': '2022-01-02', 'glucose': '110'},
    //   {'date': '2022-01-03', 'glucose': '120'},
    //   {'date': '2022-01-04', 'glucose': '130'},
    //   {'date': '2022-01-05', 'glucose': '140'},
    //   {'date': '2022-01-06', 'glucose': '150'},
    //   {'date': '2022-01-07', 'glucose': '160'},
    //   {'date': '2022-01-08', 'glucose': '170'},
    //   {'date': '2022-01-09', 'glucose': '180'},
    //   {'date': '2022-01-10', 'glucose': '190'},
    // ];

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
                // Text(data[i]['date']),
                // Text(data[i]['glucose']),
                Text(record['date']),
                Text(record['glucose_level']),
              ],
            ),
          ),
      ],
    );
  }
}
