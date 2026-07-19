import 'package:bitacora_frontend/presentation/add_folios/localWidgets/inputText.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/add_refaccion.controller.dart';

class AddRefaccionScreen extends GetView<AddRefaccionController> {
  const AddRefaccionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AddRefaccionScreen'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InputText(
              title: "Refaccion",
              hintText: "Escribir nombre de la refaccion aqui",
              textController: controller.nombreController,
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 8),
            Container(
              width: Get.size.width,
              child: FilledButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  backgroundColor: const Color(0XFF1D6CFF),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  controller.postRefaccion();
                },
                child: Text("Agregar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
