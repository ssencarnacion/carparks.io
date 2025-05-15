import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getSlotAvailability({
  required String apiKey,
  required String channelId,
  int resultIndex = 1, // Get the latest reading
}) async {
  final url = Uri.parse(
    'https://api.thingspeak.com/channels/$channelId/feeds.json?api_key=$apiKey&results=$resultIndex',
  );

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final feed = data['feeds'][0];

      int available = 0;
      int total = 0;
      List<String> availableFields = [];

      feed.forEach((key, value) {
        if (key.startsWith('field')) {
          total++;
          final distance = double.tryParse(value ?? '') ?? 0.0;
          if (distance >= 200) { // We interpret this as a slot being free (accounts for timeouts: 999cm) *LIMITATION: we cannot check which sensors have broken down yet
            available++; // Count available slots
            availableFields.add(key); // Track available field
          }
        }
      });

      return {
        'summary': '$available/$total',
        'availableFields': availableFields,
      };
    }
  } catch (e) {
  }

  return {
    'summary': '0',
    'availableFields': [],
  };
}
