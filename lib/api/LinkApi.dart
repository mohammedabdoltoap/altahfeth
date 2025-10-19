class Linkapi {


  static const String server = "http://192.168.102.65/alt/";


  //delete_student user
  static const String delet_student_skills = "${server}student/delete.php?mark=delet_student_skills";

















// select students
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
  static const String select_skill = "${server}student/select.php?mark=select_skill";
  static const String select_student_skill = "${server}student/select.php?mark=select_student_skill";

//update
  static const String updateAttendance = "${server}student/update.php?mark=updateAttendance";
  static const String update_Student = "${server}student/update.php?mark=update_Student";
  static const String update_student_skill = "${server}student/update.php?mark=update_student_skill";


  //insert student
  static const String insertStudents = "${server}student/insert.php?mark=insertStudents";
  static const String insertAttendance = "${server}student/insert.php?mark=insertAttendance";
  static const String insert_student_skills = "${server}student/insert.php?mark=insert_student_skills";


  // select

  static const String select_users = "${server}users/select.php?mark=select_users";
  static const String getstudents = "${server}users/select.php?mark=getstudents";
  static const String get_circle = "${server}users/select.php?mark=get_circle";
  static const String select_fromId_soura_with_to_soura = "${server}users/select.php?mark=select_fromId_soura_with_to_soura";
  static const String getLastDailyReport = "${server}users/select.php?mark=getLastDailyReport";
  static const String getLastReview = "${server}users/select.php?mark=getLastReview";
  static const String select_Holiday_Days = "${server}users/select.php?mark=select_Holiday_Days";
  static const String select_users_attendance_today = "${server}users/select.php?mark=select_users_attendance_today";
  static const String select_visits_type_months_years = "${server}users/select.php?mark=select_visits_type_months_years";
  static const String select_visitsed = "${server}users/select.php?mark=select_visitsed";
  static const String select_circle_for_center = "${server}users/select.php?mark=select_circle_for_center";
  static const String select_years = "${server}users/select.php?mark=select_years";
  static const String select_visits = "${server}users/select.php?mark=select_visits";
  static const String select_data_exam = "${server}users/select.php?mark=select_data_exam";
  static const String select_student_exam = "${server}users/select.php?mark=select_student_exam";
  static const String select_evaluations = "${server}users/select.php?mark=select_evaluations";
  static const String select_leave_requests = "${server}users/select.php?mark=select_leave_requests";
  static const String select_courses_typeWithSour_quran = "${server}users/select.php?mark=select_courses_typeWithSour_quran";
  static const String select_sour_quran = "${server}users/select.php?mark=select_sour_quran";
  static const String select_previous_visits = "${server}users/select.php?mark=select_previous_visits";
  static const String select_data_visit_previous = "${server}users/select.php?mark=select_data_visit_previous";
  static const String select_notes_for_teacher = "${server}users/select.php?mark=select_notes_for_teacher";


  //insert
  static const String addDailyReport = "${server}users/insert.php?mark=addDailyReport";
  static const String addResignation = "${server}users/insert.php?mark=addResignation";
  static const String addReview = "${server}users/insert.php?mark=addReview";
  static const String add_check_in_time_usersAttendance = "${server}users/insert.php?mark=add_check_in_time_usersAttendance";
  static const String add_check_out_time_usersAttendance = "${server}users/insert.php?mark=add_check_out_time_usersAttendance";
  static const String insert_visits = "${server}users/insert.php?mark=insert_visits";
  static const String insert_leave_requests = "${server}users/insert.php?mark=insert_leave_requests";
  static const String insert_visit_exam_result = "${server}users/insert.php?mark=insert_visit_exam_result";
  static const String insert_notes_for_teacher = "${server}users/insert.php?mark=insert_notes_for_teacher";

  //update
  static const String updateDailyReport = "${server}users/update.php?mark=updateDailyReport";
  static const String updateReview = "${server}users/update.php?mark=updateReview";
  static const String update_visit_exam_result = "${server}users/update.php?mark=update_visit_exam_result";
  static const String update_notes_for_teacher = "${server}users/update.php?mark=update_notes_for_teacher";

}