import 'dart:ui';

import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/direccionDialog.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/empty_folio_web.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/folios.empty.dart';
import 'package:bitacora_frontend/presentation/folios/responsive/movil.dart';
import 'package:bitacora_frontend/presentation/folios/responsive/web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/folios.controller.dart';
import 'package:url_launcher/url_launcher.dart';

class FoliosScreen extends StatefulWidget {
  const FoliosScreen({super.key});

  @override
  State<FoliosScreen> createState() => _FoliosScreenState();
}

class _FoliosScreenState extends State<FoliosScreen> {
  // Estado para controlar si el menú web está visible u oculto
  bool _isWebMenuVisible = true;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FoliosController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    final Widget mainBody = controller.obx(
      onLoading: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: SizedBox(
                  width: 120,
                  child: Image.asset(
                    fit: BoxFit.contain,
                    "assets/logos/digiApp.jpeg",
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
      onError: (error) => Center(child: Text("Error: $error")),
      onEmpty: RefreshIndicator(
        color: Colors.white,
        backgroundColor: const Color(0XFF1D6CFF),
        onRefresh: () async {
          await controller.getFoliosWithDate();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: Get.size.height,
            child: Center(
              child: kIsWeb
                  ? WebFoliosEmptyPage(needDate: true)
                  : FoliosEmptyPage(needDate: true),
            ),
          ),
        ),
      ),
      (state) {
        if (kIsWeb) {
          return WebFolioView(state: state!);
        } else {
          return MovilFolioView(state: state!);
        }
      },
    );

    if (kIsWeb) {
      return Scaffold(
        backgroundColor: const Color(0XFFF8FAFC),
        body: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: _isWebMenuVisible ? 280 : 0,
              child: _isWebMenuVisible
                  ? Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Obx(
                                      () => CircleAvatar(
                                        radius: 26,
                                        backgroundColor: Colors.white,
                                        child: Text(
                                          controller
                                                      .nameUser
                                                      .value
                                                      .isNotEmpty &&
                                                  controller.nameUser.value !=
                                                      "Cargando..."
                                              ? controller.nameUser.value[0]
                                                    .toUpperCase()
                                              : "?",
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff1565C0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Obx(
                                  () => Text(
                                    controller.nameUser.value,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
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
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        controller.rolName.value,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Elementos de navegación con Acordeón (ExpansionTile)
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                ExpansionTile(
                                  title: const Text("Refacciones"),
                                  leading: const Icon(
                                    Icons.precision_manufacturing_outlined,
                                  ),
                                  children: [
                                    ListTile(
                                      leading: const Icon(
                                        Icons.format_list_numbered_outlined,
                                      ),
                                      title: const Text("Refacciones"),
                                      onTap: () {
                                        Get.toNamed(Routes.REFACCIONES);
                                      },
                                    ),
                                  ],
                                ),
                                ExpansionTile(
                                  leading: const Icon(
                                    Icons.receipt_long_outlined,
                                  ),
                                  title: const Text("Folios"),
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.add),
                                      title: const Text("Agregar"),
                                      onTap: () =>
                                          Get.toNamed(Routes.ADD_FOLIOS),
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.archive_outlined,
                                      ),
                                      title: const Text("Archivados"),
                                      onTap: () =>
                                          Get.toNamed(Routes.ARCHIVADOS),
                                    ),
                                  ],
                                ),
                                Obx(() {
                                  if (controller.rolName.value == "Admin") {
                                    return Column(
                                      children: [
                                        ExpansionTile(
                                          leading: const Icon(
                                            Icons.business_center_outlined,
                                          ),
                                          title: const Text("Clientes"),
                                          children: [
                                            ListTile(
                                              leading: const Icon(
                                                Icons
                                                    .format_list_numbered_outlined,
                                              ),
                                              title: const Text("Clientes"),
                                              onTap: () =>
                                                  Get.toNamed(Routes.CLIENTES),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 1),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                              ],
                            ),
                          ),
                          // Botón de cerrar sesión en la parte inferior del panel
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              leading: const Icon(
                                Icons.logout_rounded,
                                color: Colors.red,
                              ),
                              title: const Text(
                                "Cerrar sesión",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: controller.signOut,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            if (_isWebMenuVisible)
              const VerticalDivider(
                thickness: 1,
                width: 1,
                color: Color(0xFFE2E8F0),
              ),

            Expanded(
              child: Scaffold(
                backgroundColor: const Color(0XFFF8FAFC),
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  scrolledUnderElevation: 0.0,
                  automaticallyImplyLeading: false,
                  leadingWidth: 120,
                  leading: Row(
                    children: [
                      IconButton(
                        tooltip: _isWebMenuVisible
                            ? "Ocultar menú"
                            : "Mostrar menú",
                        icon: Icon(
                          _isWebMenuVisible ? Icons.menu_open : Icons.menu,
                        ),
                        onPressed: () {
                          setState(() {
                            _isWebMenuVisible = !_isWebMenuVisible;
                          });
                        },
                      ),
                      SizedBox(
                        width: 80,
                        child: Obx(
                          () => Image.asset(
                            fit: BoxFit.contain,
                            controller.rolUsuario.value == 1
                                ? "assets/logos/digiAdmin.jpeg"
                                : "assets/logos/digiRepartidores.jpeg",
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      tooltip: "Filtrar por fecha",
                      onPressed: () {
                        controller.selectDate(context);
                      },
                      icon: const Icon(Icons.filter_list_outlined),
                    ),
                    IconButton(
                      tooltip: "Buscar folio",
                      onPressed: () {
                        Get.toNamed(Routes.SEARCH_FOLIO);
                      },
                      icon: const Icon(Icons.search_outlined),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                body: mainBody,
              ),
            ),
          ],
        ),
      );
    }

    // --- DISEÑO MÓVIL ORIGINAL CON DRAWER ---
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0XFFF8FAFC),
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: SizedBox(
          width: 120,
          child: Obx(
            () => Image.asset(
              fit: BoxFit.contain,
              controller.rolUsuario.value == 1
                  ? "assets/logos/digiAdmin.jpeg"
                  : "assets/logos/digiRepartidores.jpeg",
            ),
          ),
        ),
        automaticallyImplyActions: false,
        leading: Builder(
          builder: (context) => InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Align(
              alignment: Alignment.center,
              child: Obx(
                () => Text(
                  controller.nameUser.value.isNotEmpty
                      ? controller.nameUser.value[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff1565C0),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
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
      ),
      drawer: Drawer(
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
                      Obx(
                        () => CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: Text(
                            controller.nameUser.value.isNotEmpty &&
                                    controller.nameUser.value != "Cargando..."
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
              Obx(() {
                if (controller.rolName.value == "Admin") {
                  return Column(
                    children: [
                      ExpansionTile(
                        leading: const Icon(Icons.business_center_outlined),
                        title: const Text("Clientes"),
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.format_list_numbered_outlined,
                            ),
                            title: const Text("Clientes"),
                            onTap: () => Get.toNamed(Routes.CLIENTES),
                          ),
                        ],
                      ),
                      const Divider(height: 1),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
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
      ),
      body: mainBody,
    );
  }
}
