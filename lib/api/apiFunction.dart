
import 'dart:convert';
import 'package:althfeth/constants/function.dart';
import 'package:http/http.dart' as http;

Future postData(String link, Map data) async {
  var response = await http.post(
    Uri.parse(link),
  body: jsonEncode(data), // تحويل Map إلى JSON
    headers: {"Content-Type": "application/json"},
  );

  var responsbody = jsonDecode(response.body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    return responsbody;
  } else {
    return response.statusCode;
  }
}
