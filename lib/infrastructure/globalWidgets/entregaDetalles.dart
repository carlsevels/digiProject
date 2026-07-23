import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/controllers/detalles_folio.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetallesEntrega extends GetView<DetallesFolioController> {
  final Folios? state;

  DetallesEntrega({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Icon(Icons.local_shipping_outlined, color: Color(0XFF64748B)),
                  SizedBox(width: 8.0),
                  Text(
                    "Detalles del Entrega",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0XFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            ListTile(
              isThreeLine: false,
              contentPadding: EdgeInsets.zero,
              leading: Column(
                children: [
                  Text(
                    state?.cantidad ?? "",
                    textScaleFactor: 3.5,
                    style: TextStyle(height: 1),
                  ),
                  Flexible(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 35),
                      child: Text(
                        state?.tiporefaccion ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.business_center_outlined, size: 20),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      state!.nombreComercial ?? 'Sin nombre comercial',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: controller.parseColor(
                          state?.statusColor?.toString(),
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (state?.municipio != null)
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Color(0XFF64748B),
                          ),
                          Flexible(
                            child: Text(
                              state?.municipio ?? "",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Color(0XFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: state?.status != "Por entregar"
                            ? controller.parseColor(
                                state?.statusColor?.toString(),
                              )
                            : Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: controller.parseColor(
                            state?.statusColor?.toString(),
                          ),
                        ),
                      ),
                      child: Text(
                        state?.status.toString() ?? "",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: state?.status == "Por entregar"
                              ? controller.parseColor(
                                  state?.statusColor?.toString(),
                                )
                              : Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
