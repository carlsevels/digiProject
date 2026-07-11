import 'package:bitacora_frontend/presentation/add_folios/controllers/add_folios.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputText extends GetView<AddFoliosController> {
  final String title;
  final String hintText;
  final TextEditingController? textController;
  InputText({
    super.key,
    required this.title,
    required this.hintText,
    this.textController,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Color(0XFF0F172A))),
        SizedBox(height: 8),
        Container(
          height: 40,
          child: TextFormField(
            controller: textController,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hintText,

              hintStyle: TextStyle(fontSize: 14, color: Color(0XFF64748B)),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
