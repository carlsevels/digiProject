import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/detalles_folio.controller.dart';

class DetallesFolioScreen extends GetView<DetallesFolioController> {
  const DetallesFolioScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFF8FAFC),
      appBar: AppBar(backgroundColor: Color(0XFFF8FAFC)),
      body: const Center(
        child: Text(
          'DetallesFolioScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
