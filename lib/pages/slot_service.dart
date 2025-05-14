import 'dart:convert';
import 'package:http/http.dart' as http;
// Service for DCS parking slots, TODO: make it more general-purpose
// probably just ask for the API_key instead of making 1 for every parking lot
Future<String> fetchDcsSlots() async {
  final url = Uri.parse(
      'https://api.thingspeak.com/channels/2945987/feeds.json?api_key=HNVUWEWNDFYKOWBA&results=1');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final feed = data['feeds'][0];

      int available = 0;
      int total = 0;

      feed.forEach((key, value) {
        if (key.startsWith('field')) {
          total++;
          final distance = double.tryParse(value ?? '') ?? 0.0; //if reading exceeds 200cm (or 999cm : no reading), it means parking space is free
          if (distance >= 200.0) available++;
        }
      });

      return '$available/$total';
    }
  } catch (e) {
  }

  return '0';
}
