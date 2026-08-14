import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/controllers/folios.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawerView extends GetView<FoliosController> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Drawer(
      backgroundColor: const Color(0XFFF8FAFC),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 220,
              width: screenWidth,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Obx(
                        () => Text(
                          controller.nameUser.value.isNotEmpty
                              ? controller.nameUser.value[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1565C0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => Text(
                        controller.nameUser.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Row(
                        children: [
                          const Icon(
                            Icons.badge_outlined,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            controller.rolName.value,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ExpansionTile(
              title: const Text("Organigrama"),
              leading: const Icon(Icons.precision_manufacturing_outlined),
              children: [
                ListTile(
                  leading: const Icon(Icons.account_tree_outlined),
                  title: const Text("Visitar"),
                  onTap: () {
                    Get.toNamed(Routes.ORGANIGRAMA);
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Refacciones"),
              leading: const Icon(Icons.precision_manufacturing_outlined),
              children: [
                ListTile(
                  leading: const Icon(Icons.format_list_numbered_outlined),
                  title: const Text("Refacciones"),
                  onTap: () {
                    Get.toNamed(Routes.REFACCIONES);
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text("Folios"),
              children: [
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text("Agregar"),
                  onTap: () => Get.toNamed(Routes.ADD_FOLIOS),
                ),
                ListTile(
                  leading: const Icon(Icons.archive_outlined),
                  title: const Text("Archivados"),
                  onTap: () => Get.toNamed(Routes.ARCHIVADOS),
                ),
              ],
            ),
            // Usamos un Obx específico solo para validar si el rol es Admin en el menú de clientes
            Obx(
              () => controller.rolName.value == "Admin"
                  ? ExpansionTile(
                      leading: const Icon(Icons.business_center_outlined),
                      title: const Text("Clientes"),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.format_list_numbered_outlined),
                          title: const Text("Clientes"),
                          onTap: () => Get.toNamed(Routes.CLIENTES),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            Obx(
              () => controller.rolName.value == "Admin"
                  ? const Divider(height: 1)
                  : const SizedBox.shrink(),
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text(
                "Cerrar sesión",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: controller.signOut,
            ),
          ],
        ),
      ),
    );
  }
}