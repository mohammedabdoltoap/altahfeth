import 'package:althfeth/constants/function.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../globals.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  static Database? _database;

  factory LocalDatabase() {
    return _instance;
  }

  LocalDatabase._internal();

  /// الحصول على instance من LocalDatabase
  static LocalDatabase get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'alt.db');

    return await openDatabase(
      path,
      version: 10,
      onConfigure: (db)async {},
      onCreate: _createTables,
      onUpgrade: _upgradeTables,
      onOpen: (a)async{
        // await deleteDatabase(path);

        }

    );
  }

  Future<void> _createTables(Database db, int version) async {

      print("Create");
      // جدول المستخدم الحالي
      await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id_user INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        phone TEXT  NULL,
        email TEXT  NULL,
        password TEXT NOT NULL,
        status INTEGER,
        created_at TEXT NULL,
        last_login TEXT ,
        role_id INTEGER,
        id_employee INTEGER
      )
    ''');

      // جدول الحلقات المحلية
      await db.execute('''
      CREATE TABLE IF NOT EXISTS circles (
        id_circle INTEGER PRIMARY KEY,
        id_center INTEGER,
        id_user INTEGER,
        name_circle TEXT NOT NULL,
        status INTEGER,
        region_id INTEGER
      )
    ''');
      await db.execute('''
  CREATE TABLE IF NOT EXISTS users_attendance (
  id_server INTEGER ,
  id_local INTEGER PRIMARY KEY AUTOINCREMENT,
  id_user INTEGER,
  id_circle INTEGER,
  attendance_date TEXT,     
  check_in_time TEXT,         
  check_out_time TEXT NULL,
  attendance_status INTEGER,
  stat TEXT

 )
    ''');
      await db.execute('''
CREATE TABLE IF NOT EXISTS students (
    id_student INTEGER PRIMARY KEY AUTOINCREMENT,
    name_student TEXT,
    surname TEXT,
    address_student TEXT,
    place_of_birth TEXT,
    date_of_birth TEXT,
    phone TEXT,
    school_name TEXT,
    classroom TEXT,
    guardian TEXT,
    id_circle INTEGER,
    jop TEXT,
    id_stages INTEGER,
    id_level INTEGER,
    status TEXT,
    date TEXT,
    sex TEXT,
    id_qualification INTEGER,
    chronic_diseases TEXT,
    id_reder INTEGER,
    password TEXT,
    name_level TEXT,
    name_stages TEXT,
    can_read INTEGER
)
''');

      await db.execute('''
CREATE TABLE IF NOT EXISTS region_special_days (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
   region_id INTEGER,
    day_date TEXT,
    EndDate TEXT NULL,
    is_work_day INTEGER ,
    description TEXT,
    type TEXT
   
)
''');
      await db.execute('''
CREATE TABLE IF NOT EXISTS region_weekend_days (
   region_id INTEGER,
   day_of_week TEXT
)
''');
      await db.execute('''
CREATE TABLE IF NOT EXISTS daily_report (

   id_daily_report INTEGER,
   id_local INTEGER PRIMARY KEY AUTOINCREMENT,
   id_student INTEGER,
   from_id_soura INTEGER,
   from_id_aya INTEGER,
   to_id_soura INTEGER,
   to_id_aya INTEGER,
   id_user INTEGER,
   id_circle INTEGER,
   date TEXT,
   mark INTEGER,
   id_evaluation INTEGER,
   stat INTEGER
)
''');
      await db.execute('''
CREATE TABLE IF NOT EXISTS sour_quran (
   id_soura INTEGER,
   soura_name TEXT,
   active INTEGER,
   from_page INTEGER,
   to_page INTEGER,
   soura_no INTEGER,
   ayat_count INTEGER
)
''');
      await db.execute('''
