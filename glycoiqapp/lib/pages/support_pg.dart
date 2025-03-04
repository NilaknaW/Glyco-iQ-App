import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          topicLine(),
          Expanded(
            flex: 1,
            child:
                supportCard(name: 'Name', phone: '0776662244', rel: 'Family'),
          ),
          Expanded(
            flex: 1,
            child:
                supportCard(name: 'Name', phone: '0776662244', rel: 'Spouse'),
          ),
          Expanded(
            flex: 1,
            child:
                supportCard(name: 'Name', phone: '0776662244', rel: 'Doctor'),
          ),
        ],
      ),
    );
  }
}

Widget topicLine() {
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
  return Container(
    padding: const EdgeInsets.only(bottom: 10),
    child: Card.filled(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ListTile(
            title: Text(name),
            subtitle: Text(phone),
            trailing: Text(rel),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: FilledButton(
              onPressed: () {},
              child: const Icon(Icons.call),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: const [Text('Call'), Icon(Icons.call)],
              // ),
            ),
          ),
        ],
      ),
    ),
  );
}
