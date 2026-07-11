import 'package:bitacora_frontend/presentation/add_folios/localWidgets/dropdown.dart';
import 'package:bitacora_frontend/presentation/add_folios/localWidgets/inputText.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/add_cliente.controller.dart';

class AddClienteScreen extends GetView<AddClienteController> {
  const AddClienteScreen({super.key});
  @override
  Widget build(BuildContext context) {
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
              InputText(
                title: "Razon Social",
                hintText: "Escribe aqui la razon social",
              ),
              SizedBox(height: 8),
              InputText(
                title: "Nombre comercial",
                hintText: "Escribe aqui el nombre comercial",
              ),
              SizedBox(height: 8),
              Text(
                "Cliente",
                textScaleFactor: 1.2,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              InputText(title: "Calle", hintText: "Escribe aqui la calle"),
              SizedBox(height: 8),
              InputText(title: "Colonia", hintText: "Escribe aqui la colonia"),
              SizedBox(height: 8),
              SizedBox(height: 8),
              InputText(title: "Codigo Postal", hintText: "Ej. 67198"),
              SizedBox(height: 8),
              InputText(title: "Numero exterior", hintText: "# exterior"),
              SizedBox(height: 8),
              InputText(title: "Numero interior", hintText: "# interior"),
              SizedBox(height: 8),
              InputText(title: "Municipio", hintText: "Seleccionar municipio"),
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
                  onPressed: () {},
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
