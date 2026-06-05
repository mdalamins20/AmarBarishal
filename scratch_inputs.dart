import 'package:http/http.dart' as http;

void main() async {
  final res = await http.get(Uri.parse('https://www.shohoz.com/bus-tickets'));
  final body = res.body;
  
  // extract input elements
  final reg = RegExp(r'<input[^>]+>');
  final matches = reg.allMatches(body);
  for (var m in matches) {
    print(m.group(0));
  }
}
