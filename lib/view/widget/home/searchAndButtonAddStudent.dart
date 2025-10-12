import 'package:flutter/material.dart';

import '../../../constants/color.dart';
import '../../../controller/home_cont.dart';
import '../../screen/studentScreen/addStudent.dart';
import 'package:get/get.dart';
class SearchAndButtonAddStudent extends StatelessWidget {
  final  HomeCont homeCont=Get.find();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(

          child: TextField(
            onChanged: homeCont.filterStudents,
            decoration: InputDecoration(
              hintText: "ابحث عن الطالب...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () {
            Get.to(()=>Addstudent(),arguments: homeCont.dataArg);
          },
          icon: Icon(Icons.person_add,color: whiteColor,),
          label: Text("إضافة طالب",style: TextStyle(color: whiteColor),),
          style: ElevatedButton.styleFrom(
            backgroundColor:primaryGreen,
            padding:
            EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
