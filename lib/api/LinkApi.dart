class Linkapi {


  static const String server = "http://192.168.177.65/alt/";

// select students
  static const String select_levels = "${server}student/select.php?mark=select_levels";
  static const String select_ids_month = "${server}student/select.php?mark=select_ids_month";

  //insert student
  static const String insertStudents = "${server}student/insert.php?mark=insertStudents";


  // select

  static const String select_users = "${server}users/select.php?mark=select_users";
  static const String get_circle_and_students = "${server}users/select.php?mark=get_circle_and_students";
  static const String select_fromId_soura_with_to_soura = "${server}users/select.php?mark=select_fromId_soura_with_to_soura";
  static const String selectYearsWithMonths = "${server}users/select.php?mark=selectYearsWithMonths";

  //insert
  static const String addPlan = "${server}users/insert.php?mark=addPlan";

}