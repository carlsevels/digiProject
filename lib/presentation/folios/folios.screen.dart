import 'dart:ui';

import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/folios.empty.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/folios.controller.dart';

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
        backgroundColor: const Color(0XFFF8FAFC),
        title: SizedBox(
          width: 120,
          child: Image.network(
            fit: BoxFit.contain,
            "https://lirp.cdn-website.com/d83902d6/dms3rep/multi/opt/logotipo-157w.png",
          ),
        ),
        automaticallyImplyActions: false,
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.account_circle_outlined),
            );
          },
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
      drawer: Obx(
        () => Drawer(
          backgroundColor: const Color(0XFFF8FAFC),
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
                        child: Text(
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

              // ListTile(
              //   leading: const Icon(Icons.account_circle_outlined),
              //   title: const Text("Perfil"),
              //   onTap: () => Get.toNamed(Routes.PROFILE),
              // ),
              if (controller.rolName.value == "Admin")
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text("Repartidores"),
                  onTap: null,
                ),
              if (controller.rolName.value == "Admin")
                ExpansionTile(
                  title: Text("Refacciones"),
                  leading: const Icon(Icons.precision_manufacturing_outlined),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.format_list_numbered_sharp),
                      title: const Text("Refacciones"),
                      onTap: () {
                        Get.toNamed(Routes.REFACCIONES);
                      },
                    ),
                  ],
                ),
              if (controller.rolName.value == "Admin")
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
              if (controller.rolName.value == "Admin")
                ExpansionTile(
                  leading: const Icon(Icons.business_center_outlined),
                  title: const Text("Clientes"),
                  children: [
                    ListTile(
                      leading: Icon(Icons.format_list_numbered_outlined),
                      title: const Text("Clientes"),
                      onTap: () => Get.toNamed(Routes.CLIENTES),
                    ),
                    ListTile(
                      leading: Icon(Icons.person_add_alt_1_outlined),
                      title: const Text("Agregar Cliente"),
                      onTap: () => Get.toNamed(Routes.ADD_CLIENTE),
                    ),
                  ],
                ),
              if (controller.rolName.value == "Admin") const Divider(height: 1),
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
      body: controller.obx(
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
                      "assets/logos/digirey.png",
                      opacity: const AlwaysStoppedAnimation(.5),
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
          return RefreshIndicator(
            color: Colors.white,
            backgroundColor: const Color(0XFF1D6CFF),
            onRefresh: () => controller.getFoliosWithDate(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: state!.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                          if (controller.rolUsuario.value == 1)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                minimumSize: const Size(50, 30),
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Get.toNamed(Routes.ADD_FOLIOS);
                              },
                              icon: const Icon(
                                Icons.add,
                                color: Color(0XFF1D6CFF),
                              ),
                              label: const Text(
                                "Agregar Folio",
                                style: TextStyle(color: Color(0XFF1D6CFF)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                final folio = state[index - 1];
                return InkWell(
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
                        // Resultado de la confirmación
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
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
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
                                          onPressed: () => Navigator.pop(
                                            context,
                                            false,
                                          ), // Retorna false (no eliminar)
                                          child: const Text(
                                            'Cancelar',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            controller.eliminarFolio(
                                              folio.folioId ?? "",
                                            );
                                            Navigator.pop(
                                              context,
                                              true,
                                            ); // Retorna true (sí eliminar)
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFD9534F,
                                            ),
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
                          Icon(
                            Icons.archive_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
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
                          Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                    child: ListTile(
                      isThreeLine: false,
                      contentPadding: EdgeInsets.zero,
                      leading: Column(
                        children: [
                          Text(
                            folio.cantidad.toString(),
                            textScaleFactor: 3.5,
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
                      title: Text(folio.nombreComercial.toString()),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Color(0XFF64748B),
                                ),
                                Flexible(
                                  child: Text(
                                    "${folio.municipio} - ${folio.condicionPago} - ${folio.folioId.toString()}",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0XFF64748B),
                                    ),
                                  ),
                                ),
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
                                  ? Color(
                                      int.parse(folio.statusColor.toString()),
                                    )
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Color(
                                  int.parse(folio.statusColor.toString()),
                                ),
                              ),
                            ),
                            child: Text(
                              folio.status.toString(),
                              style: TextStyle(
                                color: folio.status == "Por entregar"
                                    ? Color(
                                        int.parse(folio.statusColor.toString()),
                                      )
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
