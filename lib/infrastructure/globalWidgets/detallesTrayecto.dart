import 'package:bitacora_frontend/infrastructure/models/folios.dart';
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
                  height: Get.size.height / 1.8,
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
                          const Row(
                            children: [
                              Icon(
                                Icons.route_outlined,
                                color: Color(0xFF64748B),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                "Detalles del Trayecto",
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Obx(() {
                            final lastFolio =
                                controller.historialList.isNotEmpty
                                ? controller.historialList.last
                                : null;

                            final Map<String, dynamic>? lastJson = lastFolio?.toJson();
                            final dynamic statusData = lastJson?['status'];

                            String currentStatusText = 'Por iniciar';
                            String currentStatusColorHex = '0XFF1D6CFF';

                            if (statusData is Map) {
                              currentStatusText =
                                  statusData['nombre']?.toString() ??
                                  'Por iniciar';
                              currentStatusColorHex =
                                  statusData['color']?.toString() ??
                                  '0XFF1D6CFF';
                            } else if (lastFolio?.status != null) {
                              currentStatusText = lastFolio!.status!;
                              currentStatusColorHex = lastFolio.statusColor ?? '0XFF1D6CFF';
                            } else {
                              currentStatusText = state?.status ?? 'Por iniciar';
                              currentStatusColorHex =
                                  state?.statusColor ?? '0XFF1D6CFF';
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: parseColor(currentStatusColorHex),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                currentStatusText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }),
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
                              
                              final Map<String, dynamic> itemJson = item.toJson();
                              final dynamic rawStatus = itemJson['status'];

                              String statusName = 'Por iniciar';
                              String colorHex = '0XFF1D6CFF';

                              // Extracción directa y segura de nombre y color desde el JSON o el modelo
                              if (rawStatus is Map) {
                                statusName = rawStatus['nombre']?.toString() ?? 'Por iniciar';
                                colorHex = rawStatus['color']?.toString() ?? '0XFF1D6CFF';
                              } else if (item.status != null) {
                                statusName = item.status!;
                              }

                              if (item.statusColor != null && item.statusColor!.isNotEmpty) {
                                colorHex = item.statusColor!;
                              }

                              // Descripciones ajustadas según el estatus limpio
                              String description = "";
                              final String lowerName = statusName.toLowerCase();
                              if (lowerName.contains("por entregar") || lowerName.contains("por iniciar")) {
                                description = "Por iniciar recorrido";
                              } else if (lowerName.contains("en ruta")) {
                                description = "El repartidor inició el recorrido";
                              } else if (lowerName.contains("pendiente")) {
                                description = "No se realizó la entrega";
                              } else if (lowerName.contains("sitio")) {
                                description = "Se llegó a sitio para realizar la entrega";
                              } else if (lowerName.contains("entregado")) {
                                description = "El repartidor realizó la entrega";
                              } else {
                                description = "Actualización de estado";
                              }

                              bool isLast = index == historialList.length - 1;
                              bool isWarning = lowerName.contains('pendiente');

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
                  const Row(
                    children: [
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

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(steps.length * 2 - 1, (i) {
                    if (i.isEven) {
                      final index = i ~/ 2;
                      return Expanded(
                        child: _step(
                          colorStatus: parseColor(state?.statusColor),
                          title: steps[index]["title"] as String,
                          icon: steps[index]["icon"] as IconData,
                          active: currentStep.value >= index,
                          completed: currentStep.value > index,
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
                        color: currentStep.value > leftIndex
                            ? parseColor(state?.statusColor)
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
    required Color colorStatus,
  }) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? colorStatus : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? colorStatus : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: colorStatus.withOpacity(.25),
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
      } else if (cleanedHex.length == 7) {
        cleanedHex = 'F$cleanedHex';
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