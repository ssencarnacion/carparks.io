import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EEEIParkingLotPage extends StatefulWidget {
  const EEEIParkingLotPage({super.key});

  @override
  State<EEEIParkingLotPage> createState() => _EEEIParkingLotPageState();
}

class _EEEIParkingLotPageState extends State<EEEIParkingLotPage> {
  Map<String, String>? data;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(const Duration(seconds: 15), (_) => fetchData());
  }

  Future<void> fetchData() async {
    final url = Uri.parse(
      'https://api.thingspeak.com/channels/2945987/feeds.json?api_key=HNVUWEWNDFYKOWBA&results=1',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final feed = jsonData['feeds'][0];
        setState(() {
          data = {
            'field1': feed['field1'] ?? 'N/A',
            'field2': feed['field2'] ?? 'N/A',
          };
        });
      }
    } catch (e) {
     
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F19),
      appBar: AppBar(
        title: const Text('EEEI Parking Lot'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: data == null
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Distance 1: ${data!['field1']} cm',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Distance 2: ${data!['field2']} cm',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
