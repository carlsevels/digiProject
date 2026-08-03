import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class AppBarWithoutImage extends GetView implements PreferredSizeWidget {
  final String? title;
  final Folios? state;
  final void Function()? onPressedDeleted;
  final void Function()? onPressedArchived;
  final void Function()? onPressedRestaurar;

  const AppBarWithoutImage({
    super.key,
    required this.title,
    this.state,
    this.onPressedDeleted,
    this.onPressedArchived,
    this.onPressedRestaurar,
  });

  @override
  Widget build(BuildContext context) {
    SampleItem? selectedItem;

    final bool isArchived = state?.isArchived ?? false;
    return AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(
        title ?? "",
        style: const TextStyle(color: Color(0xFF0F172A)),
      ),
      actions: [
        PopupMenuButton<SampleItem>(
          position: PopupMenuPosition.under,
          color: Colors.white,
          initialValue: selectedItem,
          onSelected: (SampleItem item) async {
            selectedItem = item;

            if (item == SampleItem.itemOne) {
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
            } else if (item == SampleItem.itemTwo) {
              showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: isArchived
                              ? Color(0xFFE8F5E9)
                              : Color(0xFFE8F0FE),
                          child: Icon(
                            isArchived
                                ? Icons.settings_backup_restore_rounded
                                : Icons.archive_outlined,
                            size: 40,
                            color: isArchived
                                ? const Color(0xFF319F43)
                                : Color(0xFF1A73E8),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isArchived ? 'Restaurar Folio' : 'Archivar Folio',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isArchived
                              ? '¿Estás seguro de restaurar este folio?'
                              : '¿Estás seguro de archivar este folio?',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                if (isArchived) {
                                  onPressedRestaurar?.call();
                                } else {
                                  onPressedArchived?.call();
                                }
                              },
                              style: isArchived
                                  ? ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF319F43),
                                      foregroundColor: Colors.white,
                                    )
                                  : ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                              child: Text(
                                isArchived ? 'Restaurar' : 'Archivar',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (item == SampleItem.itemThree) {
              showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAppBarIconPlaceholder(
                          icon: Icons.delete_outline_rounded,
                          color: Color(0xFFD9534F),
                          bgColor: Color(0xFFFEECEC),
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
                        const Text(
                          '¿Estás seguro de eliminar este folio?',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onPressedDeleted?.call();
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
                ),
              );
            }
          },
          itemBuilder: (BuildContext context) {
            return <PopupMenuEntry<SampleItem>>[
              const PopupMenuItem<SampleItem>(
                value: SampleItem.itemOne,
                child: Row(
                  children: [
                    Icon(Icons.map_outlined),
                    SizedBox(width: 8),
                    Text('Maps'),
                  ],
                ),
              ),
              PopupMenuItem<SampleItem>(
                value: SampleItem.itemTwo,
                child: Row(
                  children: [
                    Icon(
                      isArchived
                          ? Icons.settings_backup_restore_rounded
                          : Icons.archive_outlined,
                    ),
                    const SizedBox(width: 8),
                    Text(isArchived ? 'Restaurar' : 'Archivar'),
                  ],
                ),
              ),
              const PopupMenuItem<SampleItem>(
                value: SampleItem.itemThree,
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Eliminar'),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CircleAppBarIconPlaceholder extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;

  const CircleAppBarIconPlaceholder({
    super.key,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: bgColor,
      child: Icon(icon, size: 40, color: color),
    );
  }
}
