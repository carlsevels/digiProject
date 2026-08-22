import 'package:bitacora_frontend/infrastructure/globalWidgets/detallesTrayecto.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/direccion.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/repartidorDetalle.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/folios.empty.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
      actions: [
        IconButton(
          onPressed: () async {
            await controller.onInitDetalles();
          },
          icon: const Icon(Icons.search),
        ),
      ],
      title: TextField(
        controller: controller.id,
        onSubmitted: (value) async => await _buscarFolio(value),
        decoration: const InputDecoration(
          hintText: 'Buscar por ID de Folio...',
          border: InputBorder.none,
        ),
      ),
      centerTitle: true,
    );

    return FutureBuilder<bool>(
      future: _hayInternet(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: buildAppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data == false) {
          return _sinInternetScreen(buildAppBar);
        }
        return controller.obx(
          (state) => _buildMainContent(state, buildAppBar),
          onEmpty: _buildEmptyContent(buildAppBar, context),
          onLoading: Scaffold(
            appBar: buildAppBar(),
            body: const Center(child: CircularProgressIndicator()),
          ),
          onError: (error) => _buildErrorScreen(context, buildAppBar, error),
        );
      },
    );
  }

  Future<bool> _hayInternet() async {
    final connectivity = await Connectivity().checkConnectivity();
    return !connectivity.contains(ConnectivityResult.none);
  }

  Widget _buildMainContent(state, buildAppBar) {
    const primary = Color(0XFF1D6CFF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: SingleChildScrollView(
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
              const SizedBox(height: 24.0),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () {
                    Get.toNamed(
                      Routes.DETALLES_FOLIO,
                      arguments: state.folioId.toString(),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text(
                    "Ir al detalle del folio",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyContent(buildAppBar, context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF8FAFC),
      appBar: buildAppBar(),
      body: const Center(child: FoliosEmptyPage(needDate: false)),
    );
  }

  Widget _sinInternetScreen(buildAppBar) {
    return Scaffold(
      backgroundColor: const Color(0XFFF8FAFC),
      appBar: buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              "Sin conexión a internet",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final hasInternet = await _hayInternet();
                if (!hasInternet) {
                  Get.snackbar(
                    "Sin conexión",
                    "Aún no detectamos acceso a internet.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                  return;
                }

                if (controller.id.text.isNotEmpty) {
                  await controller.onInitDetalles();
                } else {
                  Get.rawSnackbar(
                    message: "Conexión restablecida. Intenta buscar de nuevo.",
                  );
                }
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

  Widget _buildErrorScreen(context, buildAppBar, error) {
    return _sinInternetScreen(buildAppBar);
  }

  Future<void> _buscarFolio([String? folio]) async {
    final hasInternet = await _hayInternet();
    if (!hasInternet) {
      Get.snackbar(
        "Error",
        "No hay conexión a internet",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    await controller.getDetailsFolio(folio ?? controller.id.text);
  }
}
