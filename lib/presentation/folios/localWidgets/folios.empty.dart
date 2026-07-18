import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/controllers/folios.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FoliosEmptyPage extends GetView<FoliosController> {
  bool needDate = false;
  FoliosEmptyPage({super.key, required this.needDate});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff1D6CFF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(.08),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 58,
              color: primary,
            ),
          ),
          const SizedBox(height: 40),
          if (needDate == true)
            Column(
              children: [
                Text(
                  controller.obtenerEtiquetaFecha(
                    DateTime.tryParse(controller.fechaSeleccionada.value) ??
                        DateTime.now(),
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),

          Text(
            "No hay folios",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
              letterSpacing: -.6,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            "Todavía no has registrado ningún folio para el día seleccionado.\nEmpieza creando el primero.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(.08),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  "Todo está al día",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          if (controller.rolUsuario.value == 1)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  Get.toNamed(Routes.ADD_FOLIOS);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  "Crear nuevo folio",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
