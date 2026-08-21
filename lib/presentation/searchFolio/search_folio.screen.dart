import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/detallesTrayecto.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/direccion.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/repartidorDetalle.dart';
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

    // Aquí está la clave: Verificamos si hay internet ANTES de decidir qué mostrar
    return FutureBuilder<bool>(
      future: _hayInternet(),
      builder: (context, snapshot) {
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

  // Lógica para verificar internet
  Future<bool> _hayInternet() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity is List) {
      return !connectivity.contains(ConnectivityResult.none);
    }
    return connectivity != ConnectivityResult.none;
  }

  Widget _buildMainContent(state, buildAppBar) {
    return Scaffold(
      backgroundColor: const Color(0XFFF8FAFC),
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              RepartidorDetalles(state: state),
              DetallesTrayecto(
                detallesTrayecto: false,
                state: state,
                currentStep: controller.currentStep,
              ),
              Direccion(state: state),
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
      body: Center(child: FoliosEmptyPage(needDate: false)),
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
                // 1. Verificamos si ya hay internet antes de reintentar
                final connectivity = await Connectivity().checkConnectivity();
                bool sinConexion = false;
                if (connectivity is List<ConnectivityResult>) {
                  sinConexion =
                      connectivity.contains(ConnectivityResult.none) &&
                      connectivity.length == 1;
                } else {
                  sinConexion = connectivity == ConnectivityResult.none;
                }

                if (sinConexion) {
                  Get.snackbar(
                    "Sin conexión",
                    "Aún no detectamos acceso a internet.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                  return;
                }

                await controller.onInitDetalles();

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
    // Si el error es de conexión, mostramos la pantalla de "Sin Internet"
    return _sinInternetScreen(buildAppBar);
  }

  Future<void> _buscarFolio([String? folio]) async {
    final hasInternet = await _hayInternet();
    if (!hasInternet) {
      Get.snackbar("Error", "No hay conexión a internet");
      return;
    }
    await controller.getDetailsFolio(folio ?? controller.id.text);
  }
}
