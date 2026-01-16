import 'dart:async';

/// ⏱️ Debouncer - يؤخر تنفيذ دالة حتى يتوقف المستخدم عن الكتابة
/// يقلل عدد الاستعلامات بشكل كبير
class Debouncer {
  final int milliseconds;
  Timer? _timer;
  
  Debouncer({this.milliseconds = 500});
  
  /// تنفيذ الدالة بعد فترة انتظار
  void run(void Function() action) {
    // إلغاء المؤقت السابق
    _timer?.cancel();
    
    // إنشاء مؤقت جديد
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
  
  /// إلغاء المؤقت
  void cancel() {
    _timer?.cancel();
  }
  
  /// التخلص من الموارد
  void dispose() {
    _timer?.cancel();
  }
}

/// ⏱️ Throttler - يسمح بتنفيذ الدالة مرة واحدة فقط في فترة زمنية محددة
/// مفيد للأحداث المتكررة مثل Scroll
class Throttler {
  final int milliseconds;
  Timer? _timer;
  bool _isReady = true;
  
  Throttler({this.milliseconds = 1000});
  
  /// تنفيذ الدالة إذا كان مسموحاً
  void run(void Function() action) {
    if (_isReady) {
      action();
      _isReady = false;
      
      _timer = Timer(Duration(milliseconds: milliseconds), () {
        _isReady = true;
      });
    }
  }
  
  /// إلغاء المؤقت
  void cancel() {
    _timer?.cancel();
    _isReady = true;
  }
  
  /// التخلص من الموارد
  void dispose() {
    _timer?.cancel();
  }
}
