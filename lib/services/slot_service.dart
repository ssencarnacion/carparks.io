import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
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
      if (distance >= 200) {
        available++;
        availableFields.add(key.toString());
      }
    }
  });

  return {
    'summary': '$available/$total',
    'availableFields': availableFields,
  };
}
