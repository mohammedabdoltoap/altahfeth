import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/notesController.dart';
import '../../../constants/inline_loading.dart';

class NotesListScreen extends StatelessWidget {
  final NotesController notesController = Get.put(NotesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الملاحظات"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => notesController.refreshNotes(),
          ),
        ],
      ),
      body: Obx(() {
        if (notesController.isLoading.value) {
          return Center(child: InlineLoading());
        }

        if (notesController.notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  "لا توجد ملاحظات",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "لم يتم إضافة أي ملاحظات بعد",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => notesController.refreshNotes(),
                  icon: Icon(Icons.refresh),
                  label: Text("تحديث"),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => notesController.fetchNotes(),
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: notesController.notes.length,
            itemBuilder: (context, index) {
              final note = notesController.notes[index];
              return _buildNoteCard(context, note);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNoteCard(BuildContext context, Map<String, dynamic> note) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showNoteDetails(context, note),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with supervisor name and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note["supervisor_name"] ?? "غير محدد",
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "الموجهة",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        notesController.formatDate(note["note_date"] ?? ""),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getVisitTypeColor(note["visit_type"]).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          notesController.getVisitTypeText(note["visit_type"] ?? ""),
                          style: TextStyle(
                            color: _getVisitTypeColor(note["visit_type"]),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Note content preview
              Text(
                note["note_content"] ?? "",
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              // Read more indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "اضغط للمزيد",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getVisitTypeColor(String? visitType) {
    switch (visitType) {
      case 'regular':
        return Colors.green;
      case 'emergency':
        return Colors.red;
      case 'follow_up':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _showNoteDetails(BuildContext context, Map<String, dynamic> note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.note_alt,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "تفاصيل الملاحظة",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 16),
                
                // Supervisor info
                _buildDetailRow(
                  context,
                  "اسم الموجهة:",
                  note["supervisor_name"] ?? "غير محدد",
                  Icons.person,
                ),
                SizedBox(height: 12),
                
                // Visit type
                _buildDetailRow(
                  context,
                  "نوع الزيارة:",
                  notesController.getVisitTypeText(note["visit_type"] ?? ""),
                  Icons.event,
                ),
                SizedBox(height: 12),
                
                // Date
                _buildDetailRow(
                  context,
                  "تاريخ الملاحظة:",
                  notesController.formatDate(note["note_date"] ?? ""),
                  Icons.calendar_today,
                ),
                SizedBox(height: 16),
                
                // Note content
                Text(
                  "نص الملاحظة:",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    note["note_content"] ?? "لا يوجد محتوى",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(height: 20),
                
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("إغلاق"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor.withOpacity(0.7),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
