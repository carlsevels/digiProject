import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/add_folios/localWidgets/dropdown.dart';
import 'package:bitacora_frontend/presentation/add_folios/localWidgets/inputText.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/add_folios.controller.dart';

class AddFoliosScreen extends GetView<AddFoliosController> {
  const AddFoliosScreen({super.key});
  @override
  Widget build(BuildContext context) {
    RxString dropdownValue = controller.list.first.obs;
    return Scaffold(
      backgroundColor: Color(0XFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Color(0XFFF8FAFC),
        centerTitle: false,
        title: Text("Nuevo Folio"),
        actions: [
          SearchAnchor(
            viewBackgroundColor: Color(0XFFF8FAFC),
            isFullScreen: true,
            viewHintText: "Buscar folio o factura",
            headerHintStyle: TextStyle(color: Color(0XFF64748B)),
            dividerColor: Color(0XFF64748B),
            viewPadding: EdgeInsets.symmetric(horizontal: 16.0),
            builder: (BuildContext context, SearchController controller) {
              return IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => controller.openView(),
              );
            },
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
                  // This triggers when the user types or opens the search view
                  return List<ListTile>.generate(5, (int index) {
                    return ListTile(
                      isThreeLine: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Column(
                        children: [
                          Text("3", textScaleFactor: 2),
                          Text("Toner"),
                        ],
                      ),
                      title: Text("TERNIUM"),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Color(0XFF64748B),
                              ),
                              Text(
                                "Guadalupe - Renta - 103325",
                                style: TextStyle(color: Color(0XFF64748B)),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: const Color(0XFF1D6CFF),
                              ),
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
                    );
                  });
                },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tipo de documento",
                textScaleFactor: 1.2,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Obx(
                () => DropdownWidget(
                  title: "Seleccione tipo",
                  dropdownValue: dropdownValue.value,
                  onChanged: (String? value) {
                    dropdownValue.value = value!;
                  },
                  items: controller.list.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 8),
              InputText(
                title: "Numero de factura",
                hintText: "Escribe el numero aqui",
              ),
              SizedBox(height: 8),
              Text(
                "Cliente",
                textScaleFactor: 1.2,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Buscar Nombre o nombre comercial"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Obx(
                    () => Expanded(
                      child: DropdownWidget(
                        dropdownValue: dropdownValue.value,
                        onChanged: (String? value) {
                          dropdownValue.value = value!;
                        },
                        items: controller.list.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  Center(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        minimumSize: Size(50, 30),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        backgroundColor: Color(0XFF1D6CFF),
                        foregroundColor: Color(0XFFFFFFFF),
                      ),
                      onPressed: () {
                        Get.toNamed(Routes.ADD_CLIENTE);
                      },
                      icon: Icon(Icons.add),
                      label: Text("Nuevo", style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                "Producto",
                textScaleFactor: 1.2,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              DropdownWidget(
                title: "Tipo de refaccion",
                dropdownValue: dropdownValue.value,
                onChanged: (String? value) {
                  dropdownValue.value = value!;
                },
                items: controller.list.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 8),
              InputText(title: "Cantidad", hintText: "Escribir la cantidad"),
              SizedBox(height: 8),
              DropdownWidget(
                title: "Condicion de pago",
                dropdownValue: dropdownValue.value,
                onChanged: (String? value) {
                  dropdownValue.value = value!;
                },
                items: controller.list.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 8),
              Text(
                "Repartidor",
                textScaleFactor: 1.2,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              DropdownWidget(
                dropdownValue: dropdownValue.value,
                onChanged: (String? value) {
                  dropdownValue.value = value!;
                },
                items: controller.list.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 8),
              Container(
                width: Get.size.width,
                child: FilledButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    backgroundColor: const Color(0XFF1D6CFF),
                    foregroundColor: Colors.white, // Color del texto/icono
                  ),
                  onPressed: () {
                    controller.postFolio();
                  },
                  child: Text("Agregar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
