import 'package:firebase_database/firebase_database.dart';

Future<Map<String, dynamic>> getSlotAvailability({
  required String id,
}) async {
  final DatabaseReference ref = FirebaseDatabase.instance.ref().child(id);

  final snapshot = await ref.get();
  final data = snapshot.value as Map<dynamic, dynamic>;

  int available = 0;
  int total = 0;
  List<String> availableFields = [];

  data.forEach((key, value) {
    if (key.toString().startsWith('slot')) {
      total++;
      final distance = double.tryParse(value.toString()) ?? 0.0;
      if (distance >= 200) { // We interpret this as a slot being free (accounts for timeouts: 999cm)
        available++; // Count available slots
        availableFields.add(key.toString()); // Track all available slots
      }
    }
  });

  return {
    'summary': '$available/$total',
    'availableFields': availableFields,
  };
}
