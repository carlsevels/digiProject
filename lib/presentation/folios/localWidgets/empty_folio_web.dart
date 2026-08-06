import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/controllers/folios.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebFoliosEmptyPage extends GetView<FoliosController> {
  final bool needDate;
  
  const WebFoliosEmptyPage({super.key, required this.needDate});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff1D6CFF);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- ICONO CON EFECTO DE PROFUNDIDAD ---
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withOpacity(.08),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 52,
                  color: primary,
                ),
              ),
              const SizedBox(height: 32),

              // --- FECHA REACTIVA (MEJORA: Actualiza al cambiar de fecha) ---
              if (needDate) ...[
                Obx(
                  () => Text(
                    controller.obtenerEtiquetaFecha(
                      DateTime.tryParse(controller.fechaSeleccionada.value) ??
                          DateTime.now(),
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // --- TÍTULO ---
              const Text(
                "No hay folios",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // --- DESCRIPCIÓN ---
              const Text(
                "Todavía no has registrado ningún folio para el día seleccionado.\nEmpieza creando el primero.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),

              // --- BADGE INFORMATIVO ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(.08),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.green.withOpacity(.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Todo está al día",
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // --- BOTÓN DE ACCIÓN WEB ---
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: () {
                    Get.toNamed(Routes.ADD_FOLIOS);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add, size: 20, color: Colors.white),
                  label: const Text(
                    "Crear nuevo folio",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}