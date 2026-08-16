import 'dart:ui';

import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/direccionDialog.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/folios.empty.dart';
import 'package:bitacora_frontend/presentation/folios/resposivo/folios.movil.dart';
import 'package:bitacora_frontend/presentation/folios/resposivo/folios.web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/folios.controller.dart';
import 'package:url_launcher/url_launcher.dart';

class FoliosScreen extends GetView<FoliosController> {
  const FoliosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
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
  child: LayoutBuilder(
    builder: (context, constraints) {
      final bool isWeb = constraints.maxWidth > 800;
      final bool isAdmin = controller.rolName.value == "Admin";

      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 220,
              width: constraints.maxWidth,
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

            // EL MENÚ INTERMEDIO SOLO SE MUESTRA SI NO ES WEB Y SÍ ES ADMIN
            if (!isWeb && isAdmin) ...[
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
              ExpansionTile(
                leading: const Icon(Icons.business_center_outlined),
                title: const Text("Clientes"),
                children: [
                  ListTile(
                    leading: const Icon(Icons.format_list_numbered_outlined),
                    title: const Text("Clientes"),
                    onTap: () => Get.toNamed(Routes.CLIENTES),
                  ),
                ],
              ),
              const Divider(height: 1),
            ],

            // Espacio de separación si es web para que no quede pegado el botón al header
            if (isWeb) const SizedBox(height: 24),

            // BOTÓN DE CERRAR SESIÓN (VISIBLE SIEMPRE)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
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
            ),
          ],
        ),
      );
    },
  ),
), body: controller.obx(
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
              child: Center(child: FoliosEmptyPage(needDate: true)),
            ),
          ),
        ),
        (state) {
          if (kIsWeb) {
            return FolioWebView(state: state!);
          } else {
            return FoliosMovilView(state: state!);
          }
        },
      ),
    );
  }
}

class DatePickerExample extends StatefulWidget {
  const DatePickerExample({super.key});
  @override
  State<DatePickerExample> createState() => _DatePickerExampleState();
}

class _DatePickerExampleState extends State<DatePickerExample> {
  DateTime? selectedDate;
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2021, 7, 25),
      firstDate: DateTime(2021),
      lastDate: DateTime(2022),
    );
    setState(() {
      selectedDate = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(onPressed: _selectDate, icon: const Icon(Icons.filter_list)),
      ],
    );
  }
}
