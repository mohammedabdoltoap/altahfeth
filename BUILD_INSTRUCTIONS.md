# تعليمات بناء تطبيق مسارات (Althfeth)

## 📱 معلومات التطبيق
- **اسم التطبيق**: مسارات (Althfeth)
- **Package Name**: com.example.althfeth
- **الإصدار**: 1.0.0+1

## 🔐 معلومات التوقيع (Keystore)
- **الموقع**: `android/app/upload-keystore.jks`
- **Alias**: upload
- **Store Password**: althfeth2024
- **Key Password**: althfeth2024
- **الصلاحية**: 10,000 يوم

## 📦 ملف APK الجاهز
تم بناء APK بنجاح في المسار التالي:
```
build\app\outputs\flutter-apk\app-release.apk
```
**الحجم**: 26.3 MB

## 🚀 كيفية بناء APK جديد

### 1. تنظيف المشروع (اختياري)
```bash
flutter clean
```

### 2. بناء APK للإصدار
```bash
flutter build apk --release
```

### 3. بناء APK مقسم حسب البنية (أصغر حجماً)
```bash
flutter build apk --split-per-abi
```
سينتج عن هذا 3 ملفات APK:
- `app-armeabi-v7a-release.apk` (للأجهزة القديمة 32-bit)
- `app-arm64-v8a-release.apk` (للأجهزة الحديثة 64-bit)
- `app-x86_64-release.apk` (للمحاكيات)

### 4. بناء App Bundle (للنشر على Google Play)
```bash
flutter build appbundle --release
```

## ⚙️ الإعدادات المطبقة

### ✅ إعدادات التوقيع
- تم إنشاء keystore جديد
- تم تكوين `key.properties`
- تم تحديث `build.gradle` للتوقيع التلقائي

### ✅ إعدادات التحسين
- **minifyEnabled**: تفعيل تصغير الكود
- **shrinkResources**: إزالة الموارد غير المستخدمة
- **ProGuard**: تم تطبيق قواعد الحماية

### ✅ الصلاحيات
- `INTERNET`: للاتصال بالإنترنت
- `ACCESS_NETWORK_STATE`: لفحص حالة الشبكة
- `usesCleartextTraffic`: للسماح بـ HTTP

## 📝 ملاحظات مهمة

### 🔒 الأمان
1. **لا ترفع** ملف `key.properties` على Git (محمي تلقائياً)
2. **احتفظ بنسخة احتياطية** من ملف `upload-keystore.jks`
3. **لا تشارك** كلمات المرور مع أحد

### 🔄 التحديثات المستقبلية
لتحديث رقم الإصدار، عدّل ملف `pubspec.yaml`:
```yaml
version: 1.0.1+2  # 1.0.1 هو رقم الإصدار، 2 هو رقم البناء
```

### 📤 توزيع التطبيق
يمكنك الآن:
1. ✅ إرسال ملف APK مباشرة لأي شخص
2. ✅ رفعه على موقعك الخاص
3. ✅ نشره على متاجر التطبيقات البديلة
4. ⚠️ للنشر على Google Play، استخدم App Bundle بدلاً من APK

## 🛠️ استكشاف الأخطاء

### مشكلة: "Keystore file not found"
**الحل**: تأكد من وجود ملف `upload-keystore.jks` في `android/app/`

### مشكلة: "Invalid keystore format"
**الحل**: أعد إنشاء keystore باستخدام:
```bash
cd android
.\create-keystore.bat
```

### مشكلة: حجم APK كبير
**الحل**: استخدم split APKs:
```bash
flutter build apk --split-per-abi
```

## 📞 الدعم
للمزيد من المساعدة، راجع:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)

---
**تاريخ الإنشاء**: 27 أكتوبر 2025
**تم البناء بواسطة**: Cascade AI
