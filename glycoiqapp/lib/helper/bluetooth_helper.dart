import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// Future<void> readFromBluetooth({
//   required BuildContext context,
//   required Function(List<String>) onDataReceived,
// }) async {
//   try {
//     final connectedDevices = await FlutterBluePlus.connectedDevices;
//     if (connectedDevices.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No connected device found.")),
//       );
//       return;
//     }

//     final device = connectedDevices.first;
//     List<BluetoothService> services = await device.discoverServices();

//     for (BluetoothService service in services) {
//       for (BluetoothCharacteristic characteristic in service.characteristics) {
//         if (characteristic.properties.read) {
//           List<int> value = await characteristic.read();
//           String glucoseData = String.fromCharCodes(value).trim();

//           final now = DateTime.now();
//           final time = "${now.hour}:${now.minute}";
//           final date = "${now.year}-${now.month}-${now.day}";

//           await DatabaseHelper().insertGlucose(date, time, glucoseData);
//           onDataReceived([glucoseData, time, date]);

//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Glucose level: $glucoseData")),
//           );
//           return;
//         }
//       }
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("No readable characteristic found.")),
//     );
//   } catch (e) {
//     debugPrint("Bluetooth read error: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Bluetooth read error: $e")),
//     );
//   }
// }

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
            title: const Text('Choose GlycoIQ Device'),
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
                                  // Navigator.pop(context); // close dialog
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
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );

                                      // Delay before popping to allow SnackBar to show
                                      await Future.delayed(
                                          const Duration(seconds: 2));
                                      Navigator.pop(
                                          context); // close dialog AFTER snack shows
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

Future<void> readFromBluetooth({
  required BuildContext context,
  required Function(List<String>) onDataReceived,
}) async {
  const serviceUuid = "00000000-8cb1-44ce-9a66-001dca0941a6";
  const writeCharUuid = "00000001-8cb1-44ce-9a66-001dca0941a6";
  const notifyCharUuid = "00000002-8cb1-44ce-9a66-001dca0941a6";

  try {
    final connectedDevices = FlutterBluePlus.connectedDevices;
    if (connectedDevices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No connected device found.")),
      );
      return;
    }

    final device = connectedDevices.first;
    List<BluetoothService> services = await device.discoverServices();
    BluetoothCharacteristic? writeChar;
    BluetoothCharacteristic? notifyChar;

    for (BluetoothService service in services) {
      if (service.uuid.toString().toLowerCase() == serviceUuid) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid.toString().toLowerCase() == writeCharUuid) {
            writeChar = characteristic;
          }
          if (characteristic.uuid.toString().toLowerCase() == notifyCharUuid) {
            notifyChar = characteristic;
          }
        }
      }
    }

    if (writeChar == null || notifyChar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Required characteristics not found.")),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Measuring..."),
          ],
        ),
      ),
    );

    // Start listening for data
    if (notifyChar.properties.notify) {
      await notifyChar.setNotifyValue(true);
      notifyChar.value.listen((value) async {
        if (value.isNotEmpty) {
          Navigator.pop(context); // Close loading dialog

          String jsonData = String.fromCharCodes(value).trim();
          debugPrint("Received data: $jsonData");
          try {
            Map<String, dynamic> data = json.decode(jsonData);
            if (data['status'] == 'success') {
              String glucose = data['glucose_level'].toString();
              DateTime now = DateTime.now();
              String time = data['time'] ?? DateFormat('HH:mm').format(now);
              String date =
                  data['date'] ?? DateFormat('yyyy-MM-dd').format(now);
              await DatabaseHelper().insertGlucose(date, time, glucose);
              onDataReceived([glucose, time, date]);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Glucose level: $glucose")),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Device error: ${data['message']}")),
              );
            }
          } catch (e) {
            debugPrint("Error parsing data: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid data received")),
            );
          }
        }
      });
    }

    if (writeChar.properties.write) {
      await writeChar.write("run_device".codeUnits);
    } else {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot write to characteristic.")),
      );
    }
  } catch (e) {
    debugPrint("Bluetooth read error: $e");
    if (context.mounted) {
      Navigator.pop(context); // Ensure dialog is closed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bluetooth read error: $e")),
      );
    }
  }
}
