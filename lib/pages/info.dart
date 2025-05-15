import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'slot_service.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  Map<String, String>? data;
  String? availableSlots;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => fetchData());
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

        // Fetch slot data from slot_service
        final slots = await getSlotAvailability(
          apiKey: 'HNVUWEWNDFYKOWBA',
          channelId: '2945987',
        );

        setState(() {
          data = {
            'field1': feed['field1'] ?? 'N/A',
            'field2': feed['field2'] ?? 'N/A',
          };
          availableSlots = slots['summary'];
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
        title: const Text('Information Page'),
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
            const SizedBox(height: 16),
            Text(
              'Available Slots: ${availableSlots ?? "Loading..."}',
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
