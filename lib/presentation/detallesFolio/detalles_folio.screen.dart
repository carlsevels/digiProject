import 'package:bitacora_frontend/infrastructure/globalWidgets/appBarWithoutImage.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/btnSlideStatus.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/detallesTrayecto.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/direccion.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/entregaDetalles.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/repartidorDetalle.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';

import 'controllers/detalles_folio.controller.dart';

class DetallesFolioScreen extends GetView<DetallesFolioController> {
  const DetallesFolioScreen({super.key});
  @override
  Widget build(BuildContext context) {
    String _formatFecha(dynamic fecha) {
      final date = DateTime.tryParse(fecha?.toString() ?? "");

      if (date == null) {
        return "";
      }

      return DateFormat("d 'de' MMMM 'del' yyyy", 'es').format(date);
    }

    return controller.obx(
      onLoading: Container(
        color: Colors.white,
        child: const Center(child: CircularProgressIndicator()),
      ),
      onEmpty: const Center(child: Text("Este folio no existe.")),
      onError: (error) {
        if (error.toString().contains('SocketException') ||
            error.toString().contains('no internet')) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wifi_off,
                      size: 48,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Sin conexión a internet",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "No pudimos conectar con el servidor. Por favor, verifica tu conexión e intenta de nuevo.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.onInit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Reintentar conexión"),
                  ),
                ],
              ),
            ),
          );
        }
        return Center(child: Text("Ocurrió un error inesperado: $error"));
      },
      (state) {
        return Scaffold(
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (controller.statusId.value == 5)
                FloatingActionButton(
                  tooltip: "Cancelar",
                  heroTag: "btn2",
                  backgroundColor: Colors.red,
                  onPressed: () {
                    controller.pedidoPendiente(state?.id?.toString() ?? "");
                    controller.onInitDetalles();
                  },
                  child: Icon(Icons.cancel_outlined, color: Colors.white),
                ),
              SizedBox(width: 16),
              FloatingActionButton(
                heroTag: "btn1",
                backgroundColor: Color(0XFF00BC16),
                onPressed: () {
                  controller.llamarTelefonoSoporteTecnico();
                },
                child: Icon(Icons.phone, color: Colors.white),
              ),
            ],
          ),
          bottomNavigationBar: controller.statusId.value != 3
              ? BtnSliderStatus(state: state)
              : SizedBox.shrink(),
          backgroundColor: Color(0XFFF8FAFC),
          appBar: AppBarWithoutImage(
            title: "Detalles de Folio",
            state: state,
            onPressedArchived: () =>
                controller.archivarFolio(state?.folioId ?? ""),
            onPressedDeleted: () =>
                controller.eliminarFolio(state?.folioId ?? ""),
            onPressedRestaurar: () =>
                controller.restaurarFolio(state?.folioId ?? ""),
          ),
          body: RefreshIndicator(
            color: Colors.white,
            backgroundColor: const Color(0XFF1D6CFF),
            onRefresh: () async {
              await controller.onInitDetalles();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: Get.size.width,
                      height: 30,
                      child: Row(
                        children: [
                          Expanded(
                            child: Marquee(
                              text:
                                  "Folio: ${state?.folioId} - ${state?.condicionPago} - "
                                  "${_formatFecha(state?.created_at)}",
                              style: const TextStyle(
                                color: Color(0XFF64748B),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              blankSpace: 50.0,
                              velocity: 50.0,
                              pauseAfterRound: const Duration(seconds: 1),
                              startPadding: 10.0,
                              accelerationDuration: const Duration(seconds: 1),
                              decelerationDuration: const Duration(
                                milliseconds: 500,
                              ),
                            ),
                          ),
                          if (state?.isArchived ?? false)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 6.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: Colors.orange,
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.archive_outlined,
                                    color: Color(0xFFFEF3C7),
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "ARCHIVADO",
                                    style: TextStyle(
                                      color: Color(0xFFFEF3C7),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    RepartidorDetalles(state: state),
                    SizedBox(height: 16),
                    DetallesTrayecto(
                      detallesTrayecto: true,
                      state: state,
                      currentStep: controller.currentStep,
                    ),
                    SizedBox(height: 16),
                    DetallesEntrega(state: state),
                    SizedBox(height: 16),
                    Direccion(state: state),

                    // BtnGoogleMaps(state: state),
                    // SizedBox(height: 32.0),
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
