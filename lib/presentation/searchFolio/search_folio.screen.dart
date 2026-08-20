import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/detallesTrayecto.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/direccion.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/repartidorDetalle.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/folios.empty.dart';
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
        child: Container(color: Color(0XFF64748B), height: 1.0),
      ),
      actions: [
        IconButton(
          onPressed: () {
            controller.getDetailsFolio(controller.id.text);
          },
          icon: Icon(Icons.search, color: Color(0XFF64748B)),
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
        appBar: buildAppBar(),
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
                  SizedBox(height: 16.0),
                  DetallesTrayecto(
                    detallesTrayecto: false,
                    state: state,
                    currentStep: controller.currentStep,
                  ),
                  SizedBox(height: 16.0),
                  Direccion(state: state),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
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
                child: Center(child: FoliosEmptyPage(needDate: false)),
              ),
            ],
          ),
        ),
      ),
      onLoading: Scaffold(
        appBar: buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0XFF00BC16)),
        ),
      ),
    );
  }
}
