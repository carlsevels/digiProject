import 'package:bitacora_frontend/infrastructure/models/clientes.dart';
import 'package:bitacora_frontend/infrastructure/models/refacciones.dart';
import 'package:bitacora_frontend/infrastructure/models/users.dart';
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
      body: controller.obx(
        (state) {
          return RefreshIndicator(
            color: Colors.white,
            backgroundColor: const Color(0XFF1D6CFF),
            onRefresh: () => controller.onInitFunction(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final fecha = DateTime.tryParse(
                        controller.fechaSeleccionada.value,
                      );

                      if (fecha == null) {
                        return const Text('');
                      }

                      final hoy = DateTime.now();

                      final esHoy =
                          fecha.year == hoy.year &&
                          fecha.month == hoy.month &&
                          fecha.day == hoy.day;

                      if (esHoy) {
                        return const Text(
                          'Hoy',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        );
                      }

                      const meses = [
                        'Enero',
                        'Febrero',
                        'Marzo',
                        'Abril',
                        'Mayo',
                        'Junio',
                        'Julio',
                        'Agosto',
                        'Septiembre',
                        'Octubre',
                        'Noviembre',
                        'Diciembre',
                      ];

                      return Text(
                        'Para el ${fecha.day} de ${meses[fecha.month - 1]}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                    Divider(),
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
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<Clientes>.empty();
                                  }
                                  return controller.clientesModel.where((
                                    Clientes c,
                                  ) {
                                    if (c.id == 0) return false;
                                    final query = textEditingValue.text
                                        .toLowerCase();
                                    return c.id.toString().contains(query) ||
                                        (c.nombreComercial
                                                ?.toLowerCase()
                                                .contains(query) ??
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
                          if (value != null)
                            controller.refaccionId.value = value;
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
                                child: Text(
                                  condicionPago.nombre ?? 'Sin nombre',
                                ),
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
        },
        onError: (error) {
          if (error.toString().contains('SocketException') ||
              error.toString().contains('no internet')) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wifi_off,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Sin conexión a internet",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "No pudimos conectar con el servidor. Por favor, verifica tu conexión e intenta de nuevo.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.onInit();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Reintentar conexión"),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(child: Text("Ocurrió un error inesperado: $error"));
        },
      ),
    );
  }
}
