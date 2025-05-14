import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DCSParkingLotPage extends StatefulWidget {
  const DCSParkingLotPage({super.key});

  @override
  State<DCSParkingLotPage> createState() => _DCSParkingLotPageState();
}

class _DCSParkingLotPageState extends State<DCSParkingLotPage> {
  // Add connected sensor fields
  String? field1; // A6
  String? field2; // A5

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

  // Check if the value of a field is exceeds to 200.00000 cm (no detected object: FREE!)
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
                'DCS',
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
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(8, (index) {
                          final slotNumber = 8 - index; // A8 to A1
                          return _buildParkingSlot('A$slotNumber');
                        }),
                      ),
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: 1,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(8, (index) {
                          final slotNumber = index + 9; // A9 to A16
                          return _buildParkingSlot('A$slotNumber');
                        }),
                      ),
                    ),
                  ],
                ),
              ),
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

    // Variable slot color according to availability
    if (!isLoading) {
      if (slotName == "A5") {
        slotColor = isAvailable(field2) ? Colors.green : Colors.red;
      } else if (slotName == "A6") {
        slotColor = isAvailable(field1) ? Colors.green : Colors.red;
      }
    }

    return Column(
      children: [
        Container(
          width: 80,
          height: 40,
          decoration: BoxDecoration(
            color: slotColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              contentText,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (slotName != "A1" && slotName != "A16")
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              width: 80,
              height: 1,
              color: Colors.white30,
            ),
          ),
      ],
    );
  }
}
