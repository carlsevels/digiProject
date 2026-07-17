import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controllers/detalles_folio.controller.dart';
import 'package:action_slider/action_slider.dart';

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
                  },
                  child: Icon(Icons.cancel_outlined, color: Colors.white),
                ),
              SizedBox(width: 16),
              FloatingActionButton(
                heroTag: "btn1",
                backgroundColor: Color(0XFF00BC16),
                onPressed: () {},
                child: Icon(Icons.phone, color: Colors.white),
              ),
            ],
          ),
          bottomNavigationBar: controller.statusId.value != 3
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: ActionSlider.standard(
                      height: 60,
                      toggleColor: const Color(0XFF1D6CFF),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      sliderBehavior: SliderBehavior.stretch,
                      backgroundColor: Colors.white,
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: controller.statusFolio(
                          controller.statusId.value,
                        ),
                      ),
                      action: (sliderController) async {
                        sliderController.loading();
                        await controller.changeStatus(
                          controller.statusId.toString(),
                          state?.folioIdHistorial?.toString() ?? "",
                        );
                        sliderController.success();

                        int? nextStatus = await controller.changeStatus(
                          controller.statusId.toString(),
                          state?.folioIdHistorial?.toString() ?? "",
                        );

                        if (nextStatus == 3) {
                          sliderController.success();
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );

                          Get.toNamed(
                            Routes.SUCCESS,
                            arguments: state?.folioId.toString(),
                          );
                        } else {
                          sliderController.success();
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                          await controller.onInitDetalles();
                        }

                        await Future.delayed(const Duration(milliseconds: 500));
                        await this.controller.onInitDetalles();
                      },
                    ),
                  ),
                )
              : SizedBox.shrink(),
          backgroundColor: Color(0XFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Color(0XFFF8FAFC),
            title: Text(
              state?.nombreComercial ?? "",
              style: TextStyle(color: Color(0xff0F172A)),
            ),
            actions: [
              IconButton(onPressed: () {}, icon: Icon(Icons.search)),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_vert_outlined),
              ),
            ],
          ),
          body: RefreshIndicator(
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
                    Text(
                      "Folio: ${state?.folioId} - ${state?.condicionPago} - "
                      "${_formatFecha(state?.created_at)}",
                      style: const TextStyle(
                        color: Color(0XFF64748B),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Card(
                      elevation: 4,
                      color: Colors.white,
                      margin: EdgeInsets.zero,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: ListTile(
                          isThreeLine: false,
                          contentPadding: EdgeInsets.zero,
                          leading: Column(
                            children: [
                              Text(
                                state?.cantidad ?? "",
                                textScaleFactor: 3.5,
                                style: TextStyle(height: 1),
                              ),
                              Flexible(
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 35,
                                  ),
                                  child: Text(
                                    state?.tiporefaccion ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            state?.nombreComercial ?? "",
                            style: TextStyle(
                              color: controller.parseColor(
                                state?.statusColor?.toString(),
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      color: Color(0XFF64748B),
                                    ),
                                    Flexible(
                                      child: Text(
                                        state?.municipio ?? "",
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0XFF64748B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: state?.status != "Por entregar"
                                      ? controller.parseColor(
                                          state?.statusColor?.toString(),
                                        )
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: controller.parseColor(
                                      state?.statusColor?.toString(),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  state?.status.toString() ?? "",
                                  style: TextStyle(
                                    color: state?.status == "Por entregar"
                                        ? controller.parseColor(
                                            state?.statusColor?.toString(),
                                          )
                                        : Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),
                    Text(
                      state?.repartidor ?? "",
                      style: TextStyle(
                        color: Color(0XFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      "Repartidor",
                      style: TextStyle(
                        color: Color(0XFF64748B),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 24.0),
                    Card(
                      color: Colors.white,
                      margin: EdgeInsets.zero,
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 32.0,
                              child: Text(
                                "Detalles del Trayecto",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Color(0XFF0F172A),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 100,
                              child: Obx(() {
                                final currentStep =
                                    controller.currentStep.value;

                                final steps = [
                                  {
                                    "title": "Por iniciar",
                                    "icon": Icons.local_shipping_outlined,
                                  },
                                  {
                                    "title": "En ruta",
                                    "icon": Icons.location_on_outlined,
                                  },
                                  {
                                    "title": "En Sitio",
                                    "icon": Icons.place_outlined,
                                  },
                                  {
                                    "title": "Entregado",
                                    "icon": Icons.check_circle_outline,
                                  },
                                ];

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                    steps.length * 2 - 1,
                                    (i) {
                                      if (i.isEven) {
                                        final index = i ~/ 2;

                                        return Expanded(
                                          child: _step(
                                            colorStatus: int.parse(
                                              state?.statusColor.toString() ??
                                                  "0xFF9E9E9E",
                                            ),
                                            title:
                                                steps[index]["title"] as String,
                                            icon:
                                                steps[index]["icon"]
                                                    as IconData,
                                            active: currentStep >= index,
                                            completed: currentStep > index,
                                            isLast: index == steps.length - 1,
                                          ),
                                        );
                                      }

                                      final leftIndex = i ~/ 2;

                                      return Container(
                                        width: 40,
                                        margin: const EdgeInsets.only(top: 16),
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: currentStep > leftIndex
                                              ? Color(
                                                  int.parse(
                                                    state?.statusColor
                                                            .toString() ??
                                                        "0xFF9E9E9E",
                                                  ),
                                                )
                                              : Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
