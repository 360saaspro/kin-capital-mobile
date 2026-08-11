import 'dart:convert';
import 'dart:io';

void main() async {
  final apiKey = 'AQ.Ab8RN6Kv12eBviUWOq-C4agmxl5B0EnyswZuNDyVLcGuyBiIAg';
  final url = Uri.parse('https://stitch.googleapis.com/mcp');
  final client = HttpClient();

  stdin.transform(utf8.decoder).transform(const LineSplitter()).listen((line) async {
    if (line.isEmpty) return;

    try {
      final request = await client.postUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('x-goog-api-key', apiKey);
      request.write(line);
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      stdout.writeln(responseBody);
    } catch (e) {
      stderr.writeln('Error forwarding request: $e');
    }
  });
}
