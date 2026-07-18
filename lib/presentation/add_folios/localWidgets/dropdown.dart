import 'package:flutter/material.dart';

class DropdownWidget<T> extends StatelessWidget {
  final String? title;
  final T? dropdownValue;
  final ValueChanged<T?>? onChanged;
  final List<DropdownMenuItem<T>> items;

  const DropdownWidget({
    required this.dropdownValue,
    required this.onChanged,
    this.title,
    this.items = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title != null
            ? Text(title!, style: TextStyle(color: Color(0XFF0F172A)))
            : SizedBox.shrink(),
        SizedBox(height: 8),
        Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
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
