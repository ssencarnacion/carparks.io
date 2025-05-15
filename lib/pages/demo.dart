import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DemoParkingLotPage extends StatefulWidget {
  const DemoParkingLotPage({super.key});

  @override
  State<DemoParkingLotPage> createState() => _DemoParkingLotPageState();
}

class _DemoParkingLotPageState extends State<DemoParkingLotPage> {
  String? field1; // A1
  String? field2; // A2

  int availableSlots = 0;
  bool isLoading = true;
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

        final String? f1 = feed['field1'];
        final String? f2 = feed['field2'];

        int count = 0;
        if (isAvailable(f1)) count++;
        if (isAvailable(f2)) count++;

        setState(() {
          field1 = f1 ?? 'N/A';
          field2 = f2 ?? 'N/A';
          availableSlots = count;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  bool isAvailable(String? value) {
    if (value == null) return false;

    final parsedValue = double.tryParse(value);
    if (parsedValue == null) return false;

    return parsedValue >= 200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F19),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                'Demo',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Parking Lot',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Row(
                  children: [
                    // A1 slot
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildParkingSlot('A1'),
                        ],
                      ),
                    ),
                    // Divider
                    Container(
                      width: 2,
                      color: Colors.white54,
                      height: double.infinity,
                    ),
                    // A2 slot
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildParkingSlot('A2'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Entrance/Exit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 80,
                alignment: Alignment.center,
                child: isLoading
                    ? const Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  '$availableSlots/2',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Text(
                'Slots Available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParkingSlot(String slotName) {
    Color slotColor = Colors.grey;
    String contentText = slotName;

    if (!isLoading) {
      if (slotName == "A1") {
        slotColor = isAvailable(field1) ? Colors.green : Colors.red;
      } else if (slotName == "A2") {
        slotColor = isAvailable(field2) ? Colors.green : Colors.red;
      }
    }

    return Container(
      width: 120,
      height: 100,
      decoration: BoxDecoration(
        color: slotColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          contentText,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
