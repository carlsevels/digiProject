import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/controllers/detalles_folio.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RepartidorDetalles extends  GetView<DetallesFolioController> {
  final Folios? state;

  RepartidorDetalles({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state?.repartidor ?? "",
          style: TextStyle(
            color: Color(0XFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w300,
            height: 1.2,
          ),
        ),
        Text(
          "Repartidor",
          style: TextStyle(
            color: Color(0XFF64748B),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ],
    );
  }
}
