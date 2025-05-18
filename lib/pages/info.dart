import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final DatabaseReference _demoRef =
  FirebaseDatabase.instance.ref().child('demo');

  String field1 = 'Loading...';
  String field2 = 'Loading...';

  @override
  void initState() {
    super.initState();
    _demoRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        field1 = data['slot1'].toString();
        field2 = data['slot2'].toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F19),
      appBar: AppBar(
        title: const Text('Realtime Data'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Distance 1: $field1 cm',
                style: const TextStyle(fontSize: 24, color: Colors.white)),
            const SizedBox(height: 20),
            Text('Distance 2: $field2 cm',
                style: const TextStyle(fontSize: 24, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
