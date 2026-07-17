import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/folios.empty.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/folios.controller.dart';

class FoliosScreen extends GetView<FoliosController> {
  const FoliosScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFF8FAFC),
      body: controller.obx(
        onEmpty: RefreshIndicator(
          onRefresh: () async {
            await controller.getFoliosWithDate();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [SizedBox(height: 200), FoliosEmptyPage()],
          ),
        ),
        (state) => RefreshIndicator(
          color: Colors.white,
          backgroundColor: Color(0XFF1D6CFF),
          onRefresh: () => controller.getFoliosWithDate(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: state!.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Hoy", textScaleFactor: 1.8),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            minimumSize: const Size(50, 30),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            backgroundColor: const Color(0XFF1D6CFF),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Get.toNamed(Routes.ADD_FOLIOS);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text(
                            "Agregar folio",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }

              final folio = state[index - 1];

              return InkWell(
                onTap: () {
                  if (folio.folioId != null) {
                    Get.toNamed(
                      Routes.DETALLES_FOLIO,
                      arguments: folio.folioId.toString(),
                    );
                  } else {
                    print("ERROR: folioId es null, por eso no se envía nada.");
                  }
                },
                child: ListTile(
                  isThreeLine: false,
                  contentPadding: EdgeInsets.zero,
                  leading: Column(
                    children: [
                      Text(
                        folio.cantidad.toString(),
                        textScaleFactor: 3.5,
                        style: TextStyle(height: 1),
                      ),
                      Flexible(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 35),
                          child: Text(
                            folio.tiporefaccion.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(folio.nombreComercial.toString()),
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
                                "${folio.municipio} - ${folio.condicionPago} - ${folio.folioId.toString()}",
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
                          color: folio.status != "Por entregar"
                              ? Color(int.parse(folio.statusColor.toString()))
                              : Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Color(
                              int.parse(folio.statusColor.toString()),
                            ),
                          ),
                        ),
                        child: Text(
                          folio.status.toString(),
                          style: TextStyle(
                            color: folio.status == "Por entregar"
                                ? Color(int.parse(folio.statusColor.toString()))
                                : Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class DatePickerExample extends StatefulWidget {
  const DatePickerExample({super.key});

  @override
  State<DatePickerExample> createState() => _DatePickerExampleState();
}

class _DatePickerExampleState extends State<DatePickerExample> {
  DateTime? selectedDate;

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2021, 7, 25),
      firstDate: DateTime(2021),
      lastDate: DateTime(2022),
    );

    setState(() {
      selectedDate = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      spacing: 20,
      children: <Widget>[
        // Text(
        //   selectedDate != null
        //       ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
        //       : 'No date selected',
        // ),
        IconButton(onPressed: _selectDate, icon: Icon(Icons.filter_list)),
      ],
    );
  }
}
