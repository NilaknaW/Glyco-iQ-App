import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';

Future<void> readFromBluetooth({
  required BuildContext context,
  required Function(List<String>) onDataReceived,
}) async {
  try {
    final connectedDevices = await FlutterBluePlus.connectedDevices;
    if (connectedDevices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No connected device found.")),
      );
      return;
    }

    final device = connectedDevices.first;
    List<BluetoothService> services = await device.discoverServices();

    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.read) {
          List<int> value = await characteristic.read();
          String data = String.fromCharCodes(value).trim();

          final now = DateTime.now();
          final time = "${now.hour}:${now.minute}";
          final date = "${now.year}-${now.month}-${now.day}";

          await DatabaseHelper().insertGlucose(date, time, data);
          onDataReceived([data, time, date]);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Glucose: $data inserted")),
          );
          return;
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No readable characteristic found.")),
    );
  } catch (e) {
    debugPrint("Bluetooth read error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bluetooth read error: $e")),
    );
  }
}

void connectToDevice(BuildContext context) async {
  List<ScanResult> foundDevices = [];

  Future<void> startScan() async {
    // Ask for permissions
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    // await Permission.location.request();

    foundDevices.clear();
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    final subscription = FlutterBluePlus.scanResults.listen((results) {
      foundDevices = results;
    });

    await Future.delayed(const Duration(seconds: 5));
    await FlutterBluePlus.stopScan();
    await subscription.cancel();
  }

  // Initial scan
  await startScan();

  if (context.mounted) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Choose Bluetooth Device'),
            content: SizedBox(
              height: 350,
              width: double.maxFinite,
              child: Column(
                children: [
                  Expanded(
                    child: foundDevices.isEmpty
                        ? const Center(child: Text("No devices found"))
                        : ListView.builder(
                            itemCount: foundDevices.length,
                            itemBuilder: (context, index) {
                              final result = foundDevices[index];
                              final device = result.device;
                              final deviceName =
                                  result.advertisementData.advName.isNotEmpty
                                      ? result.advertisementData.advName
                                      : "Unknown Device";

                              if (deviceName == "Unknown Device") {
                                return const SizedBox.shrink();
                              }
                              return ListTile(
                                title: Text(deviceName),
                                // subtitle: Text(device.remoteId.toString()),
                                onTap: () async {
                                  Navigator.pop(context); // close dialog
                                  try {
                                    await device.connect();
                                    debugPrint("Connected to $deviceName");
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(deviceName
                                                  .toLowerCase()
                                                  .contains("glyco")
                                              ? "Glyco Connected"
                                              : "Connected to $deviceName"),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text("Connection failed: $e")),
                                      );
                                    }
                                  }
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () async {
                      await startScan();
                      setState(() {}); // refresh UI
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Scan Again"),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
