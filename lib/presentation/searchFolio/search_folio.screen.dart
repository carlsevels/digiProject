import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controllers/search_folio.controller.dart';

class SearchFolioScreen extends GetView<SearchFolioController> {
  const SearchFolioScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) {
        String _formatFecha(dynamic fecha) {
          final date = DateTime.tryParse(fecha?.toString() ?? "");

          if (date == null) {
            return "";
          }

          return DateFormat("d 'de' MMMM 'del' yyyy", 'es').format(date);
        }

        return Scaffold(
          backgroundColor: Color(0XFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0XFFF8FAFC),
            elevation: 0,
            title: Obx(() {
              if (controller.isSearching.value) {
                return TextField(
                  controller: controller.id,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por ID de Folio...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(
                    color: Color(0xff0F172A),
                    fontSize: 18,
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      controller.getDetailsFolio(value);
                    }
                  },
                );
              } else {
                return Text(
                  state?.nombreComercial ?? "Detalles del Folio",
                  style: const TextStyle(
                    color: Color(0xff0F172A),
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                );
              }
            }),

            leading: Obx(
              () => IconButton(
                icon: Icon(
                  controller.isSearching.value ? Icons.close : Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () {
                  if (controller.isSearching.value) {
                    controller.toggleSearch();
                  } else {
                    Get.back();
                  }
                },
              ),
            ),

            actions: [
              Obx(
                () => controller.isSearching.value
                    ? IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Color(0XFF00BC16),
                        ),
                        onPressed: () {
                          if (controller.id.text.isNotEmpty) {
                            controller.getDetailsFolio(controller.id.text);
                          }
                        },
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.search_outlined,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          controller.toggleSearch();
                        },
                      ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: controller.id != ""
              ? RefreshIndicator(
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
                              padding: EdgeInsets.symmetric(horizontal: 8),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                                  state?.statusColor
                                                      ?.toString(),
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 32.0,
                                    child: Row(
                                      children: [
                                        Icon(Icons.route_outlined),
                                        SizedBox(width: 8.0),
                                        Text(
                                          "Detalles del Trayecto",
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: Color(0XFF0F172A),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            height: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Obx(() {
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: List.generate(
                                        steps.length * 2 - 1,
                                        (i) {
                                          if (i.isEven) {
                                            final index = i ~/ 2;

                                            return Expanded(
                                              child: _step(
                                                colorStatus: int.parse(
                                                  state?.statusColor
                                                          .toString() ??
                                                      "0xFF9E9E9E",
                                                ),
                                                title:
                                                    steps[index]["title"]
                                                        as String,
                                                icon:
                                                    steps[index]["icon"]
                                                        as IconData,
                                                active: currentStep >= index,
                                                completed: currentStep > index,
                                                isLast:
                                                    index == steps.length - 1,
                                              ),
                                            );
                                          }

                                          final leftIndex = i ~/ 2;

                                          return Container(
                                            width: 40,
                                            margin: const EdgeInsets.only(
                                              top: 16,
                                            ),
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
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 32.0),
                          ElevatedButton(
                            onPressed: () {
                              Get.toNamed(
                                Routes.DETALLES_FOLIO,
                                arguments: state?.folioId.toString(),
                              );
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
                )
              : SizedBox.shrink(),
        );
      },
      onEmpty: Scaffold(
        backgroundColor: Color(0XFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0XFFF8FAFC),
          elevation: 0,
          title: TextField(
            controller: controller.id,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Buscar por ID de Folio...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: const TextStyle(color: Color(0xff0F172A), fontSize: 18),
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                controller.getDetailsFolio(value);
              }
            },
          ),

          actions: [
            Obx(
              () => controller.isSearching.value
                  ? IconButton(
                      icon: const Icon(Icons.search, color: Color(0XFF00BC16)),
                      onPressed: () {
                        if (controller.id.text.isNotEmpty) {
                          controller.getDetailsFolio(controller.id.text);
                        }
                      },
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.search_outlined,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        controller.toggleSearch();
                      },
                    ),
            ),
            const SizedBox(width: 8),
          ],
        ),

        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0XFF00BC16).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    size: 64,
                    color: Color(0XFF00BC16),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "¿Buscas un folio?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Introduce el número de folio en la barra de\nbúsqueda superior para visualizar su estado.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onLoading: const Center(
        child: CircularProgressIndicator(color: Color(0XFF00BC16)),
      ),
      onError: (err) => Center(child: Text("Error: $err")),
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
