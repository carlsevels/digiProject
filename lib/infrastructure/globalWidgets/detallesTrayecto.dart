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
    return Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Row(
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
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            Obx(() {
              final steps = [
                {"title": "Por iniciar", "icon": Icons.local_shipping_outlined},
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
