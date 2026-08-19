import 'package:bitacora_frontend/presentation/folios/controllers/folios.controller.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EasyDateTimelinePage extends GetView<FoliosController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Center(
                  child: InkWell(
                    onTap: () async {
                      controller.controllerEasyDate.animateToCurrentDate();
                      controller.selectedDate = DateTime.now();

                      controller.fechaSeleccionada.value = DateTime.now()
                          .toIso8601String()
                          .split('T')[0];
                      await controller.getFoliosWithDate();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 100,
                      width: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 202, 202, 202),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.today_outlined),
                          Text(
                            "Hoy",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100, child: VerticalDivider(width: 0)),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme:
                        ColorScheme.fromSeed(
                          seedColor: const Color(0XFF1D6CFF),
                          brightness: Brightness.light,
                        ).copyWith(
                          primary: const Color(0XFF1D6CFF),
                          primaryContainer: const Color(0XFF1D6CFF),
                          onPrimaryContainer: Colors.white,
                        ),
                  ),
                  child: EasyDateTimeLinePicker(
                    controller: controller.controllerEasyDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 14),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 5)),
                    focusedDate: controller.selectedDate ?? DateTime.now(),
                    headerOptions: const HeaderOptions(
                      headerType: HeaderType.none,
                    ),
                    locale: const Locale('es'),
                    timelineOptions: const TimelineOptions(height: 100),
                    onDateChange: (selectedDate) async {
                      controller.selectedDate = selectedDate;
                      controller.fechaSeleccionada.value = selectedDate
                          .toIso8601String()
                          .split('T')[0];
                      await controller.getFoliosWithDate();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
