
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            graph(),
            share(),
            history(),
          ],
        ),
      ),
    );
  }
}

Widget graph() {
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

Widget share() {
  return Container(
    padding: const EdgeInsets.only(bottom: 10),
    child: Card.filled(
      child: Column(
        children: [
          const ListTile(title: Center(child: Text('Share'))),
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: FilledButton(
              onPressed: () {},
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [Text('Share'), Icon(Icons.share)],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: FilledButton(
              onPressed: () {},
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [Text('Download'), Icon(Icons.download)],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget history() {
  return Container(
    padding: const EdgeInsets.only(bottom: 10),
    child: Card.filled(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const ListTile(title: Center(child: Text('History'))),
          logs(),
        ],
      ),
    ),
  );
}

Widget logs() {
  // here we will fetch data from the database
  List data = [
    {'date': '2022-01-01', 'glucose': '100'},
    {'date': '2022-01-02', 'glucose': '110'},
    {'date': '2022-01-03', 'glucose': '120'},
    {'date': '2022-01-04', 'glucose': '130'},
    {'date': '2022-01-05', 'glucose': '140'},
    {'date': '2022-01-06', 'glucose': '150'},
    {'date': '2022-01-07', 'glucose': '160'},
    {'date': '2022-01-08', 'glucose': '170'},
    {'date': '2022-01-09', 'glucose': '180'},
    {'date': '2022-01-10', 'glucose': '190'},
  ];

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
      for (int i = 0; i < 10; i++)
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data[i]['date']),
              Text(data[i]['glucose']),
            ],
          ),
        ),
    ],
  );
}
