# دليل استخدام handleRequest مع returnErrorResponse

## المشكلة السابقة
عندما يحدث خطأ في الخادم أو الشبكة، كانت دالة `handleRequest` ترجع `null`، مما يجعل من الصعب التمييز بين أنواع الأخطاء المختلفة.

## الحل الجديد
تم إضافة معامل جديد `returnErrorResponse` إلى دالة `handleRequest` يضمن إرجاع استجابة موحدة حتى في حالة الأخطاء.

## كيفية الاستخدام

### الطريقة القديمة (غير موصى بها)
```dart
final response = await handleRequest<dynamic>(
  isLoading: isLoading,
  action: () async {
    return await postData(Linkapi.some_endpoint, {});
  },
);

if (response == null) return; // لا نعرف نوع الخطأ
```

### الطريقة الجديدة (موصى بها)
```dart
final response = await handleRequest<dynamic>(
  isLoading: isLoading,
  returnErrorResponse: true, // تفعيل الميزة الجديدة
  action: () async {
    return await postData(Linkapi.some_endpoint, {});
  },
);

// الآن response لن يكون null أبداً
if (response == null || response is! Map) {
  mySnackbar("خطأ", "فشل الاتصال بالخادم");
  return;
}

// معالجة الاستجابة بشكل موحد
if (response["stat"] == "ok") {
  // نجاح العملية
  var data = response["data"];
  // معالجة البيانات...
} else if (response["stat"] == "error") {
  // خطأ في الخادم أو الشبكة
  String errorMsg = response["msg"] ?? "حدث خطأ في الاتصال";
  mySnackbar("خطأ", errorMsg);
} else if (response["stat"] == "no") {
  // لا توجد بيانات
  mySnackbar("تنبيه", response["msg"] ?? "لا توجد بيانات");
}
```

## أنواع الأخطاء التي يتم إرجاعها

عند تفعيل `returnErrorResponse: true`، ستحصل على استجابة موحدة بالشكل التالي:

### 1. خطأ في الاتصال بالإنترنت
```dart
{
  "stat": "error",
  "msg": "لا يوجد اتصال بالإنترنت"
}
```

### 2. انتهاء مهلة الاتصال
```dart
{
  "stat": "error",
  "msg": "انتهت مهلة الاتصال. تحقق من الإنترنت وحاول مرة أخرى"
}
```

### 3. فشل الاتصال بالخادم
```dart
{
  "stat": "error",
  "msg": "فشل الاتصال بالخادم. تحقق من الإنترنت"
}
```

### 4. خطأ في تنسيق البيانات
```dart
{
  "stat": "error",
  "msg": "خطأ في تنسيق البيانات المستلمة"
}
```

### 5. خطأ غير متوقع
```dart
{
  "stat": "error",
  "msg": "حدث خطأ غير متوقع أثناء العملية"
}
```

## مثال كامل من loginController

```dart
Future<void> select_data_user() async {
  if (isLoading.value) return;
  
  if (usernameController.text.trim().isEmpty || passwordController.text.isEmpty) {
    mySnackbar("تنبيه", "ادخل البيانات المطلوبة", type: "y");
    return;
  }

  final response = await handleRequest<dynamic>(
    isLoading: isLoading,
    loadingMessage: "جاري تسجيل الدخول...",
    useDialog: false,
    immediateLoading: true,
    returnErrorResponse: true, // ✅ تفعيل الميزة
    action: () async {
      return await postData(Linkapi.select_users, {
        "username": usernameController.text.trim(),
        "password": passwordController.text.trim(),
      });
    },
  );

  if (response == null || response is! Map) {
    mySnackbar("خطأ", "فشل الاتصال بالخادم");
    return;
  }

  if (response["stat"] == "ok") {
    // معالجة النجاح
    data_user = response["data"];
    // الانتقال للصفحة المناسبة...
  } else if (response["stat"] == "error") {
    // معالجة أخطاء الخادم/الشبكة
    String errorMsg = response["msg"] ?? "حدث خطأ في الاتصال بالخادم";
    mySnackbar("خطأ", errorMsg);
  } else {
    // معالجة أخطاء تسجيل الدخول
    String errorMsg = response["msg"] ?? "اسم المستخدم أو كلمة المرور خاطئة";
    mySnackbar("خطأ", errorMsg);
  }
}
```

## متى تستخدم returnErrorResponse؟

✅ **استخدمه في:**
- صفحات تسجيل الدخول
- العمليات الحساسة التي تحتاج معالجة دقيقة للأخطاء
- الصفحات التي تحتاج التمييز بين أخطاء الخادم وأخطاء البيانات
- التقارير والعمليات المهمة

❌ **لا تستخدمه في:**
- العمليات البسيطة التي لا تحتاج معالجة خاصة للأخطاء
- الحالات التي يكفي فيها عرض رسالة خطأ عامة

## ملاحظات مهمة

1. **الميزة اختيارية**: القيمة الافتراضية لـ `returnErrorResponse` هي `false` للحفاظ على التوافق مع الكود القديم.

2. **يعمل فقط مع `T == dynamic`**: هذه الميزة مصممة للعمل مع الاستجابات الديناميكية (Map).

3. **رسائل الخطأ تُعرض تلقائياً**: `ErrorHandler` يتولى عرض رسائل الخطأ، لكن يمكنك عرض رسائل إضافية حسب الحاجة.

4. **التوافق مع الكود القديم**: جميع الاستدعاءات القديمة لـ `handleRequest` ستستمر في العمل بدون تغيير.

## توصيات للتطبيق على بقية الصفحات

يُنصح بتطبيق هذه الميزة تدريجياً على:
1. ✅ صفحات تسجيل الدخول (تم)
2. صفحات التقارير
3. صفحات إضافة/تعديل البيانات المهمة
4. صفحات الحضور والغياب
5. صفحات الطلبات (إجازات، استقالات، إلخ)

## مثال للتطبيق على التقارير

```dart
Future<void> loadData() async {
  final response = await handleRequest<dynamic>(
    isLoading: loading,
    returnErrorResponse: true,
    action: () async {
      return await postData(Linkapi.some_report, {
        "month": selectedMonth.value.toString(),
        "year": selectedYear.value.toString(),
      });
    },
  );

  if (response == null || response is! Map) {
    mySnackbar("خطأ", "فشل تحميل التقرير");
    dataList.clear();
    return;
  }

  if (response['stat'] == 'ok') {
    if (response['data'] != null && response['data'] is List) {
      dataList.assignAll(List<Map<String, dynamic>>.from(response['data']));
      mySnackbar("نجح", "تم تحميل ${dataList.length} سجل", type: "g");
    } else {
      dataList.clear();
      mySnackbar("تنبيه", "لا توجد بيانات");
    }
  } else if (response['stat'] == 'error') {
    dataList.clear();
    mySnackbar("خطأ", response['msg'] ?? "حدث خطأ في تحميل البيانات");
  } else if (response['stat'] == 'no') {
    dataList.clear();
    mySnackbar("تنبيه", "لا توجد بيانات لهذه الفترة");
  }
}
```
