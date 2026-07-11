import 'package:bitacora_frontend/infrastructure/storage/user.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controllers/profile.controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Scaffold(
        appBar: AppBar(
          title: const Text('ProfileScreen'),
          centerTitle: true,
          actions: [EstadoConexionWidget(controller: controller)],
        ),
        body: Column(
          children: [
            Obx(
              () => Text(
                "Nombre: ${controller.nombreGuardado.value}",
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EstadoConexionWidget extends StatelessWidget {
  final ProfileController controller;

  const EstadoConexionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        // Obtenemos el estado de red de forma segura
        final results = snapshot.data ?? [ConnectivityResult.wifi];
        final bool isOffline = results.contains(ConnectivityResult.none);

        return Obx(() {
          if (isOffline) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.cloud_off, color: Colors.red),
            );
          }

          if (controller.subiendo.value) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.cloud_upload, color: Colors.orange),
            );
          }

          if (controller.bajando.value) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.cloud_download, color: Colors.blue),
            );
          }

          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.cloud_done, color: Colors.green),
          );
        });
      },
    );
  }
}
