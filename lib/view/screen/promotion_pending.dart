import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../constants/function.dart';
import '../../controller/promotion_controller.dart';
import 'promotion_screen.dart';
import '../../globals.dart';

class PromotionPendingScreen extends StatefulWidget {
  const PromotionPendingScreen({super.key});

  @override
  State<PromotionPendingScreen> createState() => _PromotionPendingScreenState();
}

class _PromotionPendingScreenState extends State<PromotionPendingScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {

    final idUser = data_user_globle['id_user'];

    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      useDialog: false,
      action: () async {
        return await postData(Linkapi.select_my_promotions_pending, {
          'id_user': idUser,
        });
      },
    );
    if (res is Map && res['stat'] == 'ok') {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return <Map<String, dynamic>>[];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الترفيعات المعلقة')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('لا توجد ترفيعات قيد الانتظار'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final item = list[i];
              return Material(
                color: Colors.white,
                elevation: 1,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    // افتح شاشة التعديل مع تحميل البيانات
                    final controller = Get.put(PromotionController());
                    final ok = await controller.loadPromotionForEdit(item['id_promotion'] as int);
                    if (ok) {
                      Get.to(() => PromotionScreen());
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.person, color: Theme.of(context).primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['student_name']?.toString() ?? 'طالب',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'حلقة: ${item['circle_name'] ?? '-'}',
                                style: TextStyle(color: Colors.grey[700], fontSize: 12),
                              ),
                              Text(
                                'تاريخ: ${item['promotion_date'] ?? '-'}',
                                style: TextStyle(color: Colors.grey[700], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit, color: Colors.blueGrey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


