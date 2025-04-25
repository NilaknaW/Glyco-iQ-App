import 'package:flutter/material.dart';
import '../helper/database_helper.dart';
import '../helper/bluetooth_helper.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  // update this glucose level data by the app

  List<String> glucose = ['0', '00:00', '0000-00-00'];

  @override
  void initState() {
    super.initState();
    loadLastGlucose();
  }

  void loadLastGlucose() async {
    final data = await DatabaseHelper().getLastGlucose();
    setState(() => glucose = [data['glucose'], data['time'], data['date']]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Expanded(flex: 3, child: lastData(glucose)),
        Expanded(flex: 6, child: monitorData()),
        Expanded(flex: 1, child: connectButton()),
      ]),
    );
  }

  Widget connectButton() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: FilledButton(
        onPressed: () => connectToDevice(context), // add action here
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Connect Glyco-iQ', style: TextStyle(fontSize: 18)),
            Icon(Icons.bluetooth_connected_outlined)
          ],
        ),
      ),
    );
  }

  Widget monitorData() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Card.filled(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(title: Center(child: Text('Monitor Data'))),
            TextButton(
              onPressed: () => readFromBluetooth(
                context: context,
                onDataReceived: (data) {
                  setState(() => glucose = data);
                },
              ),
              child: Text(
                'Monitor Glucose Now',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget lastData(glucose) {
    return Card.filled(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const ListTile(
              title: Center(
                  child: Text('Glucose Level mg/dl',
                      style: TextStyle(fontSize: 20)))),
          Text(
            glucose[0],
            style: const TextStyle(
              fontSize: 36,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text('Time'),
              Text((glucose[1]), style: const TextStyle(fontSize: 24)),
              const Text('Date'),
              Text((glucose[2]), style: const TextStyle(fontSize: 24)),
            ],
          ),
        ],
      ),
    );
  }
}
