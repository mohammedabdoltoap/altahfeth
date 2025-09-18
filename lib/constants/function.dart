


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';


mySnackbar( titile, messige,{type="r"}){
  if(type=="r")
   Get.snackbar("$titile", "$messige",colorText:Colors.white,backgroundColor: Colors.red,duration: Duration(seconds: 2));
  else if(type=="y")
    Get.snackbar("$titile", "$messige",colorText:Colors.white,backgroundColor: Colors.amberAccent,duration: Duration(seconds: 2));
  else
     Get.snackbar("$titile", "$messige",colorText:Colors.white,backgroundColor: Colors.green,duration: Duration(seconds: 2));
}