CREATE TABLE IF NOT EXISTS level(
   id_level INTEGER,
   id_stages INTEGER,
   name_level TEXT,
   amount INTEGER,
   amount_value INTEGER,
   from_id_soura INTEGER,
   to_id_soura INTEGER,
   from_id_aya INTEGER,
   to_id_aya INTEGER,
   duration_days INTEGER
)
''');
      await db.execute('''
CREATE TABLE IF NOT EXISTS evaluations(
   id_evaluation INTEGER,
   name_evaluation TEXT
)
''');
      await db.execute('''
CREATE TABLE IF NOT EXISTS review (
   id_review INTEGER,
   id_local INTEGER PRIMARY KEY AUTOINCREMENT,
   id_student INTEGER,
   from_id_soura INTEGER,
   from_id_aya INTEGER,
   to_id_soura INTEGER,
   to_id_aya INTEGER,
   id_user INTEGER,
   id_circle INTEGER,
   mark TEXT,
   id_evaluation INTEGER,
   date TEXT,
   stat INTEGER
)
''');
      await db.execute('''
CREATE TABLE IF NOT EXISTS student_attendance (
   id_attendance INTEGER,
   id_local INTEGER PRIMARY KEY AUTOINCREMENT,
   id_student INTEGER,
   date TEXT,
   id_circle INTEGER,
   id_user INTEGER,
   status INTEGER,
   notes TEXT,
   stat INTEGER
)
''');

      print('✅ تم إنشاء جداول قاعدة البيانات المحلية');
      // ملاحظة: ملء الجداول يتم في LoginController._checkAndInitializeDatabase()
      // وليس هنا لتجنب مشاكل التهيئة


  }



  Future addSourQoran()async{
    var sour_quranAll=await handleRequest(
      loadingMessage: "جاري تنزيل وتهية بيانات النظام الاساسية...",
      useDialog: true,
      immediateLoading: true,
      isLoading: RxBool(false), action: ()async {
      return await postData(Linkapi.select_sour_quranAll, {});
    },) ;

    if(sour_quranAll ==null) return;

    if(sour_quranAll["stat"]=="ok") {
      for (int i = 0; i < sour_quranAll["data"].length; i++) {
        await db.insert("sour_quran", sour_quranAll["data"][i]);
      }
    }else{
      mySnackbar("تنبية", "خطا في جلب سور القران تحقق من الانترنت ");
    }

  }
  Future addLevel()async{
    var levels=await handleRequest(
      loadingMessage: "جاري تنزيل وتهية بيانات النظام الاساسية...",
      useDialog: false,
      immediateLoading: true,
      isLoading: RxBool(false), action: ()async {
      return await postData(Linkapi.select_levelsAll, {});
    },) ;

    if(levels ==null) return;


    if(levels["stat"]=="ok") {
      for (int i = 0; i < levels["data"].length; i++) {
        await _database?.insert("level", levels["data"][i]);
      }
    }else{
      mySnackbar("تنبية", "خطا في جلب المستويات تحقق من الانترنت ");
    }
    print("secondQuery========${await db.rawQuery("select * from level")}");

  }
  Future select_evaluations() async {

      final res = await handleRequest<dynamic>(
        isLoading: RxBool(false),
        // loadingMessage: "جاري تحميل التقييمات...",
        useDialog: false,
        action: () async {
          return await postData(Linkapi.select_evaluations, {});
        },
      );

      if (res == null) return;
      if (res is! Map) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        return;
      }

      if (res["stat"] == "ok") {
        final evaluations = List<Map<String, dynamic>>.from(res["data"]);
        for(int i=0; i<evaluations.length; i++){
          await _database?.insert("evaluations", evaluations[i]);
        }

        print(await _database?.rawQuery("select * from evaluations"));
      } else {
        String errorMsg = res["msg"] ?? "خطأ في جلب التقييمات";
        mySnackbar("خطأ", errorMsg);
      }



  }

  /// 🔄 ترقية قاعدة البيانات (إضافة جداول جديدة)
  Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
    print('🔄 ترقية قاعدة البيانات من v$oldVersion إلى v$newVersion');

  }






}
