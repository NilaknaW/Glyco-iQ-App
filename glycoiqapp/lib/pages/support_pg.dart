import 'package:flutter/material.dart';
import '../helper/database_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  // fetch data from local database
  List<Map<String, dynamic>> contacts = [];
  bool _isEditMode = false; // Controls edit mode

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  void loadContacts() async {
    final data = await DatabaseHelper().getContacts();
    setState(() => contacts = data);
  }

  void addContact(String name, String phone, String rel) async {
    if (contacts.length < 3) {
      await DatabaseHelper().insertContact(name, phone, rel);
      loadContacts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only add up to 3 contacts!')),
      );
    }
  }

  void deleteContact(int id) async {
    await DatabaseHelper().deleteContact(id);
    loadContacts();
  }

  void toggleEditMode() {
    setState(() => _isEditMode = !_isEditMode);
  }

  // add methods to save and delete contacts
  void _showAddContactDialog() {
    String name = '', phone = '', relation = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (value) => name = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
              onChanged: (value) => phone = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Relation'),
              onChanged: (value) => relation = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (name.isNotEmpty && phone.isNotEmpty && relation.isNotEmpty) {
                addContact(name, phone, relation);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          topicLine(context, toggleEditMode),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return supportCard(
                  id: contact['id'],
                  name: contact['name'],
                  phone: contact['phone'],
                  rel: contact['rel'],
                  showDelete: _isEditMode,
                  onDelete: deleteContact,
                );
              },
            ),
          ),
          if (_isEditMode && contacts.length < 3)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: FilledButton.icon(
                onPressed: _showAddContactDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Contact'),
              ),
            ),
        ],
      ),
    );
  }

  Widget topicLine(BuildContext context, Function onEditContact) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          const Text('Emergency Contacts', style: TextStyle(fontSize: 20)),
          const Spacer(),
          IconButton(
            onPressed: () => onEditContact(), // Add Contact Popup
            icon: Icon(_isEditMode ? Icons.check : Icons.edit), // Edit Button
          ),
        ],
      ),
    );
  }

  Widget supportCard(
      {required int id,
      required String name,
      required String phone,
      required String rel,
      required bool showDelete,
      required Function(int) onDelete}) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card.filled(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ListTile(
              title: Text(name),
              subtitle: Text(phone),
              // trailing: Text(rel),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(rel),
                  if (showDelete)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(id),
                    ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: FilledButton(
                onPressed: () =>
                    _makePhoneCall(phone), // add calling action here
                child: const Icon(Icons.call),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not launch $url";
    }
  }
}
