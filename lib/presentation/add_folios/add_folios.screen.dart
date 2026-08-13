import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/barcode.dart';
import 'package:bitacora_frontend/infrastructure/models/clientes.dart';
import 'package:bitacora_frontend/infrastructure/models/refacciones.dart';
import 'package:bitacora_frontend/infrastructure/models/users.dart';
import 'package:bitacora_frontend/presentation/add_folios/localWidgets/dropdown.dart';
import 'package:bitacora_frontend/presentation/add_folios/localWidgets/inputText.dart';
import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';

import 'package:get/get.dart';

import 'controllers/add_folios.controller.dart';

class AddFoliosScreen extends GetView<AddFoliosController> {
  const AddFoliosScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFF8FAFC),
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        title: Text("Nuevo Folio"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset("assets/logos/digiAppShort.jpeg", height: 30),
          ),
        ],
      ),
      body: controller.obx((state) {
        return RefreshIndicator(
          color: Colors.white,
          backgroundColor: const Color(0XFF1D6CFF),
          onRefresh: () => controller.onInitFunction(),
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // Obliga a que siempre haya scroll para activar el pull-to-refresh
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Tipo de documento
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

                  // Campo condicional de número de reporte
                  Obx(() {
                    if (controller.tipoDocumentoId.value != 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          InputText(
                            externalButton: _buildDemoButton(
                              context: context,
                              scanner: AiBarcodeScanner(
                                onDetect: (BarcodeCapture capture) {
                                  if (controller.isProcessingBarcode.value)
                                    return;
                                  controller.isProcessingBarcode.value = true;

                                  final String nuevoCodigo =
                                      capture.barcodes.first.displayValue ?? "";

                                  if (nuevoCodigo.isNotEmpty) {
                                    final String textoActual = controller
                                        .numReporteController
                                        .text
                                        .trim();

                                    if (textoActual.isEmpty) {
                                      controller.numReporteController.text =
                                          nuevoCodigo;
                                    } else {
                                      List<String> codigosList = textoActual
                                          .split(',')
                                          .map((e) => e.trim())
                                          .toList();
                                      if (!codigosList.contains(nuevoCodigo)) {
                                        controller.numReporteController.text =
                                            "$textoActual, $nuevoCodigo";
                                      }
                                    }
                                  }

                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ),
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
                    "Buscar Razon Social o Nombre Comercial",
                    style: TextStyle(color: Color(0XFF0F172A)),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Autocomplete<Clientes>(
                          displayStringForOption: (Clientes option) =>
                              "${option.id} - ${option.nombreComercial} - ${option.razonSocial}",
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<Clientes>.empty();
                            }
                            return controller.clientesModel.where((Clientes c) {
                              if (c.id == 0) return false;
                              final query = textEditingValue.text.toLowerCase();
                              return c.id.toString().contains(query) ||
                                  (c.nombreComercial?.toLowerCase().contains(
                                        query,
                                      ) ??
                                      false) ||
                                  (c.razonSocial?.toLowerCase().contains(
                                        query,
                                      ) ??
                                      false);
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
                          },
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
                  SizedBox(height: 4),
                  Obx(() {
                    final uniqueRefacciones = <int, GeneralModel>{};
                    for (var c in controller.refacciones) {
                      if (c.id != null) uniqueRefacciones[c.id!] = c;
                    }
                    return DropdownWidget(
                      title: "Tipo de refaccion",
                      dropdownValue: controller.refaccionId.value,
                      onChanged: (int? value) {
                        if (value != null) controller.refaccionId.value = value;
                      },
                      items: uniqueRefacciones.values
                          .map<DropdownMenuItem<int>>((GeneralModel cliente) {
                            return DropdownMenuItem<int>(
                              value: cliente.id ?? 0,
                              child: Text(cliente.nombre ?? 'Sin nombre'),
                            );
                          })
                          .toList(),
                    );
                  }),

                  SizedBox(height: 8),
                  InputText(
                    title: "Cantidad",
                    hintText: "Escribir la cantidad que se va a entregar",
                    textController: controller.cantidadController,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 8),

                  Obx(() {
                    final uniqueCondicionPago = <int, GeneralModel>{};
                    for (var c in controller.condicionPago) {
                      if (c.id != null) uniqueCondicionPago[c.id!] = c;
                    }
                    return DropdownWidget(
                      title: "Condicion de Pago",
                      dropdownValue: controller.condicionPagoId.value,
                      onChanged: (int? value) {
                        if (value != null)
                          controller.condicionPagoId.value = value;
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
                      if (c.id != null) uniqueReparto[c.id!] = c;
                    }
                    return DropdownWidget<int>(
                      title: "Seleccionar repartidor",
                      dropdownValue: controller.repartidorId.value,
                      onChanged: (int? value) {
                        if (value != null)
                          controller.repartidorId.value = value;
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

                  SizedBox(height: 24),

                  // Botón de acción principal al final del formulario
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        backgroundColor: const Color(0XFF1D6CFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        controller.postFolio();
                      },
                      child: const Text(
                        "Agregar",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  // Espaciado extra de seguridad abajo para que el botón no quede pegado al borde del celular
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Helper method to create a styled button for the demo list.
  Widget _buildDemoButton({required context, required Widget scanner}) {
    return IconButton(
      onPressed: () => controller.navigateToScanner(scanner, context),
      icon: Icon(Icons.qr_code),
    );
  }
}
