import 'package:bitacora_frontend/infrastructure/layout/layoutInterno.controller.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LayoutInterno extends StatelessWidget {
  final Widget? child;
  const LayoutInterno({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final LayoutInternoController controller = Get.put(
      LayoutInternoController(),
    );

    final bool isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return Navigator(
        key: Get.nestedKey(1),
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.black87),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xff1565C0),
                    child: Obx(
                      () => Text(
                        controller.nameUser.value.isNotEmpty &&
                                controller.nameUser.value != "Cargando..."
                            ? controller.nameUser.value[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                title: SizedBox(
                  height: 32,
                  child: Obx(
                    () => Image.asset(
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                      controller.rolUsuario.value == 1
                          ? "assets/logos/digiAdmin.jpeg"
                          : "assets/logos/digiRepartidores.jpeg",
                    ),
                  ),
                ),
                actions: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(
                          context,
                        ).openDrawer(); 
                      },
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1.0),
                  child: Container(color: Colors.grey.shade200, height: 1.0),
                ),
              ),
              drawer: Drawer(
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(right: Radius.zero),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff2196F3), Color(0xff1565C0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Obx(
                              () => Text(
                                controller.nameUser.value.isNotEmpty &&
                                        controller.nameUser.value !=
                                            "Cargando..."
                                    ? controller.nameUser.value[0].toUpperCase()
                                    : "?",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff1565C0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(
                            () => Text(
                              controller.nameUser.value,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.badge_outlined,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Obx(
                                () => Text(
                                  controller.rolName.value,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.receipt_long_outlined,
                              color: Color(0xff1565C0),
                            ),
                            title: const Text(
                              'Folios',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              controller.cambiarRuta(Routes.FOLIOS, 0);
                            },
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.account_tree_outlined,
                              color: Color(0xff1565C0),
                            ),
                            title: const Text(
                              'Organigrama',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              controller.cambiarRuta(Routes.ORGANIGRAMA, 1);
                            },
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.precision_manufacturing_outlined,
                              color: Color(0xff1565C0),
                            ),
                            title: const Text(
                              'Refacciones',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              controller.cambiarRuta(Routes.REFACCIONES, 2);
                            },
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.archive_outlined,
                              color: Color(0xff1565C0),
                            ),
                            title: const Text(
                              'Archivados',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              controller.cambiarRuta(Routes.ARCHIVADOS, 3);
                            },
                          ),
                          if (controller.rolName.value == "Admin")
                            ListTile(
                              leading: const Icon(
                                Icons.business_center_outlined,
                                color: Color(0xff1565C0),
                              ),
                              title: const Text(
                                'Clientes',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              onTap: () => {
                                Navigator.of(context).pop(),
                                controller.cambiarRuta(Routes.CLIENTES, 4),
                              },
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        controller.signOutAllDevices();
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              body: child ?? const SizedBox.shrink(),
            ),
          );
        },
      );
    }

    // SI ES ESCRITORIO (Desktop): Mantiene exactamente tu diseño web con barra lateral colapsable
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          GetBuilder<LayoutInternoController>(
            builder: (_) {
              Get.currentRoute;

              return Obx(
                () => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: controller.isWebMenuVisible.value ? 260 : 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: _buildSidebarContent(controller),
                ),
              );
            },
          ),
          Expanded(child: child ?? const SizedBox.shrink()),
        ],
      ),
    );
  }

  // Contenido exclusivo para Escritorio
  Widget _buildSidebarContent(LayoutInternoController controller) {
    return Column(
      children: [
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  controller.isWebMenuVisible.value
                      ? Icons.menu_open
                      : Icons.menu,
                ),
                onPressed: () {
                  controller.isWebMenuVisible.value =
                      !controller.isWebMenuVisible.value;
                },
              ),
              if (controller.isWebMenuVisible.value) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 35,
                    child: Obx(
                      () => Image.asset(
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
                        controller.rolUsuario.value == 1
                            ? "assets/logos/digiAdmin.jpeg"
                            : "assets/logos/digiRepartidores.jpeg",
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        Obx(
          () => Padding(
            padding: EdgeInsets.all(
              controller.isWebMenuVisible.value ? 16.0 : 12.0,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xff1565C0),
                  child: Obx(
                    () => Text(
                      controller.nameUser.value.isNotEmpty &&
                              controller.nameUser.value != "Cargando..."
                          ? controller.nameUser.value[0].toUpperCase()
                          : "?",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (controller.isWebMenuVisible.value) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.nameUser.value,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Obx(
                          () => Text(
                            controller.rolName.value,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildNavItem(
                    controller: controller,
                    icon: Icons.receipt_long_outlined,
                    selectedIcon: Icons.receipt_long,
                    label: 'Folios',
                    index: 0,
                    route: Routes.FOLIOS,
                    isExpanded: controller.isWebMenuVisible.value,
                  ),
                  _buildNavItem(
                    controller: controller,
                    icon: Icons.account_tree_outlined,
                    selectedIcon: Icons.account_tree,
                    label: 'Organigrama',
                    index: 1,
                    route: Routes.ORGANIGRAMA,
                    isExpanded: controller.isWebMenuVisible.value,
                  ),
                  _buildNavItem(
                    controller: controller,
                    icon: Icons.precision_manufacturing_outlined,
                    selectedIcon: Icons.precision_manufacturing,
                    label: 'Refacciones',
                    index: 2,
                    route: Routes.REFACCIONES,
                    isExpanded: controller.isWebMenuVisible.value,
                  ),
                  _buildNavItem(
                    controller: controller,
                    icon: Icons.archive_outlined,
                    selectedIcon: Icons.archive,
                    label: 'Archivados',
                    index: 3,
                    route: Routes.ARCHIVADOS,
                    isExpanded: controller.isWebMenuVisible.value,
                  ),
                  if (controller.rolName.value == "Admin")
                    _buildNavItem(
                      controller: controller,
                      icon: Icons.business_center_outlined,
                      selectedIcon: Icons.business_center,
                      label: 'Clientes',
                      index: 4,
                      route: Routes.CLIENTES,
                      isExpanded: controller.isWebMenuVisible.value,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required String route,
    required bool isExpanded,
    required LayoutInternoController controller,
  }) {
    final currentRoute = Get.currentRoute;
    bool isSelected =
        currentRoute == route || (route != '/' && currentRoute.contains(route));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: isSelected
              ? const Color(0xff1565C0).withOpacity(0.1)
              : Colors.transparent,
          leading: Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected ? const Color(0xff1565C0) : Colors.grey.shade700,
            size: 22,
          ),
          title: isExpanded
              ? Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xff1565C0)
                        : Colors.grey.shade800,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                )
              : null,
          minLeadingWidth: 0,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 16 : 14,
            vertical: 0,
          ),
          onTap: () {
            controller.cambiarRuta(route, index);
          },
        ),
      ),
    );
  }
}
