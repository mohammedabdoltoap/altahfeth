
import 'dart:convert';
import 'package:althfeth/constants/function.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

Future postData(String link, Map data) async {
  // ✅ Token ثابت (يمكن تغييره من السيرفر)
  const String token = "your_secret_token_here";

  var response = await http.post(
    Uri.parse(link),
    body: jsonEncode(data), // تحويل Map إلى JSON
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token", // ✅ إضافة Token في Headers
    },
  );

  // التحقق من حالة HTTP
  if (response.statusCode != 200 && response.statusCode != 201) {
    throw HttpException(
      'خطأ في الخادم: ${response.statusCode}',
      uri: Uri.parse(link),
    );
  }

  // محاولة فك تشفير JSON
  if (response.body.isEmpty) {
    throw Exception('الخادم أرجع رد فارغ');
  }

  var responsbody = jsonDecode(response.body);

  // التحقق من حالة API (stat)
  if (responsbody is Map && responsbody.containsKey('stat')) {
    if (responsbody['stat'] == 'error') {
      // خطأ من API (مثل خطأ في قاعدة البيانات)
      String errorMsg = responsbody['msg'] ?? 'حدث خطأ في الخادم';
      throw Exception('خطأ API: $errorMsg');
    } else if (responsbody['stat'] == 'no') {
      // لا توجد بيانات (ليس خطأ، لكن يمكن التعامل معه)
      return responsbody;
    }
  }

  return responsbody;
}
