# 📚 API Documentation - Althfeth App

## 🌐 Server URL
```
http://192.168.174.65/alt/
```

---

## 📋 Table of Contents
1. [Student APIs](#student-apis)
2. [Users APIs](#users-apis)
3. [Response Format](#response-format)

---

## 🎓 Student APIs

### SELECT Operations
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `select_levels` | جلب المستويات | - |
| `select_ids_month` | جلب أرقام الأشهر | - |
| `select_students` | جلب الطلاب | `id_circle` |
| `select_students_attendance` | جلب حضور الطلاب | `id_circle`, `date` |
| `check_attendance` | التحقق من الحضور | `id_circle`, `date` |
| `select_attendance` | جلب سجل الحضور | `id_student` |
| `select_data_student` | جلب بيانات طالب | `id_student` |
| `select_daily_report` | جلب التقرير اليومي | `id_student` |
| `select_review_report` | جلب تقرير المراجعة | `id_student` |
| `select_absence_report` | جلب تقرير الغياب | `id_student` |
| `select_reders` | جلب القراء | - |
| `select_skill` | جلب المهارات | - |
| `select_student_skill` | جلب مهارات طالب | `id_student` |

### UPDATE Operations
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `updateAttendance` | تحديث الحضور | `id_student`, `date`, `status` |
| `update_Student` | تحديث بيانات طالب | `id_student`, ... |
| `update_student_skill` | تحديث مهارة طالب | `id_student_skill`, `avaluation` |

### INSERT Operations
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `insertStudents` | إضافة طالب جديد | `name_student`, `id_circle`, ... |
| `insertAttendance` | إضافة حضور | `id_student`, `date`, `status` |
| `insert_student_skills` | إضافة مهارة لطالب | `id_student`, `id_skill`, `avaluation` |

### DELETE Operations
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `delet_student_skills` | حذف مهارة طالب | `id_student_skill` |

---

## 👥 Users APIs

### SELECT Operations

#### 👤 User & Circle
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `select_users` | جلب المستخدمين | `username`, `password` |
| `getstudents` | جلب الطلاب | `id_circle` |
| `get_circle` | جلب الحلقة | `id_user` |
| `select_circle_for_center` | جلب حلقات المركز | `id_center` |

#### 📊 Attendance
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `select_users_attendance_today` | جلب حضور المستخدمين اليوم | `date` |

#### 📝 Reports
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `getLastDailyReport` | جلب آخر تقرير يومي | `id_student` |
| `getLastReview` | جلب آخر مراجعة | `id_student` |

#### 📖 Quran
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `select_fromId_soura_with_to_soura` | جلب السور من إلى | `from_id`, `to_id` |
| `select_courses_typeWithSour_quran` | جلب أنواع الدورات مع السور | `id_course` |
| `select_sour_quran` | جلب جميع السور | - |

#### 🏖️ Holidays
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `select_Holiday_Days` | جلب أيام العطل | - |

#### 🏢 Visits
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `select_visits_type_months_years` | جلب أنواع الزيارات والأشهر والسنوات | - |
| `select_years` | جلب السنوات | - |
| `select_visits` | جلب الزيارات | `id_user` |
| `select_visitsed` | جلب الزيارات المنفذة | `id_user` |
| `select_previous_visits` | جلب الزيارات السابقة | `id_circle` or `id_user` |
| `select_data_visit_previous` | جلب بيانات زيارة سابقة | `id_visit`, `id_circle` |

#### 📊 Exams & Results
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `select_data_exam` | جلب بيانات الاختبار | `id_visit`, `id_circle` |
| `select_student_exam` | جلب اختبار طالب | `id_student`, `id_visit` |
| `select_visit_results` | **جلب نتائج الزيارة** | `id_visit` |

#### ⭐ Evaluations
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `select_evaluations` | جلب التقييمات | - |

#### 🏖️ Leave Requests
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `select_leave_requests` | جلب طلبات الإجازة | `id_user` |

#### 📝 Notes
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `select_notes_for_teacher` | جلب ملاحظات للمعلم | `id_visit` |
| `select_notes_for_teacher_by_circle` | جلب ملاحظات حسب الحلقة | `id_circle` |

### INSERT Operations
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `addDailyReport` | إضافة تقرير يومي | ... |
| `addResignation` | إضافة طلب استقالة | `id_user`, `reason`, `date` |
| `addReview` | إضافة مراجعة | ... |
| `add_check_in_time_usersAttendance` | تسجيل دخول | `id_user`, `date`, `time` |
| `add_check_out_time_usersAttendance` | تسجيل خروج | `id_user`, `date`, `time` |
| `insert_visits` | إضافة زيارة | ... |
| `insert_leave_requests` | **إضافة طلب إجازة** | `id_user`, `date_leave`, `reason_leave`, `leave_type`, `end_date?` |
| `insert_visit_exam_result` | إضافة نتيجة اختبار | ... |
| `insert_notes_for_teacher` | إضافة ملاحظة | `id_visit`, `notes` |

### UPDATE Operations
| Endpoint | Description | Parameters |
|----------|-------------|------------|
| `updateDailyReport` | تحديث تقرير يومي | ... |
| `updateReview` | تحديث مراجعة | ... |
| `update_visit_exam_result` | تحديث نتيجة اختبار | ... |
| `update_notes_for_teacher` | تحديث ملاحظة | `id_visit`, `notes` |

---

## 📤 Response Format

### Success Response
```json
{
  "stat": "ok",
  "data": [...]
}
```

### No Data Response
```json
{
  "stat": "no",
  "msg": "رسالة توضيحية"
}
```

### Error Response
```json
{
  "stat": "error",
  "msg": "رسالة الخطأ"
}
```

### Exist Response (للتحقق من التكرار)
```json
{
  "stat": "exist",
  "msg": "رسالة توضيحية"
}
```

---

## 🆕 New Features Added

### 1. Leave Requests (طلبات الإجازة)
- ✅ دعم يوم واحد أو فترة
- ✅ حقول: `leave_type` (single/period), `end_date`
- ✅ التحقق من التداخل في التواريخ

### 2. Visit Results (نتائج الزيارات)
- ✅ عرض نتائج الطلاب للزيارات الفنية
- ✅ تصدير PDF مع خط عربي
- ✅ معلومات كاملة: الحفظ، التلاوة، الشهري، المراجعة

---

## 🔧 Database Schema

### Table: `leave_requests`
```sql
CREATE TABLE leave_requests (
  id_leave INT(11) AUTO_INCREMENT PRIMARY KEY,
  id_user INT(11) NOT NULL,
  reason_leave VARCHAR(50) NOT NULL,
  date_leave DATE NOT NULL,
  leave_type ENUM('single', 'period') DEFAULT 'single',
  end_date DATE NULL,
  date_request DATE DEFAULT CURRENT_TIMESTAMP,
  status INT(11) DEFAULT 0
);
```

### Table: `visit_exam_result`
```sql
-- يحتوي على نتائج الاختبارات للزيارات الفنية
-- الحقول: id_visit, id_student, hifz_monthly, tilawa_monthly, 
--         from_id_soura_monthly, to_id_soura_monthly, etc.
```

---

## 📱 Flutter Usage Example

```dart
// جلب نتائج الزيارة
var res = await postData(Linkapi.select_visit_results, {
  "id_visit": 98,
});

// إضافة طلب إجازة
var res = await postData(Linkapi.insert_leave_requests, {
  "id_user": 4,
  "date_leave": "2025-10-24",
  "reason_leave": "سبب الإجازة",
  "leave_type": "period",
  "end_date": "2025-10-26"
});
```

---

## ✅ API Checklist

- [x] جميع APIs منظمة ومرتبة
- [x] التعليقات واضحة في PHP و Dart
- [x] معالجة الأخطاء محسنة
- [x] استجابات موحدة
- [x] دعم اللغة العربية
- [x] توثيق كامل

---

**Last Updated:** October 24, 2025
**Version:** 1.0.0
