import 'package:flutter/material.dart';

class DCSParkingLotPage extends StatefulWidget {
  const DCSParkingLotPage({super.key});

  @override
  State<DCSParkingLotPage> createState() => _DCSParkingLotPageState();
}

class _DCSParkingLotPageState extends State<DCSParkingLotPage> {
  // All parking slots are available by default
  final List<bool> _parkingSlots = List.generate(16, (_) => true);

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
              // Title
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

              // Parking lot layout
              Expanded(
                child: Row(
                  children: [
                    // Left column (A1-A8)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(8, (index) {
                          final slotNumber = 8 - index; // A8 to A1
                          return _buildParkingSlot('A$slotNumber', _parkingSlots[slotNumber - 1]);
                        }),
                      ),
                    ),

                    // Center divider
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

                    // Right column (A9-A16)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(8, (index) {
                          final slotNumber = index + 9; // A9 to A16
                          return _buildParkingSlot('A$slotNumber', _parkingSlots[slotNumber - 1]);
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              // Entrance/Exit
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

              const SizedBox(height: 20),

              // Available slots counter
              Text(
                '${_parkingSlots.where((slot) => slot).length}/${_parkingSlots.length}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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

  Widget _buildParkingSlot(String slotName, bool isAvailable) {
    bool showUnderline = slotName != "A1" && slotName != "A16";

    return Column(
      children: [
        // Parking slot
        GestureDetector(
          onTap: () {
            // Toggle availability when tapped
            setState(() {
              final index = int.parse(slotName.substring(1)) - 1;
              _parkingSlots[index] = !_parkingSlots[index];
            });
          },
          child: Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              color: isAvailable ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                slotName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        if (showUnderline)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              width: 80,
              height: 1,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white30,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}