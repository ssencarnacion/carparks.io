import 'dart:convert';
import 'package:http/http.dart' as http;

class ThingSpeakService {
  final String apiKey = 'HNVUWEWNDFYKOWBA';

  Future<Map<String, dynamic>> fetchData() async {
    final url = Uri.parse('https://api.thingspeak.com/channels/2945987/feeds.json?api_key=$apiKey&results=1');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch data from ThingSpeak');
    }
  }
}
