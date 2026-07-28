import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/controllers/detalles_folio.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetallesTrayecto extends GetView<DetallesFolioController> {
  final Folios? state;
  final RxInt currentStep;

  DetallesTrayecto({super.key, required this.state, required this.currentStep});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await controller.historialFolio(state?.id ?? "");

        Get.bottomSheet(
          Container(
            padding: const EdgeInsets.only(top: 16.0, left: 8, right: 8),
            width: Get.size.width,
            height: Get.size.height / 2,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                        Icon(Icons.route_outlined, color: Color(0xFF64748B)),
                        SizedBox(width: 8.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Detalles del Trayecto",
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (controller.historialList.any(
                              (item) =>
                                  (item.status ?? '').toLowerCase().contains(
                                    'pospuso',
                                  ) ||
                                  (item.status ?? '').toLowerCase().contains(
                                    'pendiente',
                                  ),
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
                        style: TextStyle(
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
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
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
                            description = "El repartidor inicio el recorrido";
                            break;
                          case "Pendiente":
                            description = "No se realizó la entrega";
                            break;
                          case "En sitio":
                            description =
                                "El repartidor llegó a sitio para realizar la entrega";
                            break;
                          case "Entregado":
                            description = "El repartidor realizó la entrega";
                            break;
                          default:
                        }

                        final String? colorHex = item.statusColor;

                        bool isLast = index == historialList.length - 1;
                        bool isWarning = statusName.toLowerCase().contains(
                          'pospuso',
                        );

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
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
              SizedBox(height: 8.0),
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
                          colorStatus: int.parse(
                            state?.statusColor.toString() ?? "0xFF9E9E9E",
                          ),
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
      return const Color(0xFF22C55E); // Color por defecto (Verde)
    }
    try {
      String cleanedHex = hexColor
          .replaceAll('#', '')
          .replaceAll('0X', '')
          .replaceAll('0x', '');

      if (cleanedHex.length == 6) {
        cleanedHex =
            'FF$cleanedHex'; // Agrega opacidad completa si solo trae 6 caracteres
      }
      return Color(int.parse(cleanedHex, radix: 16));
    } catch (e) {
      return const Color(0xFF22C55E); // Fallback si hay error de formato
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
    // Función auxiliar para convertir HEX a Color de Flutter
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

    // Función auxiliar para formatear la fecha a "hh:mm"
    String formatTimeToHour(String rawTime) {
      if (rawTime.isEmpty) return '';
      try {
        DateTime parsedDate = DateTime.parse(rawTime);
        // Extrae hora y minuto con ceros a la izquierda si es necesario
        String hour = parsedDate.hour.toString().padLeft(2, '0');
        String minute = parsedDate.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      } catch (e) {
        return rawTime; // Devuelve el texto original si falla el parseo
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

              // Hora formateada (hh:mm)
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
