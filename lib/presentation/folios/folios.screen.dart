import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/folios.controller.dart';

class FoliosScreen extends GetView<FoliosController> {
  const FoliosScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFF8FAFC),
      appBar: AppBar(backgroundColor: Color(0XFFF8FAFC)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Hoy", textScaleFactor: 1.8),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    minimumSize: Size(50, 30),

                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    backgroundColor: Color(0XFF1D6CFF),
                    foregroundColor: Color(0XFFFFFFFF),
                  ),
                  onPressed: () {
                    Get.toNamed(Routes.ADD_FOLIOS);
                  },
                  icon: Icon(Icons.add),
                  label: Text("Agregar folio", style: TextStyle(fontSize: 14)),
                ),
              ],
            ),

            InkWell(
              onTap: () {},
              child: ListTile(
                isThreeLine: true,
                contentPadding: EdgeInsets.zero,
                leading: Column(
                  children: [
                    Text("3", textScaleFactor: 2),
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 35),
                        child: Text(
                          "Multifuncional",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text("TERNIUM"),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Color(0XFF64748B),
                          ),
                          Flexible(
                            child: Text(
                              "Guadalupe - Renta - 103325",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Color(0XFF64748B)),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: const Color(0XFF1D6CFF)),
                      ),
                      child: const Text(
                        "Por entregar",
                        style: TextStyle(
                          color: Color(0XFF1D6CFF),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: ListTile(
                isThreeLine: true,
                contentPadding: EdgeInsets.zero,
                leading: Column(
                  children: [
                    Text("1", textScaleFactor: 2),
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 35),
                        child: Text(
                          "Toner",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text("TERNIUM"),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Color(0XFF64748B),
                          ),
                          Flexible(
                            child: Text(
                              "Guadalupe - Renta - 103325",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Color(0XFF64748B)),
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
                        color: Color(0xffFF6B35),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        "En ruta",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        // // Text(
        // //   selectedDate != null
        // //       ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
        // //       : 'No date selected',
        // // ),
        IconButton(onPressed: _selectDate, icon: Icon(Icons.filter_list)),
      ],
    );
  }
}
