import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/controllers/detalles_folio.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Direccion extends GetView<DetallesFolioController> {
  final Folios? state;

  Direccion({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    // Construimos la dirección completa para Google Maps (esto ya lo tienes, solo referencia)
    String direccionCompleta = "${state?.calle ?? ''} #${state?.numExt ?? ''}, "
        "${state?.colonia ?? ''}, ${state?.municipio ?? ''}, C.P. ${state?.codigoPostal ?? ''}";

    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      color: Colors.white,
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Padding uniforme más limpio
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_outlined, color: Color(0XFF64748B)),
                const SizedBox(width: 8.0),
                const Text(
                  "Dirección",
                  style: TextStyle(
                    color: Color(0XFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // --- Fila de Calle y Número (Probable causa del error) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                // ENVOLVEMOS EL TEXTO LARGO EN EXPANDED
                Expanded(
                  child: Text(
                    "${state?.calle ?? 'S/N'} #${state?.numExt ?? ''}"
                    "${(state?.numInt != null && state!.numInt.toString().isNotEmpty) ? ' Int. ${state?.numInt}' : ''}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    // Opcional: si quieres que fuerce salto de línea en lugar de puntos suspensivos
                    // softWrap: true, 
                  ),
                ),
              ],
            ),
            const Divider(height: 16, color: Colors.black12),
            // --- Fila de Colonia ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Alineación arriba
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
                // ENVOLVEMOS EL TEXTO LARGO EN EXPANDED
                Expanded(
                  child: Text(
                    state?.colonia ?? "No especificada",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    // Esto permite que la colonia ocupe 2 o más líneas si es necesario
                    // en lugar de cortarse con ellipsis (...)
                    // overflow: TextOverflow.visible, 
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // --- Fila de Municipio ---
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
                // ENVOLVEMOS EL TEXTO LARGO EN EXPANDED
                Expanded(
                  child: Text(
                    state?.municipio ?? "No especificado",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // --- Fila de C.P. ---
            Row(
              children: [
                Icon(
                  Icons.markunread_mailbox,
                  size: 16,
                  color: Colors.grey[600],
                ),
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
                    state?.codigoPostal ?? "No especificado",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // --- (Aquí iría tu botón de mapa que configuramos antes) ---
          ],
        ),
      ),
    );
  }
}