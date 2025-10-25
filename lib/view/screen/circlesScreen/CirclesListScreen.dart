import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/circlesController.dart';
import '../../../constants/inline_loading.dart';
import '../notesScreen/NotesListScreen.dart';

class CirclesListScreen extends StatelessWidget {
  final CirclesController circlesController = Get.put(CirclesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("اختر الحلقة"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => circlesController.refreshCircles(),
          ),
        ],
      ),
      body: Obx(() {
        if (circlesController.isLoading.value) {
          return Center(child: InlineLoading());
        }

        if (circlesController.circles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  "لا توجد حلقات",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "لم يتم تعيين أي حلقات لك بعد",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => circlesController.refreshCircles(),
                  icon: Icon(Icons.refresh),
                  label: Text("تحديث"),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => circlesController.fetchCircles(),
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: circlesController.circles.length,
            itemBuilder: (context, index) {
              final circle = circlesController.circles[index];
              return _buildCircleCard(context, circle);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCircleCard(BuildContext context, Map<String, dynamic> circle) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToNotes(context, circle),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.group,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          circle["name_circle"] ?? "حلقة غير محددة",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "رقم الحلقة: ${circle["id_circle"] ?? "غير محدد"}",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).primaryColor,
                    size: 16,
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.note_alt,
                      size: 16,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "عرض الملاحظات",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToNotes(BuildContext context, Map<String, dynamic> circle) {
    // تمرير بيانات الحلقة مع بيانات المستخدم
    var arguments = {
      ...circlesController.dataArg,
      "id_circle": circle["id_circle"],
      "circle_name": circle["name_circle"],
    };
    
    Get.to(() => NotesListScreen(), arguments: arguments);
  }
}
