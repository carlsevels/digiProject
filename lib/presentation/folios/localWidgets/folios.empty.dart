import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/controllers/folios.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FoliosEmptyPage extends GetView<FoliosController> {
  final bool needDate;

  const FoliosEmptyPage({super.key, this.needDate = false});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff1D6CFF);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
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
                    const SizedBox(height: 24),

                    // Fecha dinámica opcional
                    if (needDate) ...[
                      Obx(
                        () => Text(
                          controller.obtenerEtiquetaFecha(
                            DateTime.tryParse(
                                  controller.fechaSeleccionada.value,
                                ) ??
                                DateTime.now(),
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    Text(
                      "No hay folios",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                        letterSpacing: -.6,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Todavía no has registrado ningún folio para el día seleccionado.\nEmpieza creando el primero.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(.08),
                        borderRadius: BorderRadius.circular(100),
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
                              fontSize: 13,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(), // Distribuye el espacio de forma equilibrada

                    if (needDate)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton.icon(
                            onPressed: () {
                              Get.toNamed(
                                Routes.ADD_FOLIOS,
                                arguments: {
                                  'fecha': controller.fechaSeleccionada.value,
                                },
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text(
                              "Crear nuevo folio",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
