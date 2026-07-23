import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/btnGoogleMaps.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/detallesTrayecto.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/direccion.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/entregaDetalles.dart';
import 'package:bitacora_frontend/infrastructure/globalWidgets/repartidorDetalle.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/folios.empty.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'controllers/search_folio.controller.dart';

class SearchFolioScreen extends GetView<SearchFolioController> {
  const SearchFolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definición del AppBar común para todos los estados
    PreferredSizeWidget buildAppBar() => AppBar(
      iconTheme: const IconThemeData(color: Color(0XFF64748B)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Color(0XFF64748B), height: 1.0),
      ),
      backgroundColor: const Color(0XFFF8FAFC),
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

    String formatFecha(dynamic fecha) {
      final date = DateTime.tryParse(fecha?.toString() ?? "");
      return date == null
          ? ""
          : DateFormat("d 'de' MMMM 'del' yyyy", 'es').format(date);
    }

    return controller.obx(
      // ESTADO DE ÉXITO
      (state) => Scaffold(
        backgroundColor: const Color(0XFFF8FAFC),
        appBar: buildAppBar(),
        body: RefreshIndicator(
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
                    state: state,
                    currentStep: controller.currentStep,
                  ),
                  SizedBox(height: 16.0),
                  Direccion(state: state),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: () => Get.toNamed(
                      Routes.DETALLES_FOLIO,
                      arguments: state?.folioId.toString(),
                    ),
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
      // ESTADO VACÍO (Con Scaffold)
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
      // ESTADO DE CARGA
      onLoading: Scaffold(
        appBar: buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0XFF00BC16)),
        ),
      ),
      // ESTADO DE ERROR
      onError: (err) => Scaffold(
        appBar: buildAppBar(),
        body: Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _step({
    required String title,
    required IconData icon,
    required bool active,
    required bool completed,
    required bool isLast,
    required int colorStatus,
  }) {
    final color = Color(colorStatus);
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? color : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? color : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withOpacity(.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            completed ? Icons.check_rounded : icon,
            size: 20,
            color: active ? Colors.white : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
