import 'package:get/get.dart';

/// 🗄️ مدير الذاكرة المؤقتة (Cache Manager)
/// يخزن البيانات مؤقتاً لتقليل الطلبات المتكررة للسيرفر
class CacheManager extends GetxController {
  static CacheManager get instance => Get.find<CacheManager>();
  
  // ⏰ مدة صلاحية الـ Cache (بالدقائق)
  final Map<String, int> _cacheDurations = {
    'students': 30,        // قائمة الطلاب - 30 دقيقة
    'evaluations': 1440,   // التقييمات - يوم كامل
    'surahs': 1440,        // السور - يوم كامل
    'circles': 60,         // الحلقات - ساعة
    'levels': 1440,        // المستويات - يوم كامل
    'user_data': 60,       // بيانات المستخدم - ساعة
  };
  
  // 📦 تخزين البيانات مع وقت الحفظ
  final Map<String, CacheEntry> _cache = {};
  
  /// ✅ حفظ بيانات في الـ Cache
  void set(String key, dynamic data, {int? durationMinutes}) {
    final duration = durationMinutes ?? _cacheDurations[key] ?? 30;
    _cache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      expiryMinutes: duration,
    );
    print('💾 تم حفظ "$key" في الـ Cache (صالح لـ $duration دقيقة)');
  }
  
  /// ✅ جلب بيانات من الـ Cache
  dynamic get(String key) {
    final entry = _cache[key];
    
    if (entry == null) {
      print('❌ "$key" غير موجود في الـ Cache');
      return null;
    }
    
    if (entry.isExpired) {
      print('⏰ "$key" انتهت صلاحيته - سيتم حذفه');
      _cache.remove(key);
      return null;
    }
    
    print('✅ تم جلب "$key" من الـ Cache');
    return entry.data;
  }
  
  /// ✅ التحقق من وجود بيانات صالحة
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }
  
  /// ✅ حذف عنصر محدد
  void remove(String key) {
    _cache.remove(key);
    print('🗑️ تم حذف "$key" من الـ Cache');
  }
  
  /// ✅ مسح كل الـ Cache
  void clear() {
    _cache.clear();
    print('🧹 تم مسح كل الـ Cache');
  }
  
  /// ✅ مسح الـ Cache المنتهي الصلاحية
  void cleanExpired() {
    final expiredKeys = _cache.entries
        .where((e) => e.value.isExpired)
        .map((e) => e.key)
        .toList();
    
    for (var key in expiredKeys) {
      _cache.remove(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      print('🧹 تم حذف ${expiredKeys.length} عنصر منتهي الصلاحية');
    }
  }
  
  /// 📊 عرض حالة الـ Cache
  void printStatus() {
    print('\n📊 ====== حالة الـ Cache ======');
    print('عدد العناصر: ${_cache.length}');
    _cache.forEach((key, entry) {
      final remaining = entry.remainingMinutes;
      print('  • $key: ${remaining > 0 ? "صالح ($remaining دقيقة)" : "منتهي"}');
    });
    print('================================\n');
  }
}

/// 📦 عنصر في الـ Cache
class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final int expiryMinutes;
  
  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.expiryMinutes,
  });
  
  bool get isExpired {
    final now = DateTime.now();
    final diff = now.difference(timestamp).inMinutes;
    return diff >= expiryMinutes;
  }
  
  int get remainingMinutes {
    final now = DateTime.now();
    final diff = now.difference(timestamp).inMinutes;
    return expiryMinutes - diff;
  }
}
