class Linkapi {
  // ==================== SERVER URL ====================
  // static const String server = "https://masart.io/alt/";
  static const String server = "http://192.168.118.65/alt/";


  // ==================== STUDENT APIs ====================
  
  // DELETE
  static const String delet_student_skills = "${server}student/delete.php?mark=delet_student_skills";










  // SELECT
  static const String select_levels = "${server}student/select.php?mark=select_levels";
  static const String select_ids_month = "${server}student/select.php?mark=select_ids_month";
  static const String select_students = "${server}student/select.php?mark=select_students";
  static const String select_students_attendance = "${server}student/select.php?mark=select_students_attendance";
  static const String check_attendance = "${server}student/select.php?mark=check_attendance";
  static const String select_attendance = "${server}student/select.php?mark=select_attendance";
  static const String select_data_student = "${server}student/select.php?mark=select_data_student";
  static const String select_daily_report = "${server}student/select.php?mark=select_daily_report";
  static const String select_review_report = "${server}student/select.php?mark=select_review_report";
  static const String select_absence_report = "${server}student/select.php?mark=select_absence_report";
  static const String select_reders = "${server}student/select.php?mark=select_reders";
  static const String select_qualification = "${server}student/select.php?mark=select_qualification";
  static const String select_skill = "${server}student/select.php?mark=select_skill";
  static const String select_student_skill = "${server}student/select.php?mark=select_student_skill";
  static const String select_student_plan = "${server}student/select.php?mark=select_student_plan";

  // UPDATE
  static const String updateAttendance = "${server}student/update.php?mark=updateAttendance";
  static const String update_Student = "${server}student/update.php?mark=update_Student";
  static const String update_student_skill = "${server}student/update.php?mark=update_student_skill";

  // INSERT
  static const String insertStudents = "${server}student/insert.php?mark=insertStudents";
  static const String insertAttendance = "${server}student/insert.php?mark=insertAttendance";
  static const String insert_student_skills = "${server}student/insert.php?mark=insert_student_skills";

  // ==================== USERS APIs ====================
  
  // SELECT

  static const String select_users = "${server}users/select.php?mark=select_users";
  static const String getstudents = "${server}users/select.php?mark=getstudents";
  static const String get_circle = "${server}users/select.php?mark=get_circle";
  static const String select_fromId_soura_with_to_soura = "${server}users/select.php?mark=select_fromId_soura_with_to_soura";
  static const String getLastDailyReport = "${server}users/select.php?mark=getLastDailyReport";
  static const String getLastReview = "${server}users/select.php?mark=getLastReview";
  static const String select_Holiday_Days = "${server}users/select.php?mark=select_Holiday_Days";
  static const String select_users_attendance_today = "${server}users/select.php?mark=select_users_attendance_today";
  static const String select_all_users_attendance_by_date = "${server}users/select.php?mark=select_all_users_attendance_by_date";
  static const String select_visits_type_months_years = "${server}users/select.php?mark=select_visits_type_months_years";
  static const String select_visitsed = "${server}users/select.php?mark=select_visitsed";
  static const String select_circle_for_center = "${server}users/select.php?mark=select_circle_for_center";
  static const String select_years = "${server}users/select.php?mark=select_years";
  static const String select_visits = "${server}users/select.php?mark=select_visits";
  static const String select_visit_results = "${server}users/select.php?mark=select_visit_results";
  static const String select_data_exam = "${server}users/select.php?mark=select_data_exam";
  static const String select_student_exam = "${server}users/select.php?mark=select_student_exam";
  static const String select_evaluations = "${server}users/select.php?mark=select_evaluations";
  static const String select_leave_requests = "${server}users/select.php?mark=select_leave_requests";
  static const String select_resignation_requests = "${server}users/select.php?mark=select_resignation_requests";
  static const String select_teacher_performance = "${server}users/select.php?mark=select_teacher_performance";
  static const String select_student_attendance = "${server}users/select.php?mark=select_student_attendance";
  static const String select_daily_recitation_report = "${server}users/select.php?mark=select_daily_recitation_report";
  static const String select_review_recitation_report = "${server}users/select.php?mark=select_review_recitation_report";
  static const String select_admin_absence_report = "${server}users/select.php?mark=select_absence_report";
  static const String select_comprehensive_student_performance = "${server}users/select.php?mark=select_comprehensive_student_performance";
  static const String select_circle_statistics = "${server}users/select.php?mark=select_circle_statistics";
  static const String select_comprehensive_circle_report = "${server}users/select.php?mark=select_comprehensive_circle_report";
  static const String select_circle_comparison = "${server}users/select.php?mark=select_circle_comparison";
  static const String select_visit_results_report = "${server}users/select.php?mark=select_visit_results_report";
  static const String select_visit_notes_report = "${server}users/select.php?mark=select_visit_notes_report";
  static const String select_visit_statistics_report = "${server}users/select.php?mark=select_visit_statistics_report";
  static const String select_teacher_evaluation_criteria = "${server}users/select.php?mark=select_teacher_evaluation_criteria";
  static const String select_students_evaluation_criteria = "${server}users/select.php?mark=select_students_evaluation_criteria";
  static const String add_administrative_visit = "${server}users/insert.php?mark=add_administrative_visit";
  static const String select_parents_contacts = "${server}users/select.php?mark=select_parents_contacts";
  static const String select_courses_typeWithSour_quran = "${server}users/select.php?mark=select_courses_typeWithSour_quran";
  static const String select_sour_quran = "${server}users/select.php?mark=select_sour_quran";
  static const String select_previous_visits = "${server}users/select.php?mark=select_previous_visits";
  static const String select_data_visit_previous = "${server}users/select.php?mark=select_data_visit_previous";
  static const String select_notes_for_teacher_by_circle = "${server}users/select.php?mark=select_notes_for_teacher_by_circle";

