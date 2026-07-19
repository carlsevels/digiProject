import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/clientes.controller.dart';

class ClientesScreen extends GetView<ClientesController> {
  const ClientesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClientesScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ClientesScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
