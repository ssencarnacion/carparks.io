import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'pages/dcs.dart';
import 'pages/demo.dart';
import 'pages/info.dart';
import 'pages/slot_service.dart';
void main() {
  runApp(const CarParksApp());
}

class CarParksApp extends StatelessWidget {
  const CarParksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'carparks.io',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E0F19),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.white54),
        ),
      ),
      home: const SearchPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  bool _tapped = false;
  Timer? timer;

  // List of connected parking lots
  // change apiKey and channelId as necessary
  List<Map<String, dynamic>> _parkingLots = [
    {
      'id': 'demo',
      'name': 'Demo Parking Lot',
      'address': 'Dragons\' Den Exhibition',
      'slots': 'Loading...',
      'page': const DemoParkingLotPage(),
      'apiKey': 'HNVUWEWNDFYKOWBA',
      'channelId': '2945987',
    },
    {
      'id': 'dcs',
      'name': 'DCS Parking Lot',
      'address': 'Velasquez St, UP Campus, Diliman, Quezon City',
      'slots': 'Loading...',
      'page': const DCSParkingLotPage(),
      'apiKey': 'HNVUWEWNDFYKOWBA',
      'channelId': '2945987',
    },
    {
      //debug page
      'id': 'info',
      'name': 'Info Page',
      'address': 'Check sensor information',
      'slots': 'n/n',
      'page': const InfoPage(),
    },
  ];

  @override
  void initState() {
    super.initState();
    updateParkingSlots();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => updateParkingSlots());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Get parking slot data from the cloud
  void updateParkingSlots() async {
    for (var lot in _parkingLots) {
      if (lot['id'] == 'dcs' || lot['id'] == 'demo') {
        final apiKey = lot['apiKey'];
        final channelId = lot['channelId'];

        final slots = await getSlotAvailability(
          apiKey: apiKey,
          channelId: channelId,
        );

        setState(() {
          lot['slots'] = slots['summary'];
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredLots {
    final query = _controller.text.toLowerCase();
    return _parkingLots.where((lot) {
      return lot['name'].toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'carparks.io',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                onTap: () => setState(() => _tapped = true),
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Where to park?',
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1C1D2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _tapped
                    ? ListView(
                  children: _filteredLots.map((lot) {
                    return Card(
                      color: const Color(0xFF1C1D2A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.white24),
                      ),
                      child: ListTile(
                        title: Text(
                          lot['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          lot['address'],
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: Text(
                          '${lot['slots']} Slots left',
                          style:
                          const TextStyle(color: Colors.greenAccent),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => lot['page']),
                          );
                        },
                      ),
                    );
                  }).toList(),
                )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
