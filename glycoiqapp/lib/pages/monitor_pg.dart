import 'package:flutter/material.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({Key? key}) : super(key: key);

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  List<int> glucose = [
    78,
    20,
    55,
    3,
    3,
    2025
  ]; //glusose level, hour, minute, day, month, year
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        connectButton(),
        const SizedBox(height: 20),
        monitorData(),
        const SizedBox(height: 20),
        lastData(glucose),
      ]),
    );
  }
}

Widget connectButton() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {}, // add action here
      child: const Text('Connect Glyco-iQ', style: TextStyle(fontSize: 18)),
    ),
  );
}

Widget monitorData() {
  return Container(
    // padding: const EdgeInsets.all(10),
    height: 200,
    width: double.infinity,
    child: Card(
      child: ElevatedButton(
        onPressed: () {}, // add action here
        child: const Text('Monitor', style: TextStyle(fontSize: 18)),
      ),
    ),
  );
}

Widget lastData(glucose) {
  return Card(
    child: Column(
      children: [
        ListTile(title: Center(child: Text('Last Monitored'))),
        Text(
          glucose[0].toString() + ' mg/dl',
          style:
              TextStyle(fontSize: 36, color: ColorScheme.fromSwatch().primary),
        ),
        SizedBox(height: 10),
        Text(
          'recorded at ' +
              glucose[1].toString() +
              ':' +
              glucose[2].toString() +
              ' ' +
              glucose[3].toString() +
              '/' +
              glucose[4].toString() +
              '/' +
              glucose[5].toString(),
        ),
        SizedBox(height: 10),
      ],
    ),
  );
}
