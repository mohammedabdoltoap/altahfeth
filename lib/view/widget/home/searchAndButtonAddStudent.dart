import 'package:flutter/material.dart';

import '../../../controller/home_cont.dart';
import '../../screen/studentScreen/addStudent.dart';
import 'package:get/get.dart';
import '../../../constants/customTextField.dart';
import '../../../constants/appButton.dart';
class SearchAndButtonAddStudent extends StatefulWidget {
  final TextEditingController? controller;
  const SearchAndButtonAddStudent({super.key, this.controller});
  @override
  State<SearchAndButtonAddStudent> createState() => _SearchAndButtonAddStudentState();
}

class _SearchAndButtonAddStudentState extends State<SearchAndButtonAddStudent> {
  final HomeCont homeCont = Get.find();
  late final TextEditingController _searchCtrl;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _searchCtrl = widget.controller ?? homeCont.textEditingController;
  }

  @override
  void dispose() {
    if (_ownsController) {
      _searchCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: _searchCtrl,
            label: "البحث",
            hint: "ابحث عن الطالب...",
            prefixIcon: Icons.search,
            onChanged: homeCont.filterStudents,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 150,
          child: AppButton(
            text: "إضافة طالب",
            onPressed: () {
              Get.to(() => Addstudent(), arguments: homeCont.dataArg);
            },
            height: 50,
          ),
        ),
      ],
    );
  }
}