  // ==================== PROMOTION (ترفيع) APIs ====================
  static const String select_centers = "${server}users/select.php?mark=select_centers";
  static const String select_circles_by_center = "${server}users/select.php?mark=select_circles_by_center";
  static const String select_promotion_committee = "${server}users/select.php?mark=select_promotion_committee";
  static const String select_promotion_subjects = "${server}users/select.php?mark=select_promotion_subjects";
  static const String insert_promotion = "${server}users/insert.php?mark=insert_promotion";
  static const String select_my_promotions_pending = "${server}users/select.php?mark=select_my_promotions_pending";
  static const String select_promotion_details = "${server}users/select.php?mark=select_promotion_details";

  // INSERT
  static const String addDailyReport = "${server}users/insert.php?mark=addDailyReport";
  static const String addResignation = "${server}users/insert.php?mark=addResignation";
  static const String addReview = "${server}users/insert.php?mark=addReview";
  static const String add_check_in_time_usersAttendance = "${server}users/insert.php?mark=add_check_in_time_usersAttendance";
  static const String add_check_out_time_usersAttendance = "${server}users/insert.php?mark=add_check_out_time_usersAttendance";
  static const String add_substitute_attendance = "${server}users/insert.php?mark=add_substitute_attendance";
  static const String select_available_substitute_teachers = "${server}users/select.php?mark=select_available_substitute_teachers";
  static const String insert_visits = "${server}users/insert.php?mark=insert_visits";
  static const String insert_leave_requests = "${server}users/insert.php?mark=insert_leave_requests";
  static const String insert_visit_exam_result = "${server}users/insert.php?mark=insert_visit_exam_result";
  static const String insert_notes_for_teacher = "${server}users/insert.php?mark=insert_notes_for_teacher";
  static const String insert_public_visits = "${server}users/insert.php?mark=insert_public_visits";

  // UPDATE
  static const String updateDailyReport = "${server}users/update.php?mark=updateDailyReport";
  static const String updateReview = "${server}users/update.php?mark=updateReview";
  static const String update_visit_exam_result = "${server}users/update.php?mark=update_visit_exam_result";
  static const String update_notes_for_teacher = "${server}users/update.php?mark=update_notes_for_teacher";
}