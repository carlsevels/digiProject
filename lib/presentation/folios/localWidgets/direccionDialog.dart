import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

Future<dynamic> direccionDialog({Folios? folio}) {
  return Get.defaultDialog(
    backgroundColor: Color(0XFFF8FAFC),
    title: "Detalles de Dirección",
    titleStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0XFF1D6CFF),
    ),
    middleText: "",
    content: Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${folio?.calle ?? 'S/N'} #${folio?.numExt ?? ''}"
                  "${(folio?.numInt != null && folio!.numInt!.isNotEmpty) ? ' Int. ${folio.numInt}' : ''}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              Icon(Icons.map, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                "Colonia:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  folio?.colonia ?? "No especificada",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.location_city, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                "Municipio:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  folio?.municipio ?? "No especificado",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.markunread_mailbox, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                "C.P.:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  folio?.codigoPostal ?? "No especificado",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0XFF1D6CFF),
                side: const BorderSide(color: Color(0XFF1D6CFF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text("Abrir en Google Maps"),
              onPressed: () async {
                final String direccionQuery = [
                  folio?.calle,
                  if (folio?.numExt != null) '#${folio?.numExt}',
                  folio?.colonia,
                  folio?.municipio,
                  folio?.codigoPostal,
                ].where((e) => e != null && e.isNotEmpty).join(', ');

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
          ),
        ],
      ),
    ),
    textConfirm: "Aceptar",
    confirmTextColor: Colors.white,
    buttonColor: Color(0XFF1D6CFF),
    onConfirm: () => Get.back(),
    radius: 8,
  );
}
