import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/detallesTrayecto.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/direccion.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/repartidorDetalle.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/empty_folio_web.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/folios.empty.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                  controller.getDetailsFolio(controller.id.text);
                },
                icon: const Icon(Icons.search, color: Color(0XFF64748B)),
              ),
            ),
          ],
          title: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: TextField(
              controller: controller.id,
              onSubmitted: (value) {
                controller.getDetailsFolio(value);
              },
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Buscar por ID de Folio...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color(0XFF94A3B8)),
              ),
              style: const TextStyle(color: Color(0xff0F172A), fontSize: 16),
              keyboardType: TextInputType.number,
            ),
          ),
          centerTitle: true,
        );

    return controller.obx(
      (state) => Scaffold(
        backgroundColor: const Color(0XFFF8FAFC),
        appBar: buildAppBar(),
        body: RefreshIndicator(
          color: Colors.white,
          backgroundColor: const Color(0XFF1D6CFF),
          onRefresh: () async => await controller.onInitDetalles(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              // Limita el ancho máximo en pantallas grandes (Web / Desktop)
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RepartidorDetalles(state: state),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(color: Color(0xFFE2E8F0)),
                        ),
                        DetallesTrayecto(
                          detallesTrayecto: false,
                          state: state,
                          currentStep: controller.currentStep,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(color: Color(0xFFE2E8F0)),
                        ),
                        Direccion(state: state),
                        const SizedBox(height: 32.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final folioId = state?.folioId?.toString();
                              if (folioId != null && folioId.isNotEmpty) {
                                Get.toNamed(Routes.DETALLES_FOLIO, arguments: folioId);
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
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Ir al folio",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      onEmpty: Scaffold(
        backgroundColor: const Color(0XFFF8FAFC),
        appBar: buildAppBar(),
        body: RefreshIndicator(
          onRefresh: () async =>
              await controller.getDetailsFolio(controller.id.text),
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