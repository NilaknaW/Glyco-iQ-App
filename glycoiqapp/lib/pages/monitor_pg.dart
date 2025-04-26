import 'package:flutter/material.dart';
import '../helper/database_helper.dart';
import '../helper/bluetooth_helper.dart';
// import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

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
      width: double.infinity,
      child: Card.filled(
        // child: Padding(
        // padding: const EdgeInsets.all(20),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.greenAccent, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: FilledButton(
                onPressed: () => readFromBluetooth(
                  context: context,
                  onDataReceived: (data) {
                    // if (data)
                    setState(() => glucose = data);
                  },
                ),
                child: Column(
                  children: [
                    Image.asset('assets/icons/icon.png')
                        .animate(onPlay: (controller) => controller.repeat())
                        .fadeIn(curve: Curves.easeInOut, duration: 1500.ms)
                        .scale(
                          curve: Curves.easeInOut,
                          duration: 1500.ms,
                        )
                        .then(delay: 1000.ms)
                        .fadeOut(curve: Curves.easeInOut, duration: 1000.ms)
                        .then(delay: 500.ms), // baseline=800ms
                    Text(
                      'Monitor Glucose Now',
                      style: TextStyle(
                        fontSize: 18,
                        color: ColorScheme.fromSeed(seedColor: Colors.blue)
                            .primary,
                      ),
                    ),
                  ],
                ),
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(Colors.white.withOpacity(0.5)),
                  foregroundColor: WidgetStatePropertyAll(Colors.blue),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      // side: const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // ),
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
                  child: Text('Glucose Level mmol/L',
                      style: TextStyle(fontSize: 20)))),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                glucose[0],
                style: TextStyle(
                  fontSize: 36,
                  color: ColorScheme.fromSeed(seedColor: Colors.blue).primary,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                (double.parse(glucose[0]) <= 7.8 &&
                        double.parse(glucose[0]) > 3.9)
                    ? Icons.check_circle
                    : Icons.error,
                color: (double.parse(glucose[0]) <= 7.8 &&
                        double.parse(glucose[0]) > 3.9)
                    ? Colors.green
                    : Colors.red,
                size: 36,
              )
            ],
          ),
          // Text(
          //   glucose[0],
          //   style: TextStyle(
          //     fontSize: 36,
          //     color: ColorScheme.fromSeed(seedColor: Colors.blue).primary,
          //   ),
          // ),
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
