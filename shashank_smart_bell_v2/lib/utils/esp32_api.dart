import 'package:http/http.dart' as http;

class ESP32Api {
  static const String esp32Url = 'http://192.168.4.1'; // replace with your ESP32 IP

  static Future<void> sendCodeToESP32(String code) async {
    final url = Uri.parse('$esp32Url/upload');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'text/plain'},
      body: code,
    );

    if (response.statusCode != 200) {
      throw Exception('ESP32 error: ${response.statusCode} ${response.reasonPhrase}');
    }
  }
}