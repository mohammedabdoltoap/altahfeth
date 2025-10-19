


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


Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String message,
  String title = "تأكيد",
  String yesText = "نعم",
  String noText = "لا",
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // يمنع الإغلاق بالضغط خارج الحوار
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(yesText),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.teal,
              side: BorderSide(color: Colors.teal),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(noText),
          ),
        ],
      );
    },
  );
}

Future del()async{
  await Future.delayed(Duration(seconds: 1));

}

checkApi(res,{massge="لايوجد بيانات",type="s"}){
  if(res["stat"]=="ok"){
    if(type=="s")
    return res["data"];
    if(type=="i")
      mySnackbar("تنبية", "تم الاضافة بنجاح",type: "g");
  }
  else if(res["stat"]=="no"){
    mySnackbar("تنبية", massge);
    return [];
  }
  else if(res["stat"]=="error"){
    mySnackbar("تنبية", "${res["msg"]}");
    return [];
  }
}

