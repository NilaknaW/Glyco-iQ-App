import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  // add methods to save and delete contacts

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          topBar(),
          supportCard(name: 'Name', phone: '0776662244', rel: 'Family'),
          const SizedBox(height: 10),
          supportCard(name: 'Name', phone: '0776662244', rel: 'Spouse'),
          const SizedBox(height: 10),
          supportCard(name: 'Name', phone: '0776662244', rel: 'Doctor'),
        ],
      ),
    );
  }
}

Widget topBar() {
  return Container(
    padding: const EdgeInsets.all(10),
    child: Row(
      children: [
        const Text('Emergency Contacts', style: TextStyle(fontSize: 20)),
        const Spacer(),
        IconButton(
          onPressed: () {}, // add actions
          icon: const Icon(Icons.add),
        ),
      ],
    ),
  );
}

Widget supportCard({
  required String name,
  required String phone,
  required String rel,
}) {
  return Card(
      child: Column(
    children: [
      ListTile(
        title: Text(name),
        subtitle: Text(phone),
        trailing: Text(rel),
      ),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () {},
          child: const Text('Call'),
        ),
      ),
      const SizedBox(height: 10),
    ],
  ));
}
