import 'package:althfeth/constants/function.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityHelper extends GetxController {
  static ConnectivityHelper get instance => Get.find<ConnectivityHelper>();

  final Connectivity _connectivity = Connectivity();
  final RxBool isOnline = true.obs;
  final RxString connectionStatus = 'متصل'.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _listenToConnectivityChanges();
  }

  /// فحص الاتصال الأولي
  Future<void> _checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      // results هي List<ConnectivityResult> في الإصدار الجديد
      if (results.isNotEmpty) {
        _updateConnectionStatus(results.first);
      }
    } catch (e) {
      // print('❌ خطأ في فحص الاتصال: $e');
      mySnackbar("خطأ في فحص الاتصال❌", "$e");
      isOnline.value = true; // افترض أن هناك اتصال في حالة الخطأ
    }
  }

  /// الاستماع لتغييرات الاتصال
  void _listenToConnectivityChanges() {
    _connectivity.onConnectivityChanged.listen((results) {
      // results هي List<ConnectivityResult> في الإصدار الجديد
      if (results.isNotEmpty) {
        _updateConnectionStatus(results.first);
      }
    });
  }

  /// تحديث حالة الاتصال
  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      isOnline.value = false;
      connectionStatus.value = 'بدون اتصال';
      print('📡 الحالة: بدون اتصال إنترنت');
    } else if (result == ConnectivityResult.mobile) {
      isOnline.value = true;
      connectionStatus.value = 'متصل (بيانات الهاتف)';
      print('📡 الحالة: متصل عبر بيانات الهاتف');
    } else if (result == ConnectivityResult.wifi) {
      isOnline.value = true;
      connectionStatus.value = 'متصل (WiFi)';
      print('📡 الحالة: متصل عبر WiFi');
    }
  }

  /// التحقق من الاتصال الحالي
  bool get hasConnection => isOnline.value;

  /// الحصول على حالة الاتصال
  String get status => connectionStatus.value;
}
