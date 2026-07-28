import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class AppBarWithoutImage extends GetView implements PreferredSizeWidget {
  final String? title;
  final Folios? state;
  const AppBarWithoutImage({super.key, required this.title, this.state});

  @override
  Widget build(BuildContext context) {
    SampleItem? selectedItem;

    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      title: Text(
        title ?? "",
        style: const TextStyle(color: Color(0xFF0F172A)),
      ),
      actions: [
        PopupMenuButton<SampleItem>(
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
            } else if (item == SampleItem.itemThree) {}
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
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
            const PopupMenuItem<SampleItem>(
              value: SampleItem.itemTwo,
              child: Row(
                children: [
                  Icon(Icons.comment_outlined),
                  SizedBox(width: 8),
                  Text('Comentarios'),
                ],
              ),
            ),
            const PopupMenuItem<SampleItem>(
              value: SampleItem.itemThree,
              child: Row(
                children: [
                  Icon(Icons.note_outlined),
                  SizedBox(width: 8),
                  Text('Notas'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
