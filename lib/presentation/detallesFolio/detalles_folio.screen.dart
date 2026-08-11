import 'package:bitacora_frontend/presentation/detallesFolio/responsive/detallesFolio_movil.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/responsive/detallesFolio_wev.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/detalles_folio.controller.dart';

class DetallesFolioScreen extends GetView<DetallesFolioController> {
  const DetallesFolioScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return controller.obx(
      onLoading: Container(
        color: Colors.white,
        child: const Center(child: CircularProgressIndicator()),
      ),
      onEmpty: const Center(child: Text("Este folio no existe.")),
      (state) {
        if (kIsWeb) {
          return DetallesFolioWebView(state: state!);
        } else {
          return DetallesFolioMovilView(state: state!);
        }
      },
    );
  }
}
