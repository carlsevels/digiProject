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
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
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
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Gestión y seguimiento de folios activos",
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(Routes.ADD_FOLIOS),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text("Agregar Folio"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFF1D6CFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- CUADRÍCULA DE TARJETAS PROFESIONALES ---
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent:
                    420, // Ancho ideal para tarjetas web compactas
                mainAxisExtent:
                    130, // Altura óptima para acomodar la información
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: state.length,
              itemBuilder: (context, index) {
                final folio = state[index];

                final int colorInt =
                    (folio.statusColor != null &&
                        folio.statusColor.toString().isNotEmpty)
                    ? (int.tryParse(folio.statusColor.toString()) ?? 0xFF9E9E9E)
                    : 0xFF9E9E9E;

                return Material(
                  color: Colors.white,
                  elevation: 1,
                  shadowColor: Colors.black.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
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
                          // Columna Izquierda: Cantidad y Tipo con diseño de insignia
                          // Columna Izquierda: Cantidad y Tipo
                          Container(
                            width: 65,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  folio.cantidad.toString(),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    folio.tiporefaccion?.toString() ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
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
                                      Icons.business_center_outlined,
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
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Municipio y Folio
                                Row(
                                  children: [
                                    if (folio.municipio != null &&
                                        folio.municipio!.trim().isNotEmpty) ...[
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 13,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 2),
                                      Flexible(
                                        child: Text(
                                          folio.municipio!,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        " • ",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                    if (folio.folioId != null) ...[
                                      const Icon(
                                        Icons.confirmation_number_outlined,
                                        size: 13,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        "#${folio.folioId}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Estado de la orden / Badge
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: folio.status != "Por entregar"
                                          ? Color(colorInt)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Color(colorInt),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      folio.status.toString(),
                                      style: TextStyle(
                                        color: folio.status == "Por entregar"
                                            ? Color(colorInt)
                                            : Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
