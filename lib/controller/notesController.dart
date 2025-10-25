import 'package:get/get.dart';
import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';

class NotesController extends GetxController {
  var notes = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final response = await handleRequest<dynamic>(
      isLoading: isLoading,
      loadingMessage: "جاري تحميل الملاحظات...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_notes_for_teacher, {});
      },
    );

    if (response == null) return;
    
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (response["stat"] == "ok") {
      notes.assignAll(List<Map<String, dynamic>>.from(response["data"]));
    } else {
      String errorMsg = response["msg"] ?? "تعذّر تحميل الملاحظات";
      mySnackbar("خطأ", errorMsg);
    }
  }

  void refreshNotes() {
    fetchNotes();
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  String getVisitTypeText(String visitType) {
    switch (visitType) {
      case 'regular':
        return 'زيارة عادية';
      case 'emergency':
        return 'زيارة طارئة';
      case 'follow_up':
        return 'زيارة متابعة';
      default:
        return visitType;
    }
  }
}
