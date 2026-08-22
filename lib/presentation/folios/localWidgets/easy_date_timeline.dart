import 'package:bitacora_frontend/presentation/folios/controllers/folios.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';

class BitacoraCalendar extends GetView<FoliosController> {
  final Function(DateTime) onDateSelected;

  const BitacoraCalendar({super.key, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDate = today.subtract(const Duration(days: 15));
    final lastDate = today.add(const Duration(days: 5));

    return Row(
      children: [
        const SizedBox(width: 8),

        // ============================================================
        // BOTÓN HOY
        // ============================================================
        Container(
          height: 85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                controller.goToToday(onDateSelected);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D6CFF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.today_rounded,
                        color: Color(0xFF1D6CFF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Hoy',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D6CFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // ============================================================
        // CALENDARIO REACTIVO CON Obx
        // ============================================================
        Expanded(
          child: Obx(() {
            // Convertimos la fecha seleccionada en string o Rx a DateTime para el focusDate
            DateTime fechaFocuseada =
                DateTime.tryParse(controller.fechaSeleccionada.value) ??
                DateTime.now();

            return EasyInfiniteDateTimeLine(
              locale: 'es',
              showTimelineHeader: false,
              controller: controller.timelineController,
              firstDate: firstDate,
              lastDate: lastDate,
              focusDate:
                  fechaFocuseada, // Ahora reacciona dinámicamente al cambio sin redibujar toda la pantalla
              onDateChange: (date) async {
                controller.changeDate(date, onDateSelected);
                await controller.getFoliosWithDate();
              },
              dayProps: EasyDayProps(
                height: 85,
                width: 65,
                dayStructure: DayStructure.monthDayNumDayStr,
                activeDayStyle: DayStyle(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    color: Color(0xFF1D6CFF),
                  ),
                  dayNumStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  dayStrStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  monthStrStyle: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                inactiveDayStyle: DayStyle(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    color: Colors.grey.shade200,
                  ),
                  dayNumStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  dayStrStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  monthStrStyle: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
