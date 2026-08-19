import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
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
              final folioId = state?.folioId?.toString();
              if (folioId != null && folioId.isNotEmpty) {
                Get.toNamed(Routes.DETALLES_FOLIO, arguments: folioId);
              }
              
              Get.bottomSheet(
                DraggableScrollableSheet(
                  initialChildSize: 0.65,
                  minChildSize: 0.3,
                  maxChildSize: 0.95,
                  snap: true,
                  builder: (context, scrollController) {
                    return Container(
                      padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
                      width: Get.size.width,
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
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2.5),
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

                          Obx(() {
                            return _buildMetricsSummary(controller.historialList);
                          }),

                          const SizedBox(height: 16),
                          const Text(
                            "Historial de Eventos",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Expanded(
                            child: Obx(() {
                              final historialList = controller.historialList;

                              if (historialList.isEmpty) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              return ListView.builder(
                                controller: scrollController,
                                physics: const ClampingScrollPhysics(),
                                itemCount: historialList.length,
                                itemBuilder: (context, index) {
                                  final item = historialList[index];
                                  final String createdAt = item.created_at ?? '';
                                  final String statusName =
                                      (item.status != null && item.status!.isNotEmpty)
                                      ? item.status!
                                      : 'Por iniciar';

                                  String description = "";
                                  switch (statusName) {
                                    case "Por entregar":
                                      description = "Por iniciar recorrido";
                                      break;
                                    case "En ruta":
                                      description =
                                          "El repartidor inició el recorrido";
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
                    );
                  },
                ),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
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
                  if (detallesTrayecto == true) const Icon(Icons.arrow_forward_ios),
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

                // Obtenemos el color entero de forma segura usando parseColor
                final int resolvedColorValue = parseColor(state?.statusColor?.toString()).value;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(steps.length * 2 - 1, (i) {
                    if (i.isEven) {
                      final index = i ~/ 2;
                      return Expanded(
                        child: _step(
                          colorStatus: resolvedColorValue,
                          title: steps[index]["title"] as String,
                          icon: steps[index]["icon"] as IconData,
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
                            ? Color(resolvedColorValue)
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

  // --- WIDGET PARA MOSTRAR LAS MÉTRICAS DE TIEMPO CALCULADAS ---
  Widget _buildMetricsSummary(List<dynamic> historial) {
    if (historial.isEmpty) return const SizedBox.shrink();

    DateTime? timeEnRuta;
    DateTime? timeEnSitio;
    DateTime? timeFinalizado;

    for (var item in historial) {
      final status = (item.status ?? '').toLowerCase();
      final fechaStr = item.created_at;
      if (fechaStr == null) continue;

      try {
        DateTime parsedDate = DateTime.parse(fechaStr);
        if (status.contains('en ruta')) {
          timeEnRuta = parsedDate;
        } else if (status.contains('en sitio')) {
          timeEnSitio = parsedDate;
        } else if (status.contains('entregado') || status.contains('pendiente')) {
          timeFinalizado = parsedDate;
        }
      } catch (_) {}
    }

    String viajeDuration = "N/D";
    if (timeEnRuta != null && timeEnSitio != null) {
      final diff = timeEnSitio.difference(timeEnRuta);
      viajeDuration = _formatDuration(diff);
    }

    String sitioDuration = "N/D";
    if (timeEnSitio != null && timeFinalizado != null) {
      final diff = timeFinalizado.difference(timeEnSitio);
      sitioDuration = _formatDuration(diff);
    }

    String totalDuration = "N/D";
    if (timeEnRuta != null && timeFinalizado != null) {
      final diff = timeFinalizado.difference(timeEnRuta);
      totalDuration = _formatDuration(diff);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _metricItem("En Ruta", viajeDuration, Icons.directions_car),
          _verticalDivider(),
          _metricItem("En Sitio", sitioDuration, Icons.store),
          _verticalDivider(),
          _metricItem("Total", totalDuration, Icons.timer),
        ],
      ),
    );
  }

  Widget _metricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return "${duration.inMinutes} min";
    } else {
      int hours = duration.inHours;
      int minutes = duration.inMinutes.remainder(60);
      return "${hours}h ${minutes}m";
    }
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
      return const Color(0xFF9E9E9E);
    }
    try {
      String cleanedHex = hexColor
          .toUpperCase()
          .replaceAll('#', '')
          .replaceAll('0X', '')
          .replaceAll('0x', '')
          .trim();
      if (cleanedHex.length == 6) {
        cleanedHex = 'FF$cleanedHex';
      }
      int? colorInt = int.tryParse(cleanedHex, radix: 16);
      return colorInt != null ? Color(colorInt) : const Color(0xFF9E9E9E);
    } catch (e) {
      return const Color(0xFF9E9E9E);
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
                color: itemColor.withValues(alpha: 0.3),
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