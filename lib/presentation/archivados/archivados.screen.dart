import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/archivados.controller.dart';

class ArchivadosScreen extends GetView<ArchivadosController> {
  const ArchivadosScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ArchivadosScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ArchivadosScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
