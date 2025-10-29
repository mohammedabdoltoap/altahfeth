<?php
// ========== أضف في switch case ==========
case "select_student_plan":
    select_student_plan();
    break;

// ========== أضف الدالة ==========
function select_student_plan(){
    global $con;
    
    if (!isset($_POST['id_student']) || empty($_POST['id_student'])) {
        echo json_encode(array("stat" => "error", "msg" => "معرف الطالب مطلوب"));
        return;
    }

    $id_student = intval($_POST['id_student']);

    $sql = "SELECT 
                sp.id,
                sp.id_student,
                sp.stage_id,
                sp.level_id,
                sp.level_detail_id,
                sp.start_date,
                sp.end_date,
                sp.days,
                s.name_stages AS stage_name,
                l.name_level AS level_name,
                ld.name AS level_detail_name
            FROM student_plan sp
            LEFT JOIN stages s ON sp.stage_id = s.id_stages
            LEFT JOIN level l ON sp.level_id = l.id_level
            LEFT JOIN level_detail ld ON sp.level_detail_id = ld.id
            WHERE sp.id_student = :id_student
            ORDER BY sp.start_date DESC";

    $result = $con->prepare($sql);
    $result->bindParam(':id_student', $id_student, PDO::PARAM_INT);
    $result->execute();
    
    if ($result) {
        $r = $result->fetchAll(PDO::FETCH_ASSOC);
        if (count($r) > 0) {
            echo json_encode(array("stat" => "ok", "data" => $r, "count" => count($r)));
        } else {
            echo json_encode(array("stat" => "no", "msg" => "لا توجد خطة لهذا الطالب"));
        }
    } else {
        echo json_encode(array("stat" => "error", "msg" => "خطأ في الاستعلام"));
    }
}

?>

<!-- 
========================================
SQL لإنشاء جدول student_plan (إذا لم يكن موجوداً)
========================================

CREATE TABLE IF NOT EXISTS `student_plan` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_student` int(11) NOT NULL,
  `stage_id` int(11) DEFAULT NULL,
  `level_id` int(11) DEFAULT NULL,
  `level_detail_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `days` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_student` (`id_student`),
  KEY `idx_stage` (`stage_id`),
  KEY `idx_level` (`level_id`),
  KEY `idx_level_detail` (`level_detail_id`),
  CONSTRAINT `fk_student_plan_student` FOREIGN KEY (`id_student`) REFERENCES `students` (`id_student`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

========================================
بيانات تجريبية للاختبار
========================================

INSERT INTO `student_plan` (`id_student`, `stage_id`, `level_id`, `level_detail_id`, `start_date`, `end_date`, `days`) VALUES
(1, 1, 1, 1, '2025-01-01', '2025-03-31', 90),
(1, 1, 2, 2, '2025-04-01', '2025-06-30', 91),
(2, 2, 3, 3, '2025-01-15', '2025-04-15', 90);

-->
