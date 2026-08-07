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
                  child: Column(
                    children: [
                      // Cabecera: Botón hamburguesa y Logo
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

                      // Perfil del usuario compacto / expandido
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
                                            controller.nameUser.value !=
                                                "Cargando..."
                                        ? controller.nameUser.value[0]
                                              .toUpperCase()
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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

                      // Opciones de navegación limpias
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
                                    isExpanded:
                                        controller.isWebMenuVisible.value,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ), // Contenido principal
          Expanded(child: child ?? const SizedBox.shrink()),
        ],
      ),
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

    // Validación estricta y limpia para cualquier ruta
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
