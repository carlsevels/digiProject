import 'package:bitacora_frontend/presentation/add_folios/controllers/add_folios.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputText extends GetView<AddFoliosController> {
  final String title;
  final String hintText;
  final TextEditingController? textController;
  final TextInputType? keyboardType;
  final Widget? externalButton; 

  const InputText({
    super.key,
    required this.title,
    required this.hintText,
    this.textController,
    this.keyboardType,
    this.externalButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0XFF0F172A))),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: Row(
            children: [
              // El input ocupa todo el espacio restante
              Expanded(
                child: TextFormField(
                  keyboardType: keyboardType,
                  controller: textController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(fontSize: 14, color: Color(0XFF64748B)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
              
              if (externalButton != null) ...[
                const SizedBox(width: 8),
                externalButton!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}