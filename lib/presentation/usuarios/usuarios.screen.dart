import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/usuarios.controller.dart';

class UsuariosScreen extends GetView<UsuariosController> {
  const UsuariosScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UsuariosScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'UsuariosScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
