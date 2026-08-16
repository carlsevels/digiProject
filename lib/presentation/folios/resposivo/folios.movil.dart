import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/controllers/folios.controller.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/direccionDialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FoliosMovilView extends GetView<FoliosController> {
  final List<Folios> state;

  FoliosMovilView({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: const Color(0XFF1D6CFF),
      onRefresh: () => controller.getFoliosWithDate(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state!.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => Text(
                          controller.obtenerEtiquetaFecha(
                            DateTime.tryParse(
                                  controller.fechaSeleccionada.value,
                                ) ??
                                DateTime.now(),
                          ),
                          textScaler: const TextScaler.linear(1.8),
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(50, 30),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                        onPressed: () {
                          Get.toNamed(Routes.ADD_FOLIOS);
                        },
                        icon: const Icon(Icons.add, color: Color(0XFF1D6CFF)),
                        label: const Text(
                          "Agregar Folio",
                          style: TextStyle(color: Color(0XFF1D6CFF)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }
          final folio = state[index - 1];

          final int colorInt =
              (folio.statusColor != null &&
                  folio.statusColor.toString().isNotEmpty)
              ? (int.tryParse(folio.statusColor.toString()) ?? 0xFF9E9E9E)
              : 0xFF9E9E9E;

          return InkWell(
            onLongPress: () {
              direccionDialog(folio: folio);
            },
            onTap: () {
              if (folio.folioId != null) {
                Get.toNamed(
                  Routes.DETALLES_FOLIO,
                  arguments: folio.folioId.toString(),
                );
              }
            },
            child: Dismissible(
              key: ValueKey(folio.id),
              direction: controller.rolName == "Reparto"
                  ? DismissDirection.startToEnd
                  : DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  final bool? confirmacion = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundColor: Color(0xFFE8F0FE),
                                child: Icon(
                                  Icons.archive_outlined,
                                  size: 40,
                                  color: Color(0xFF1A73E8),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Archivar Folio',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '¿Estás seguro de enviar el folio #${folio.folioId ?? ""} al archivo?',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      controller.archivarFolio(
                                        folio.folioId ?? "",
                                      );
                                      Navigator.pop(context, true);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Archivar'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  return confirmacion ?? false;
                }
                if (direction == DismissDirection.endToStart) {
                  final bool? confirmacion = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundColor: Color(0xFFFEECEC),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 40,
                                  color: Color(0xFFD9534F),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Eliminar Folio',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '¿Estás seguro de eliminar el folio #${folio.folioId ?? ""}? Esta acción no se puede deshacer.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      controller.eliminarFolio(
                                        folio.folioId ?? "",
                                      );
                                      Navigator.pop(context, true);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD9534F),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  return confirmacion ?? false;
                }
                return true;
              },
              background: Container(
                color: Colors.orange,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Row(
                  children: [
                    Icon(Icons.archive_outlined, color: Colors.white, size: 30),
                    SizedBox(width: 8),
                    Text(
                      'Archivar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Eliminar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.delete_outline, color: Colors.white, size: 30),
                  ],
                ),
              ),
              child: ListTile(
                style: ListTileStyle.list,
                dense: true,
                isThreeLine: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Column(
                  children: [
                    Text(
                      folio.cantidad.toString(),
                      textScaler: const TextScaler.linear(3.2),
                      style: const TextStyle(height: 1),
                    ),
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 35),
                        child: Text(
                          folio.tiporefaccion.toString(),
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
                        folio.nombreComercial ?? 'Sin nombre comercial',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (folio.municipio != null &&
                              folio.municipio!.trim().isNotEmpty) ...[
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Color(0XFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                folio.municipio!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0XFF64748B),
                                ),
                              ),
                            ),
                            const Text(
                              " - ",
                              style: TextStyle(color: Color(0XFF64748B)),
                            ),
                          ],
                          if (folio.condicionPago != null &&
                              folio.condicionPago!.trim().isNotEmpty) ...[
                            const Icon(
                              Icons.payments_outlined,
                              size: 16,
                              color: Color(0XFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                folio.condicionPago!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0XFF64748B),
                                ),
                              ),
                            ),
                            if (folio.folioId != null &&
                                folio.folioId.toString().trim().isNotEmpty)
                              const Text(
                                " - ",
                                style: TextStyle(color: Color(0XFF64748B)),
                              ),
                          ],
                          if (folio.folioId != null &&
                              folio.folioId.toString().trim().isNotEmpty) ...[
                            const Icon(
                              Icons.confirmation_number_outlined,
                              size: 16,
                              color: Color(0XFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                folio.folioId.toString(),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0XFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: folio.status != "Por entregar"
                            ? Color(colorInt)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Color(colorInt)),
                      ),
                      child: Text(
                        folio.status.toString(),
                        style: TextStyle(
                          color: folio.status == "Por entregar"
                              ? Color(colorInt)
                              : Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
