import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/controllers/folios.controller.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/easy_date_timeline.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/folios.empty.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnEmptyView extends GetView<FoliosController> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: const Color(0XFF1D6CFF),
      onRefresh: () async {
        await controller.getFoliosWithDate();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: Get.size.height,
          child: Center(
            child: Column(
              key: const ValueKey('header_fijo_fecha'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => Text(
                          controller.obtenerEtiquetaFecha(
                            DateTime.tryParse(
                                  controller.fechaSeleccionada.value,
                                ) ??
                                DateTime.now(),
                          ),
                          textScaler: const TextScaler.linear(1.8),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Get.offAndToNamed(Routes.ADD_FOLIOS),
                        icon: const Icon(Icons.add, color: Color(0XFF1D6CFF)),
                        label: const Text(
                          "Agregar Folio",
                          style: TextStyle(color: Color(0XFF1D6CFF)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                EasyDateTimelinePage(),
                const SizedBox(height: 16),
                FoliosEmptyPage(needDate: false)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
