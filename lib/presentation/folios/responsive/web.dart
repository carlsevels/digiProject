import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/controllers/detalles_folio.controller.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/responsive/detallesFolio_wev.dart';
import 'package:bitacora_frontend/presentation/folios/controllers/folios.controller.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/direccionDialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebFolioView extends GetView<FoliosController> {
  final List<Folios> state;

  const WebFolioView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;

        return SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        controller.obtenerEtiquetaFecha(
                          DateTime.tryParse(
                                controller.fechaSeleccionada.value,
                              ) ??
                              DateTime.now(),
                        ),
                        style: TextStyle(
                          fontSize: isDesktop ? 26 : 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF1D6CFF),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 20 : 12,
                          vertical: isDesktop ? 14 : 10,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Get.toNamed(Routes.ADD_FOLIOS);
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: Text(
                        "Agregar Folio",
                        style: TextStyle(
                          fontSize: isDesktop ? 15 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: isDesktop
                      ? _buildResponsiveShortView()
                      : _buildResponsiveLongView(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveShortView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. COLUMNA IZQUIERDA: LISTA DE FOLIOS
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: state.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final folio = state[index];

                final statusColor = Color(
                  int.tryParse(folio.statusColor?.toString() ?? '') ??
                      0xFF1D6CFF,
                );

                return Obx(() {
                  final isSelected =
                      controller.folioSeleccionado.value?.folioId ==
                      folio.folioId;

                  return InkWell(
                    onTap: () {
                      controller.folioSeleccionado.value = folio;
                      if (folio.id != null && folio.id!.isNotEmpty) {
                        controller.historialFolio(folio.id!);
                      }
                      if (Get.isRegistered<DetallesFolioController>()) {
                        Get.delete<DetallesFolioController>();
                      }
                      Get.put(DetallesFolioController());
                    },
                    onLongPress: () {
                      direccionDialog(folio: folio);
                    },
                    hoverColor: const Color(0xFFF8FAFC),
                    child: Container(
                      color: isSelected
                          ? const Color(0xFFEFF6FF)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  folio.cantidad.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: Text(
                                    folio.tiporefaccion.toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  folio.nombreComercial ??
                                      'Sin nombre comercial',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Folio: ${folio.folioId ?? 'N/A'} • ${folio.municipio ?? ''}",
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: folio.status != "Por entregar"
                                  ? statusColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              folio.status.toString(),
                              style: TextStyle(
                                color: folio.status == "Por entregar"
                                    ? statusColor
                                    : Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ),

        const SizedBox(width: 20),

        // 2. COLUMNA DERECHA: DETALLE WEB
        Expanded(
          flex: 6,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() {
              final folioActivo = controller.folioSeleccionado.value;

              if (folioActivo == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 48,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Selecciona un folio de la lista\npara ver sus detalles aquí",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    color:  Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Detalle: #${folioActivo.folioId ?? ''}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                          onPressed: () async {
                            controller.folioSeleccionado.value = null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  Expanded(
                    child: SizedBox.expand(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: DetallesFolioWebView(state: folioActivo),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveLongView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: state.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final folio = state[index];
          final statusColor = Color(
            int.tryParse(folio.statusColor?.toString() ?? '') ?? 0xFF1D6CFF,
          );

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                // 1. Asignamos el folio seleccionado
                controller.folioSeleccionado.value = folio;

                // 2. Consultamos el historial correctamente para alimentar ambas listas
                if (folio.id != null && folio.id!.isNotEmpty) {
                  await controller.historialFolio(folio.id!);
                }

                // 3. Manejamos el ciclo de vida del controlador de detalles
                if (Get.isRegistered<DetallesFolioController>()) {
                  Get.delete<DetallesFolioController>();
                }
                Get.put(DetallesFolioController());

                // 4. Mostramos el BottomSheet clásico con los detalles completos
                Get.bottomSheet(
                  Container(
                    height: MediaQuery.of(context).size.height * 0.85,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Barra superior del BottomSheet
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Detalle: #${folio.folioId ?? ''}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Get.back(),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        // Contenido del detalle
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: DetallesFolioWebView(state: folio),
                          ),
                        ),
                      ],
                    ),
                  ),
                  isScrollControlled: true,
                );
              },
              onLongPress: () {
                direccionDialog(folio: folio);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            folio.cantidad.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.0,
                            ),
                            child: Text(
                              folio.tiporefaccion.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            folio.nombreComercial ?? 'Sin nombre comercial',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Folio: ${folio.folioId ?? 'N/A'} • ${folio.municipio ?? ''}",
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: folio.status != "Por entregar"
                            ? statusColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        folio.status.toString(),
                        style: TextStyle(
                          color: folio.status == "Por entregar"
                              ? statusColor
                              : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}