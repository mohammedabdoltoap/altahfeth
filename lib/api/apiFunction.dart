
import 'dart:convert';
import 'package:althfeth/constants/function.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

Future postData(String link, Map data) async {
  // ✅ Token ثابت (يمكن تغييره من السيرفر)
  const String token = "your_secret_token_here";

  // 🔍 طباعة تفاصيل الطلب
  // print('\n🌐 ========== طلب API ==========');
  // print('📍 URL: $link');
  // print('📦 البيانات المرسلة: ${jsonEncode(data)}');
  // print('================================\n');

  try {
    var response = await http.post(
      Uri.parse(link),
      body: jsonEncode(data), // تحويل Map إلى JSON
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // ✅ إضافة Token في Headers
      },
    );

    // // 🔍 طباعة تفاصيل الرد
    // print('\n📥 ========== رد السيرفر ==========');
    // print('📊 Status Code: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');
    // print('=====================================\n');

    // التحقق من حالة HTTP
    if (response.statusCode != 200 && response.statusCode != 201) {
      print('❌ خطأ HTTP: ${response.statusCode}');
      print('📄 محتوى الخطأ: ${response.body}');
      
      throw HttpException(
        'خطأ في الخادم: ${response.statusCode}',
        uri: Uri.parse(link),
      );
    }

    // محاولة فك تشفير JSON
    if (response.body.isEmpty) {
      print('⚠️ السيرفر أرجع رد فارغ');
      throw Exception('الخادم أرجع رد فارغ');
    }

    var responsbody = jsonDecode(response.body);

    return responsbody;
    
  } catch (e) {
    print('\n❌ ========== خطأ في postData ==========');
    print('🔴 نوع الخطأ: ${e.runtimeType}');
    print('📝 رسالة الخطأ: $e');
    print('📍 URL: $link');
    print('📦 البيانات: ${jsonEncode(data)}');
    print('=========================================\n');
    rethrow;
  }
}
