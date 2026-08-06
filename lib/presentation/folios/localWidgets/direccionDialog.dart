import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

Future<dynamic> direccionDialog({Folios? folio}) {
  return Get.dialog(
    Dialog(
      backgroundColor: const Color(0XFFF8FAFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      // Controlamos el ancho ideal para pantallas web/escritorio
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado del Diálogo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Detalles de Dirección",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF1D6CFF),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () => Get.back(),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Contenedor de información
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
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
                    const Divider(height: 24),
                    _buildInfoRow(Icons.map, "Colonia:", folio?.colonia),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.location_city, "Municipio:", folio?.municipio),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.markunread_mailbox, "C.P.:", folio?.codigoPostal),
                    const SizedBox(height: 20),
                    
                    // Botón de Google Maps optimizado para web
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0XFF1D6CFF),
                          side: const BorderSide(color: Color(0XFF1D6CFF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text(
                          "Abrir en Google Maps",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
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
                            // En web, 'externalApplication' abre una nueva pestaña de forma nativa
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
              const SizedBox(height: 20),

              // Botón de Acción Inferior (Aceptar)
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFF1D6CFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    "Aceptar",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildInfoRow(IconData icon, String label, String? value) {
  return Row(
    children: [
      Icon(icon, size: 16, color: Colors.grey[600]),
      const SizedBox(width: 8),
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          value ?? "No especificado",
          style: const TextStyle(fontSize: 14, color: Colors.black54),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}