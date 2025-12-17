import 'package:althfeth/utils/ConnectivityHelper.dart';
import 'package:althfeth/utils/LocalDatabase.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';


RxMap<String, dynamic> holidayData = RxMap<String, dynamic>();
RxList<Map<String, dynamic>> specialDaysData = RxList<Map<String, dynamic>>();
const int adminRole=2;

const String adminModEmail="m15_";
const String adminModPass="Mod_&&_12";
const int teacherRole=4;
const int committeeRole=5;
late LocalDatabase localDb;
late ConnectivityHelper connectivityHelper;
late Database db;



Map data_user_globle={};