import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/add_usuario.controller.dart';

class AddUsuarioScreen extends GetView<AddUsuarioController> {
  const AddUsuarioScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('AddUsuarioScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AddUsuarioScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
