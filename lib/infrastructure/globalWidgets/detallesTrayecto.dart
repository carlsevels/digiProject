import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/models/historial_folios.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/controllers/detalles_folio.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetallesTrayecto extends GetView<DetallesFolioController> {
  final Folios? state;
  final RxInt currentStep;
  final bool detallesTrayecto;

  const DetallesTrayecto({
    super.key,
    required this.state,
    required this.currentStep,
    required this.detallesTrayecto,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: detallesTrayecto == true
          ? () async {
              await controller.historialFolio(state?.id ?? "");

              Get.bottomSheet(
                Container(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                    left: 16,
                    right: 16,
                  ),
                  width: Get.size.width,
                  height: Get.size.height / 2,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 30,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.route_outlined,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 8.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Detalles del Trayecto",
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (controller.historialList.any(
                                    (item) =>
                                        (item.status ?? '')
                                            .toLowerCase()
                                            .contains('pospuso') ||
                                        (item.status ?? '')
                                            .toLowerCase()
                                            .contains('pendiente'),
                                  ))
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        "+1 día",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: parseColor(state?.statusColor?.toString()),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              state?.status ?? "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Obx(() {
                          final historialList = controller.historialList;

                          if (historialList.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return ListView.builder(
                            itemCount: historialList.length,
                            itemBuilder: (context, index) {
                              final item = historialList[index];
                              final String createdAt = item.created_at ?? '';
                              final String statusName =
                                  (item.status != null &&
                                      item.status!.isNotEmpty)
                                  ? item.status!
                                  : 'Por iniciar';

                              String description = "";
                              switch (statusName) {
                                case "Por entregar":
                                  description = "Por iniciar recorrido";
                                  break;
                                case "En ruta":
                                  description =
                                      "El repartidor inicio el recorrido";
                                  break;
                                case "Pendiente":
                                  description = "No se realizó la entrega";
                                  break;
                                case "En sitio":
                                  description =
                                      "Se llegó a sitio para realizar la entrega";
                                  break;
                                case "Entregado":
                                  description =
                                      "El repartidor realizó la entrega";
                                  break;
                                default:
                              }

                              final String? colorHex = item.statusColor;
                              bool isLast = index == historialList.length - 1;
                              bool isWarning = statusName
                                  .toLowerCase()
                                  .contains('pendiente');

                              return _buildTimelineItem(
                                time: createdAt,
                                statusName: statusName,
                                description: description,
                                statusColorHex: colorHex,
                                isWarning: isWarning,
                                isFirst: index == 0,
                                isLast: isLast,
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                isScrollControlled: true,
              );
            }
          : null,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.route_outlined, color: Color(0XFF64748B)),
                      SizedBox(width: 8.0),
                      Text(
                        "Detalles del Trayecto",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color(0XFF0F172A),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (detallesTrayecto == true)
                    const Icon(Icons.arrow_forward_ios),
                ],
              ),
              const SizedBox(height: 8.0),
              Obx(() {
                final steps = [
                  {
                    "title": "Por iniciar",
                    "icon": Icons.local_shipping_outlined,
                  },
                  {"title": "En ruta", "icon": Icons.location_on_outlined},
                  {"title": "En Sitio", "icon": Icons.place_outlined},
                  {"title": "Entregado", "icon": Icons.check_circle_outline},
                ];

                final int stepValue = currentStep.value;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(steps.length * 2 - 1, (i) {
                    if (i.isEven) {
                      final index = i ~/ 2;

                      return Expanded(
                        child: _step(
                          colorStatus: int.parse(
                            state?.statusColor.toString() ?? "0xFF9E9E9E",
                          ),
                          title: steps[index]["title"] as String,
                          icon: steps[index]["icon"] as IconData,
                          active: stepValue >= index,
                          completed: stepValue > index,
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
                        color: stepValue > leftIndex
                            ? Color(
                                int.parse(
                                  state?.statusColor.toString() ?? "0xFF9E9E9E",
                                ),
                              )
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }),
                );
              }),
            ],
          ),
        ),
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

  Color parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFF22C55E);
    }
    try {
      String cleanedHex = hexColor
          .replaceAll('#', '')
          .replaceAll('0X', '')
          .replaceAll('0x', '');

      if (cleanedHex.length == 6) {
        cleanedHex = 'FF$cleanedHex';
      }
      return Color(int.parse(cleanedHex, radix: 16));
    } catch (e) {
      return const Color(0xFF22C55E);
    }
  }

  Widget _buildTimelineItem({
    required String time,
    required String statusName,
    required String description,
    required String? statusColorHex,
    bool isWarning = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    Color parseColor(String? hexColor) {
      if (hexColor == null || hexColor.isEmpty) {
        return const Color(0xFF22C55E);
      }
      try {
        String cleanedHex = hexColor
            .replaceAll('#', '')
            .replaceAll('0X', '')
            .replaceAll('0x', '');

        if (cleanedHex.length == 6) {
          cleanedHex = 'FF$cleanedHex';
        }
        return Color(int.parse(cleanedHex, radix: 16));
      } catch (e) {
        return const Color(0xFF22C55E);
      }
    }

    String formatTimeToHour(String rawTime) {
      if (rawTime.isEmpty) return '';
      try {
        DateTime parsedDate = DateTime.parse(rawTime);
        String day = parsedDate.day.toString().padLeft(2, '0');
        String month = parsedDate.month.toString().padLeft(2, '0');
        String year = parsedDate.year.toString();
        String hour = parsedDate.hour.toString().padLeft(2, '0');
        String minute = parsedDate.minute.toString().padLeft(2, '0');
        return '$day-$month-$year $hour:$minute';
      } catch (e) {
        return rawTime;
      }
    }

    final Color itemColor = parseColor(statusColorHex);
    final String formattedTime = formatTimeToHour(time);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: itemColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isWarning ? Icons.warning_amber_rounded : Icons.circle,
                color: Colors.white,
                size: isWarning ? 16 : 10,
              ),
            ),
            if (!isLast)
              Container(
                width: 3,
                height: 55,
                color: itemColor.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusName.isNotEmpty ? statusName : 'Actualización',
                style: TextStyle(
                  color: itemColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(color: Color(0xFF334155), fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                formattedTime,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class DetallesTrayectoWeb extends GetView<DetallesFolioController> {
  final RxList<HistorialEstado> historialList;
  final RxInt currentStep;
  final bool detallesTrayecto;
  final String statusNombre;
  final String statusColor;

  const DetallesTrayectoWeb({
    super.key,
    required this.historialList,
    required this.currentStep,
    required this.detallesTrayecto,
    required this.statusNombre,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final HistorialEstado? currentFolio = historialList.isNotEmpty
          ? historialList.last
          : null;

      return InkWell(
        onTap: detallesTrayecto == true
            ? () async {
                await controller.historialFolio(currentFolio?.foliold ?? "");

                Get.bottomSheet(
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.only(
                        top: 16.0,
                        left: 16,
                        right: 16,
                      ),
                      width: Get.size.width,
                      height: Get.size.height / 2,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 30,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.route_outlined,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Detalles del Trayecto",
                                        style: TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (controller.historialListWeb.any(
                                            (item) =>
                                                (item.status?.nombre ?? '')
                                                    .toLowerCase()
                                                    .contains('pospuso') ||
                                                (item.status?.nombre ?? '')
                                                    .toLowerCase()
                                                    .contains('pendiente'),
                                          ) ||
                                          statusNombre.toLowerCase().contains(
                                            'pospuso',
                                          ) ||
                                          statusNombre.toLowerCase().contains(
                                            'pendiente',
                                          ))
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Text(
                                            "+1 día",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: parseColor(
                                    statusColor.isNotEmpty
                                        ? statusColor
                                        : currentFolio?.status?.color
                                              ?.toString(),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusNombre.isNotEmpty
                                      ? statusNombre
                                      : (currentFolio?.status?.nombre
                                                ?.toString() ??
                                            ""),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: controller.historialListWeb.isEmpty
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : ListView.builder(
                                    itemCount:
                                        controller.historialListWeb.length,
                                    itemBuilder: (context, index) {
                                      final item =
                                          controller.historialListWeb[index];
                                      final String createdAt =
                                          item.createdAt ?? '';

                                      final String currentItemStatusNombre =
                                          (item.status?.nombre != null &&
                                              item.status!.nombre!.isNotEmpty)
                                          ? item.status!.nombre!
                                          : 'Sin estatus';

                                      String description = "";
                                      switch (currentItemStatusNombre) {
                                        case "Por entregar":
                                          description = "Por iniciar recorrido";
                                          break;
                                        case "En ruta":
                                          description =
                                              "El repartidor inicio el recorrido";
                                          break;
                                        case "Pendiente":
                                          description =
                                              "No se realizó la entrega";
                                          break;
                                        case "En sitio":
                                          description =
                                              "Se llegó a sitio para realizar la entrega";
                                          break;
                                        case "Entregado":
                                          description =
                                              "El repartidor realizó la entrega";
                                          break;
                                        default:
                                          description =
                                              "Actualización de estado";
                                      }

                                      final String? colorHex =
                                          item.status?.color;
                                      bool isLast =
                                          index ==
                                          controller.historialListWeb.length -
                                              1;
                                      bool isWarning = currentItemStatusNombre
                                          .toLowerCase()
                                          .contains('pendiente');

                                      return _buildTimelineItem(
                                        time: createdAt,
                                        statusName: currentItemStatusNombre,
                                        description: description,
                                        statusColorHex: colorHex,
                                        isWarning: isWarning,
                                        isFirst: index == 0,
                                        isLast: isLast,
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  isScrollControlled: true,
                );
              }
            : null,
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          margin: EdgeInsets.zero,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.route_outlined, color: Color(0XFF64748B)),
                        SizedBox(width: 8.0),
                        Text(
                          "Detalles del Trayecto",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Color(0XFF0F172A),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (detallesTrayecto == true)
                      const Icon(Icons.arrow_forward_ios),
                  ],
                ),
                const SizedBox(height: 8.0),
                Obx(() {
                  // Obtenemos el último elemento actualizado directamente de la lista reactiva
                  final latestFolio = historialList.isNotEmpty
                      ? historialList.last
                      : null;

                  // Determinamos el color priorizando el estatus más reciente del historial
                  final String activeColorHex =
                      (latestFolio?.status?.color != null &&
                          latestFolio!.status!.color!.isNotEmpty)
                      ? latestFolio.status!.color!
                      : (statusColor.isNotEmpty ? statusColor : "0xFF9E9E9E");

                  final int colorInt = int.parse(activeColorHex);

                  // Opcional: Calcula el step actual de manera automática basándose en el nombre del último estatus
                  final String currentStatusName =
                      latestFolio?.status?.nombre ?? '';
                  int stepValue = 0;
                  switch (currentStatusName.toLowerCase()) {
                    case 'por entregar':
                    case 'por iniciar':
                      stepValue = 0;
                      break;
                    case 'en ruta':
                      stepValue = 1;
                      break;
                    case 'en sitio':
                      stepValue = 2;
                      break;
                    case 'entregado':
                      stepValue = 3;
                      break;
                    default:
                      stepValue = currentStep
                          .value; // Respeta el valor si es otro estado
                  }

                  final steps = [
                    {
                      "title": "Por iniciar",
                      "icon": Icons.local_shipping_outlined,
                    },
                    {"title": "En ruta", "icon": Icons.location_on_outlined},
                    {"title": "En Sitio", "icon": Icons.place_outlined},
                    {"title": "Entregado", "icon": Icons.check_circle_outline},
                  ];

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(steps.length * 2 - 1, (i) {
                      if (i.isEven) {
                        final index = i ~/ 2;

                        return Expanded(
                          child: _step(
                            colorStatus: colorInt,
                            title: steps[index]["title"] as String,
                            icon: steps[index]["icon"] as IconData,
                            active: stepValue >= index,
                            completed: stepValue > index,
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
                          color: stepValue > leftIndex
                              ? Color(colorInt)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    });
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

  Color parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFF22C55E);
    }
    try {
      String cleanedHex = hexColor
          .replaceAll('#', '')
          .replaceAll('0X', '')
          .replaceAll('0x', '');

      if (cleanedHex.length == 6) {
        cleanedHex = 'FF$cleanedHex';
      }
      return Color(int.parse(cleanedHex, radix: 16));
    } catch (e) {
      return const Color(0xFF22C55E);
    }
  }

  Widget _buildTimelineItem({
    required String time,
    required String statusName,
    required String description,
    required String? statusColorHex,
    bool isWarning = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    Color parseColor(String? hexColor) {
      if (hexColor == null || hexColor.isEmpty) {
        return const Color(0xFF22C55E);
      }
      try {
        String cleanedHex = hexColor
            .replaceAll('#', '')
            .replaceAll('0X', '')
            .replaceAll('0x', '');

        if (cleanedHex.length == 6) {
          cleanedHex = 'FF$cleanedHex';
        }
        return Color(int.parse(cleanedHex, radix: 16));
      } catch (e) {
        return const Color(0xFF22C55E);
      }
    }

    String formatTimeToHour(String rawTime) {
      if (rawTime.isEmpty) return '';
      try {
        DateTime parsedDate = DateTime.parse(rawTime);
        String day = parsedDate.day.toString().padLeft(2, '0');
        String month = parsedDate.month.toString().padLeft(2, '0');
        String year = parsedDate.year.toString();
        String hour = parsedDate.hour.toString().padLeft(2, '0');
        String minute = parsedDate.minute.toString().padLeft(2, '0');
        return '$day-$month-$year $hour:$minute';
      } catch (e) {
        return rawTime;
      }
    }

    final Color itemColor = parseColor(statusColorHex);
    final String formattedTime = formatTimeToHour(time);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: itemColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isWarning ? Icons.warning_amber_rounded : Icons.circle,
                color: Colors.white,
                size: isWarning ? 16 : 10,
              ),
            ),
            if (!isLast)
              Container(
                width: 3,
                height: 55,
                color: itemColor.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusName.isNotEmpty ? statusName : 'Actualización',
                style: TextStyle(
                  color: itemColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(color: Color(0xFF334155), fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                formattedTime,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
