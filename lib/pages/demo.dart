import 'dart:async';
import 'package:flutter/material.dart';
import '../services/slot_service.dart';
class DemoParkingLotPage extends StatefulWidget {
  const DemoParkingLotPage({super.key});

  @override
  State<DemoParkingLotPage> createState() => _DemoParkingLotPageState();
}

class _DemoParkingLotPageState extends State<DemoParkingLotPage> {
  List<String> availableFields = [];
  String? availableSlots;
  bool isLoading = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => fetchData());
  }

  Future<void> fetchData() async {
    try {
      final result = await getSlotAvailability(
        id: 'demo'
      );
      setState(() {
        availableSlots = result['summary'];
        availableFields = result['availableFields'];
        isLoading = false;
      });
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
                  '$availableSlots',
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
    if (!isLoading && slotName.length > 1) {
      final slotNumber = slotName.substring(1);
      final slotKey = 'slot$slotNumber';
      final isSlotAvailable = availableFields.contains(slotKey);
      slotColor = isSlotAvailable ? Colors.green : Colors.red;
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