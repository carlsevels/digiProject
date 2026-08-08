import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/appBarWithoutImage.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/btnGoogleMaps.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/btnSlideStatus.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/detallesTrayecto.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/direccion.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/entregaDetalles.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/repartidorDetalle.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/empty_folio_web.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/folios.empty.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'controllers/search_folio.controller.dart';

class SearchFolioScreen extends GetView<SearchFolioController> {
  const SearchFolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget buildAppBar() => AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      iconTheme: const IconThemeData(color: Color(0XFF64748B)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: const Color(0XFFE2E8F0), height: 1.0),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            onPressed: () {
              if (controller.id.text.trim().isNotEmpty) {
                controller.getDetailsFolio(controller.id.text.trim());
              }
            },
            icon: const Icon(Icons.search, color: Color(0XFF64748B)),
          ),
        ),
      ],
      title: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9), 
          borderRadius: BorderRadius.circular(22), 
          border: Border.all(color: const Color(0xFFE2E8F0)), 
        ),
        child: TextField(
          controller: controller.id,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              controller.getDetailsFolio(value.trim());
            }
          },
          autofocus: true,
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            hintText: 'Escribe el ID del folio a buscar...',
            hintStyle: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Color(0xFF64748B),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          keyboardType: TextInputType.text,
        ),
      ),
      centerTitle: true,
    );

    return controller.obx(
      (state) => Scaffold(
        backgroundColor: const Color(0XFFF8FAFC),
        appBar: buildAppBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Container(
                  width: constraints.maxWidth * 0.5 < 400
                      ? 400
                      : (constraints.maxWidth * 0.5 > 800
                            ? 800
                            : constraints.maxWidth * 0.5),
                  padding: const EdgeInsets.all(24.0),
                  child: _DetallesFolioEmbeddedView(
                    state: controller.folio ?? Folios(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      onEmpty: Scaffold(
        backgroundColor: const Color(0XFFF8FAFC),
        appBar: buildAppBar(),
        body: RefreshIndicator(
          onRefresh: () async {
            if (controller.id.text.trim().isNotEmpty) {
              await controller.getDetailsFolio(controller.id.text.trim());
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: kIsWeb
                      ? WebFoliosEmptyPage(needDate: false)
                      : FoliosEmptyPage(needDate: false),
                ),
              ),
            ],
          ),
        ),
      ),
      onLoading: Scaffold(
        backgroundColor: const Color(0XFFF8FAFC),
        appBar: buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0XFF00BC16)),
        ),
      ),
      onError: (err) => Scaffold(
        backgroundColor: const Color(0XFFF8FAFC),
        appBar: buildAppBar(),
        body: Center(child: Text("Error: $err")),
      ),
    );
  }
}

class _DetallesFolioEmbeddedView extends GetView<SearchFolioController> {
  final Folios state;

  const _DetallesFolioEmbeddedView({required this.state});

  @override
  Widget build(BuildContext context) {
    String formatFecha(dynamic fecha) {
      final date = DateTime.tryParse(fecha?.toString() ?? "");
      if (date == null) return "";
      return DateFormat("d 'de' MMMM 'del' yyyy", 'es').format(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D6CFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF1D6CFF),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Folio ID: ${state.folioId ?? 'N/A'}",
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Condición de pago: ${state.condicionPago ?? 'N/A'} • Creado el ${formatFecha(state.created_at)}",
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (state.isArchived ?? false)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.amber, width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.archive_outlined,
                        color: Colors.amber,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "ARCHIVADO",
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Historial General de Status",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final listaHistorial = controller.historialList;
                if (listaHistorial.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "No hay registros de status disponibles para este folio.",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  );
                }

                return Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: listaHistorial.map((historialItem) {
                    String rawColor =
                        historialItem.status?.color?.toString() ?? '0xFF1D6CFF';
                    rawColor = rawColor
                        .replaceAll('#', '0x')
                        .replaceAll('0X', '0x');

                    final colorStatus = Color(
                      int.tryParse(rawColor) ?? 0xFF1D6CFF,
                    );

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorStatus.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorStatus),
                      ),
                      child: Text(
                        historialItem.status?.nombre?.toString() ??
                            'Sin estatus',
                        style: TextStyle(
                          color: colorStatus,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth > 900;

            if (!isWideScreen) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RepartidorDetalles(state: state),
                  const SizedBox(height: 16),
                  DetallesTrayectoWeb(
                    detallesTrayecto: true,
                    historialList: controller.folioList.obs,
                    currentStep: controller.currentStep,
                    statusNombre: controller.folioList.isNotEmpty
                        ? (controller.folioList.last.status?.nombre ?? '')
                        : '',
                    statusColor: controller.folioList.isNotEmpty
                        ? (controller.folioList.last.status?.color ?? '')
                        : '',
                  ),
                  const SizedBox(height: 16),
                  DetallesEntrega(state: state),
                  const SizedBox(height: 16),
                  Direccion(state: state),
                  const SizedBox(height: 16),
                  BtnGoogleMaps(state: state),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildCardContainer(
                        Obx(
                          () => DetallesTrayectoWeb(
                            detallesTrayecto: true,
                            historialList: controller.folioList.obs,
                            currentStep: controller.currentStep,
                            statusNombre: controller.folioList.isNotEmpty
                                ? (controller.folioList.last.status?.nombre ??
                                      '')
                                : '',
                            statusColor: controller.folioList.isNotEmpty
                                ? (controller.folioList.last.status?.color ??
                                      '')
                                : '',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCardContainer(Direccion(state: state)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildCardContainer(RepartidorDetalles(state: state)),
                      const SizedBox(height: 16),
                      _buildCardContainer(DetallesEntrega(state: state)),
                      const SizedBox(height: 16),
                      _buildActionPanel(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCardContainer(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildActionPanel() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Acciones del Folio",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (controller.statusId.value != 3) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BtnSliderStatus(state: state),
                  const SizedBox(height: 10),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            if (controller.statusId.value == 5) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (state.folioIdHistorial != null) {
                        await controller.pedidoPendiente(
                          state.folioIdHistorial!,
                        );
                        if (state.folioId != null) {
                          await controller.getDetailsFolio(state.folioId!);
                        }
                      }
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text(
                      "Cancelar Pedido",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0XFF00BC16),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {},
            icon: const Icon(Icons.phone, size: 18),
            label: const Text(
              "Llamar a Soporte Técnico",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}