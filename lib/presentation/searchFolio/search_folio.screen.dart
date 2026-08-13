import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:bitacora_frontend/infrastructure/models/barcode.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/detallesTrayecto.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/direccion.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/repartidorDetalle.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/controllers/detalles_folio.controller.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/folios.empty.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/search_folio.controller.dart';

class SearchFolioScreen extends GetView<SearchFolioController> {
  const SearchFolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget buildAppBar(String id) => AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      iconTheme: const IconThemeData(color: Color(0XFF64748B)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: const Color(0XFF64748B), height: 1.0),
      ),
      actions: [
        _buildDemoButton(
          context: context,
          scanner: AiBarcodeScanner(
            onDetect: (BarcodeCapture capture) async {
              final rawValue = capture.barcodes.isNotEmpty
                  ? capture.barcodes.first.displayValue
                  : null;

                  print("rawValuerawValue: ${rawValue}");

              if (rawValue == null || rawValue.isEmpty) return;

              if (controller.isProcessingBarcode.value) return;
              controller.isProcessingBarcode.value = true;

              controller.codeBar = BarcodeResponse(
                name: "barcode",
                data: capture.barcodes
                    .map(
                      (b) => BarcodeItem(
                        displayValue: b.displayValue,
                        rawValue: b.rawValue,
                        format: b.format.rawValue,
                        type: b.type.index,
                        rawBytes: b.rawBytes,
                        corners: b.corners
                            .map((c) => CornerPoint(x: c.dx, y: c.dy))
                            .toList(),
                        size: b.size != null
                            ? BarcodeSize(
                                width: b.size!.width,
                                height: b.size!.height,
                              )
                            : null,
                      ),
                    )
                    .toList(),
              );

              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              if (rawValue.isNotEmpty) {
                Get.toNamed(
                  Routes.DETALLES_FOLIO,
                  arguments: {"folioId": rawValue},
                );
              } else {
                Get.snackbar("Aviso", "El ID del folio no está disponible");
              }

              await Future.delayed(const Duration(milliseconds: 300));
              controller.isProcessingBarcode.value = false;
            },
          ),
        ),
        IconButton(
          onPressed: () {
            controller.getDetailsFolio(controller.id.text);
          },
          icon: const Icon(Icons.search, color: Color(0XFF64748B)),
        ),
      ],
      title: TextField(
        controller: controller.id,
        onSubmitted: (value) {
          controller.getDetailsFolio(value);
        },
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Buscar por ID de Folio...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Color(0XFF64748B)),
        ),
        style: const TextStyle(color: Color(0xff0F172A), fontSize: 18),
        keyboardType: TextInputType.number,
      ),
      centerTitle: true,
    );

    return controller.obx(
      (state) => Scaffold(
        backgroundColor: const Color(0XFFF8FAFC),
        appBar: buildAppBar(state?.id ?? ""),
        body: RefreshIndicator(
          color: Colors.white,
          backgroundColor: const Color(0XFF1D6CFF),
          onRefresh: () async => await controller.onInitDetalles(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RepartidorDetalles(state: state),
                  const SizedBox(height: 16.0),
                  DetallesTrayecto(
                    detallesTrayecto: false,
                    state: state,
                    currentStep: controller.currentStep,
                  ),
                  const SizedBox(height: 16.0),
                  Direccion(state: state),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: () {
                      final folioId = state?.folioId?.toString();
                      Get.lazyPut(() => DetallesFolioController());
                      if (folioId != null && folioId.isNotEmpty) {
                        Get.toNamed(
                          Routes.DETALLES_FOLIO,
                          arguments: {"folioId": folioId},
                        );
                      } else {
                        Get.snackbar(
                          "Aviso",
                          "El ID del folio no está disponible",
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E6FF3),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Ir al folio",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onEmpty: Scaffold(
        backgroundColor: const Color(0XFFF8FAFC),
        appBar: buildAppBar(controller.idPrincipal.value),
        body: RefreshIndicator(
          onRefresh: () async =>
              await controller.getDetailsFolio(controller.id.text),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(child: FoliosEmptyPage(needDate: false)),
              ),
            ],
          ),
        ),
      ),
      onLoading: Scaffold(
        appBar: buildAppBar(controller.idPrincipal.value),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0XFF00BC16)),
        ),
      ),
      onError: (err) => Scaffold(
        appBar: buildAppBar(controller.idPrincipal.value),
        body: Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildDemoButton({required context, required Widget scanner}) {
    return IconButton(
      onPressed: () {
        controller.isProcessingBarcode.value = false;
        controller.navigateToScanner(scanner, context);
      },
      icon: const Icon(Icons.qr_code),
    );
  }
}
