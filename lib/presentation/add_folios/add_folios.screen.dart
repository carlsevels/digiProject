import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/clientes.dart';
import 'package:bitacora_frontend/infrastructure/models/refacciones.dart';
import 'package:bitacora_frontend/infrastructure/models/users.dart';
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
    return Scaffold(
      backgroundColor: Color(0XFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Color(0XFFF8FAFC),
        centerTitle: false,
        title: Text("Nuevo Folio"),
        actions: [
          SizedBox(
            height: 50,
            child: Image.asset(
              "assets/logos/digireyShort.png",
              opacity: const AlwaysStoppedAnimation(.5),
            ),
          ),
        ],
      ),
      body: controller.obx((state) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tipo de documento",
                  textScaleFactor: 1.2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0XFF0F172A),
                  ),
                ),
                SizedBox(height: 4.0),
                Obx(() {
                  final uniqueTipoDocumento = <int, GeneralModel>{};

                  for (var c in controller.tipoDocumento) {
                    if (c.id != null) {
                      uniqueTipoDocumento[c.id!] = c;
                    }
                  }
                  return DropdownWidget(
                    title: "Tipo de documento",
                    dropdownValue: controller.tipoDocumentoId.value,
                    onChanged: (int? value) {
                      if (value != null) {
                        controller.tipoDocumentoId.value = value;
                      }
                    },
                    items: uniqueTipoDocumento.values
                        .map<DropdownMenuItem<int>>((GeneralModel cliente) {
                          return DropdownMenuItem<int>(
                            value: cliente.id ?? 0,
                            child: Text(cliente.nombre ?? 'Sin nombre'),
                          );
                        })
                        .toList(),
                  );
                }),
                Obx(() {
                  if (controller.tipoDocumentoId.value != 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        InputText(
                          keyboardType: TextInputType.number,
                          textController: controller.numReporteController,
                          title: controller.tipoDocumentoId.value == 1
                              ? "Numero de Factura"
                              : "Numero de Folio",
                          hintText: "Escribe el numero aqui",
                        ),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),

                SizedBox(height: 8),
                Text(
                  "Cliente",
                  textScaleFactor: 1.2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0XFF0F172A),
                  ),
                ),
                Text(
                  "Buscar Nombre o nombre comercial",
                  style: TextStyle(color: Color(0XFF0F172A)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Obx(() {
                        final uniqueClientes = <int, Clientes>{};
                        for (var c in controller.clientesModel) {
                          if (c.id != null) {
                            uniqueClientes[c.id!] = c;
                          }
                        }
                        return Container(
                          height: 40,

                          child: Autocomplete<Clientes>(
                            displayStringForOption: (Clientes option) =>
                                option.nombreComercial ?? "",

                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<Clientes>.empty();
                                  }

                                  return controller.clientesModel.where((
                                    Clientes c,
                                  ) {
                                    final nombre =
                                        c.nombreComercial?.toLowerCase() ?? '';
                                    return nombre.contains(
                                      textEditingValue.text.toLowerCase(),
                                    );
                                  });
                                },

                            fieldViewBuilder:
                                (
                                  context,
                                  textController,
                                  focusNode,
                                  onFieldSubmitted,
                                ) {
                                  return TextField(
                                    controller: textController,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                      label: Text(
                                        'Buscar Cliente',
                                        style: TextStyle(
                                          color: Color(0XFF64748B),
                                        ),
                                      ),
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.search),
                                    ),
                                  );
                                },

                            onSelected: (Clientes selection) {
                              controller.clienteId.value = selection.id ?? 0;
                              print(controller.clienteId.value);
                            },
                          ),
                        );
                      }),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0XFF0F172A),
                  ),
                ),
                SizedBox(height: 4.0),

                SizedBox(height: 8),
                InputText(
                  title: "Cantidad",
                  hintText: "Escribir la cantidad",
                  textController: controller.cantidadController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 8),
                Obx(() {
                  final uniqueRefacciones = <int, GeneralModel>{};

                  for (var c in controller.refacciones) {
                    if (c.id != null) {
                      uniqueRefacciones[c.id!] = c;
                    }
                  }
                  return DropdownWidget(
                    title: "Tipo de refaccion",
                    dropdownValue: controller.refaccionId.value,
                    onChanged: (int? value) {
                      if (value != null) {
                        controller.refaccionId.value = value;
                      }
                    },
                    items: uniqueRefacciones.values.map<DropdownMenuItem<int>>((
                      GeneralModel cliente,
                    ) {
                      return DropdownMenuItem<int>(
                        value: cliente.id ?? 0,
                        child: Text(cliente.nombre ?? 'Sin nombre'),
                      );
                    }).toList(),
                  );
                }),
                SizedBox(height: 8),
                Obx(() {
                  final uniqueCondicionPago = <int, GeneralModel>{};
                  for (var c in controller.condicionPago) {
                    if (c.id != null) {
                      uniqueCondicionPago[c.id!] = c;
                    }
                  }
                  return DropdownWidget(
                    title: "Condicion de Pago",
                    dropdownValue: controller.condicionPagoId.value,
                    onChanged: (int? value) {
                      if (value != null) {
                        controller.condicionPagoId.value = value;
                      }
                    },
                    items: uniqueCondicionPago.values
                        .map<DropdownMenuItem<int>>((
                          GeneralModel condicionPago,
                        ) {
                          return DropdownMenuItem<int>(
                            value: condicionPago.id!,
                            child: Text(condicionPago.nombre ?? 'Sin nombre'),
                          );
                        })
                        .toList(),
                  );
                }),
                SizedBox(height: 8),
                Text(
                  "Repartidor",
                  textScaleFactor: 1.2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0XFF0F172A),
                  ),
                ),
                SizedBox(height: 4.0),
                Obx(() {
                  final uniqueReparto = <int, Users>{};

                  for (var c in controller.reparto) {
                    if (c.id != null) {
                      uniqueReparto[c.id!] = c;
                    }
                  }
                  return DropdownWidget<int>(
                    title: "Seleccionar repartidor",
                    dropdownValue: controller.repartidorId.value,
                    onChanged: (int? value) {
                      if (value != null) {
                        controller.repartidorId.value = value;
                        print(jsonEncode(controller.reparto));
                      }
                    },
                    items: uniqueReparto.values.map<DropdownMenuItem<int>>((
                      Users reparto,
                    ) {
                      return DropdownMenuItem<int>(
                        value: reparto.id,
                        child: Text(reparto.nombre ?? 'Sin nombre'),
                      );
                    }).toList(),
                  );
                }),
                SizedBox(height: 8),
                Container(
                  width: Get.size.width,
                  child: FilledButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      backgroundColor: const Color(0XFF1D6CFF),
                      foregroundColor: Colors.white,
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
        );
      }),
    );
  }
}
