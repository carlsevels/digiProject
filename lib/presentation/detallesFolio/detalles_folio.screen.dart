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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildWebView(context);
        } else {
          return _buildMobileView(context);
        }
      },
    );
  }

  Widget _buildMobileView(BuildContext context) {
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
                  child: const Icon(Icons.cancel_outlined, color: Colors.white),
                ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: "btn1",
                backgroundColor: const Color(0XFF00BC16),
                onPressed: () {
                  controller.llamarTelefonoSoporteTecnico();
                },
                child: const Icon(Icons.phone, color: Colors.white),
              ),
            ],
          ),
          bottomNavigationBar: controller.statusId.value != 3
              ? BtnSliderStatus(state: state)
              : const SizedBox.shrink(),
          backgroundColor: const Color(0XFFF8FAFC),
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
                    SizedBox(
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
                    const SizedBox(height: 16),
                    DetallesTrayecto(
                      detallesTrayecto: true,
                      state: state,
                      currentStep: controller.currentStep,
                    ),
                    const SizedBox(height: 16),
                    DetallesEntrega(state: state),
                    const SizedBox(height: 16),
                    Direccion(state: state),
                    // Container(
                    //   width: Get.size.width,
                    //   height: 400,
                    //   child: ListView(
                    //     shrinkWrap: true,
                    //     children: <Widget>[
                    //       const SizedBox(
                    //         height: 300,
                    //         child: Center(
                    //           child: Text(
                    //             'Big container to test scrolling issues',
                    //           ),
                    //         ),
                    //       ),
                    //       //SIGNATURE CANVAS
                    //       Padding(
                    //         padding: const EdgeInsets.all(16.0),
                    //         child: Signature(
                    //           placeholder: Text(
                    //             'Sign here',
                    //             style: Theme.of(context).textTheme.bodyLarge!
                    //                 .copyWith(color: Colors.red),
                    //           ),
                    //           key: const Key('signature'),
                    //           controller:
                    //               controller.signatureControllerController,
                    //           height: 300,
                    //           backgroundColor: Colors.grey[300]!,
                    //         ),
                    //       ),
                    //       Text(
                    //         controller.signatureControllerController.isEmpty
                    //             ? "Signature pad is empty"
                    //             : "Signature pad is not empty",
                    //       ),
                    //       const SizedBox(
                    //         height: 300,
                    //         child: Center(
                    //           child: Text(
                    //             'Big container to test scrolling issues',
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // IconButton(
                    //   key: const Key('exportSVG'),
                    //   icon: const Icon(Icons.share),
                    //   color: Colors.blue,
                    //   onPressed: () => controller.exportSVG(context),
                    //   tooltip: 'Export SVG',
                    // ),
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

  Widget _buildWebView(BuildContext context) {
    String _formatFecha(dynamic fecha) {
      final date = DateTime.tryParse(fecha?.toString() ?? "");
      if (date == null) return "";
      return DateFormat("d 'de' MMMM 'del' yyyy", 'es').format(date);
    }

    return controller.obx(
      onLoading: Container(
        color: const Color(0xFFF8FAFC),
        child: const Center(child: CircularProgressIndicator()),
      ),
      onEmpty: const Center(child: Text("Este folio no existe.")),
      (state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBarWithoutImage(title: "Detalles de Folio"),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Folio: #${state?.folioId ?? 'N/D'}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            state?.condicionPago ?? 'Sin condición',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatFecha(state?.created_at),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    if (state?.isArchived ?? false)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.archive_outlined,
                              color: Colors.orange,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "ARCHIVADO",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: DetallesTrayecto(
                                detallesTrayecto: true,
                                state: state,
                                currentStep: controller.currentStep,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: DetallesEntrega(state: state),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Direccion(state: state),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Control y Asignación",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  RepartidorDetalles(state: state),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
