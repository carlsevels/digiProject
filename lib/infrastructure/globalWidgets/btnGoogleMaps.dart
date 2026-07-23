import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/controllers/detalles_folio.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class BtnGoogleMaps extends  GetView<DetallesFolioController> {
  final Folios? state;

  BtnGoogleMaps({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0XFF1D6CFF),
          side: const BorderSide(color: Color(0XFF1D6CFF)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.map_outlined, size: 18),
        label: const Text("Abrir en Google Maps"),
        onPressed: () async {
          final String direccionQuery = [
            state?.calle,
            if (state?.numExt != null) '#${state?.numExt}',
            state?.colonia,
            state?.municipio,
            state?.codigoPostal,
          ].where((e) => e != null && e.toString().isNotEmpty).join(', ');

          final Uri googleMapsUrl = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(direccionQuery)}',
          );

          if (await canLaunchUrl(googleMapsUrl)) {
            await launchUrl(
              googleMapsUrl,
              mode: LaunchMode.externalApplication,
            );
          } else {
            Get.snackbar("Error", "No se pudo abrir Google Maps");
          }
        },
      ),
    );
  }
}
