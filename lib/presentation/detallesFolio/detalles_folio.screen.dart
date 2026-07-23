import 'package:bitacora_frontend/infrastructure/globalWidgets/appBarWithoutImage.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/btnGoogleMaps.dart';
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
                    controller.pedidoPendiente(
                      state?.folioIdHistorial?.toString() ?? "",
                    );
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
          appBar: AppBarWithoutImage(title: "Detalles de Folio"),
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
                        decelerationDuration: const Duration(milliseconds: 500),
                      ),
                    ),
                    RepartidorDetalles(state: state),
                    SizedBox(height: 16.0),
                    DetallesTrayecto(state: state, currentStep: controller.currentStep,),
                    SizedBox(height: 16.0),
                    DetallesEntrega(state: state),
                    SizedBox(height: 16.0),
                    Direccion(state: state),
                    SizedBox(height: 16.0),
                    BtnGoogleMaps(state: state),
                    SizedBox(height: 32.0),
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
