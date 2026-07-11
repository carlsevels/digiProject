import 'package:bitacora_frontend/presentation/add_folios/controllers/add_folios.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DropdownWidget extends GetView<AddFoliosController> {
  final String? title;
  final int dropdownValue;
  final ValueChanged<int?>? onChanged;
  final List<DropdownMenuItem<int>>? items;
  const DropdownWidget({
    required this.dropdownValue,
    required this.onChanged,
    this.title,
    this.items,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title != null ? Text(title ?? "", style: TextStyle(color: Color(0XFF0F172A)),) : SizedBox.shrink(),
        SizedBox(height: 8),
        Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey, width: 1), // The outline
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: dropdownValue,
              icon: const Icon(Icons.keyboard_arrow_down),
              elevation: 16,
              style: const TextStyle(color: Color(0XFF64748B)),
              onChanged: onChanged,
              items: items,
            ),
          ),
        ),
      ],
    );
  }
}
