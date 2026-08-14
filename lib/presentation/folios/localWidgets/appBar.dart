import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/controllers/folios.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBarView extends GetView<FoliosController>
    implements PreferredSizeWidget {
  const AppBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,

      leading: Builder(
        builder: (context) {
          return InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Center(
              child: Obx(
                () => Text(
                  controller.nameUser.value.isNotEmpty
                      ? controller.nameUser.value[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff1565C0),
                  ),
                ),
              ),
            ),
          );
        },
      ),

      title: Container(
        width: 120,
        height: 45,
        color: Colors.red,
        child: Image.asset(
          "assets/logos/digiAdmin.jpeg",
          fit: BoxFit.contain,
        ),
      ),

      centerTitle: true,

      actions: [
        IconButton(
          onPressed: () {
            controller.selectDate(context);
          },
          icon: const Icon(Icons.filter_list_outlined),
        ),
        IconButton(
          onPressed: () {
            Get.toNamed(Routes.SEARCH_FOLIO);
          },
          icon: const Icon(Icons.search_outlined),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}