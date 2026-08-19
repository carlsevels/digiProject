import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/controllers/folios.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FolioWebView extends GetView<FoliosController> {
  final List<Folios> state;

  const FolioWebView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(
        0xFFF8FAFC,
      ), // Fondo general tipo dashboard corporativo
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER EMPRESARIAL ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      controller.obtenerEtiquetaFecha(
                        DateTime.tryParse(controller.fechaSeleccionada.value) ??
                            DateTime.now(),
                      ),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Gestión y seguimiento de folios activos en tiempo real",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(Routes.ADD_FOLIOS),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text("Agregar Folio"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF2563EB,
                  ), // Azul corporativo vibrante
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 440,
                mainAxisExtent: 140,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: state.length,
              itemBuilder: (context, index) {
                final folio = state[index];

                final int colorInt =
                    (folio.statusColor != null &&
                        folio.statusColor.toString().isNotEmpty)
                    ? (int.tryParse(folio.statusColor.toString()) ?? 0xFF64748B)
                    : 0xFF64748B;

                final Color statusColor = Color(colorInt);
                final bool isPorEntregar = folio.status == "Por entregar";

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        if (folio.folioId != null) {
                          Get.toNamed(
                            Routes.DETALLES_FOLIO,
                            arguments: folio.folioId.toString(),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Columna Izquierda: Insignia de Cantidad y Tipo
                            Container(
                              width: 70,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFF1F5F9),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    folio.cantidad.toString(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Text(
                                      folio.tiporefaccion?.toString() ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Columna Derecha: Información Principal
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Nombre Comercial
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.business_center_rounded,
                                        size: 15,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          folio.nombreComercial ??
                                              'Sin nombre comercial',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Municipio y Folio ID
                                  Row(
                                    children: [
                                      if (folio.municipio != null &&
                                          folio.municipio!
                                              .trim()
                                              .isNotEmpty) ...[
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 13,
                                          color: Color(0xFF94A3B8),
                                        ),
                                        const SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            folio.municipio!,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          " • ",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFCBD5E1),
                                          ),
                                        ),
                                      ],
                                      if (folio.folioId != null) ...[
                                        const Icon(
                                          Icons.tag_rounded,
                                          size: 13,
                                          color: Color(0xFF94A3B8),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          "${folio.folioId}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Badge de Estado Moderno
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPorEntregar
                                            ? statusColor.withOpacity(0.1)
                                            : statusColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        folio.status.toString(),
                                        style: TextStyle(
                                          color: isPorEntregar
                                              ? statusColor
                                              : Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
