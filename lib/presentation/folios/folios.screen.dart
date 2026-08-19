import 'dart:ui';

import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/direccionDialog.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/easy_date_timeline.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/folios.empty.dart';
import 'package:bitacora_frontend/presentation/folios/resposivo/folios.movil.dart';
import 'package:bitacora_frontend/presentation/folios/resposivo/folios.web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/folios.controller.dart';

class FoliosScreen extends GetView<FoliosController> {
  const FoliosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
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
            onPressed: () async {
              await controller.syncPendingData();
              ();
            },
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => controller.selectDate(context),
            icon: const Icon(Icons.filter_list_outlined),
          ),
          IconButton(
            onPressed: () => Get.toNamed(Routes.SEARCH_FOLIO),
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
                      leading: const Icon(
                        Icons.precision_manufacturing_outlined,
                      ),
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
                      leading: const Icon(Icons.receipt_long_outlined),
                      title: const Text("Folios"),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.add),
                          title: const Text("Agregar"),
                          onTap: () => Get.offAndToNamed(Routes.ADD_FOLIOS),
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

                  // Espacio de separación si es web para que no quede pegado el botón al header
                  if (isWeb) const SizedBox(height: 24),

                  // BOTÓN DE CERRAR SESIÓN (VISIBLE SIEMPRE)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
            );
          },
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
                child: Column(
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
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                              ),
                            ),
                            onPressed: () {
                              print(
                                'Fecha seleccionada: ${controller.fechaSeleccionada.value}',
                              );

                              Get.offAndToNamed(
                                Routes.ADD_FOLIOS,
                                arguments: {
                                  'fecha': controller.fechaSeleccionada.value,
                                },
                              );
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
                    ),
                    const SizedBox(height: 16),
                    EasyDateTimelinePage(),
                    const SizedBox(height: 32),
                    FoliosEmptyPage(needDate: true),
                  ],
                ),
              ),
            ),
          ),
        ),
        (state) {
          return RefreshIndicator(
            color: Colors.white,
            backgroundColor: const Color(0XFF1D6CFF),
            onRefresh: () async => await controller.getFoliosWithDate(),
            child: ReorderableListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              cacheExtent: 500,
              buildDefaultDragHandles: false,
              itemCount: controller.elementosAplanados.length + 2,

              proxyDecorator:
                  (Widget child, int index, Animation<double> animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (BuildContext context, Widget? child) {
                        final animValue = Curves.easeInOut.transform(
                          animation.value,
                        );
                        final elevation = lerpDouble(0, 12, animValue)!;
                        return Material(
                          elevation: elevation,
                          color: Colors.white,
                          shadowColor: Colors.black38,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0XFF1D6CFF).withOpacity(0.6),
                                width: 1.5,
                              ),
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: child,
                    );
                  },

              onReorder: (int oldIndex, int newIndex) {
                if (oldIndex == 0 ||
                    newIndex == 0 ||
                    oldIndex > controller.elementosAplanados.length ||
                    newIndex > controller.elementosAplanados.length) {
                  return;
                }

                int adjustedOld = oldIndex - 1;
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                int adjustedNew = newIndex - 1;
                adjustedNew = adjustedNew.clamp(
                  0,
                  controller.elementosAplanados.length - 1,
                );

                final elementos = controller.elementosAplanados;
                if (elementos[adjustedOld]['tipo'] != 'header') return;

                final String muniMovido = elementos[adjustedOld]['nombre'];
                String? muniDestino;

                // Búsqueda inteligente del municipio destino (hacia atrás o adelante)
                for (int i = adjustedNew; i >= 0; i--) {
                  if (elementos[i]['tipo'] == 'header') {
                    muniDestino = elementos[i]['nombre'];
                    break;
                  }
                }
                if (muniDestino == null) {
                  for (int i = adjustedNew; i < elementos.length; i++) {
                    if (elementos[i]['tipo'] == 'header') {
                      muniDestino = elementos[i]['nombre'];
                      break;
                    }
                  }
                }

                if (muniDestino != null && muniDestino != muniMovido) {
                  final int oldMunIdx = controller.ordenMunicipiosCustom
                      .indexOf(muniMovido);
                  final int newMunIdx = controller.ordenMunicipiosCustom
                      .indexOf(muniDestino);

                  if (oldMunIdx != -1 && newMunIdx != -1) {
                    controller.ordenMunicipiosCustom.removeAt(oldMunIdx);
                    controller.ordenMunicipiosCustom.insert(
                      newMunIdx,
                      muniMovido,
                    );

                    GetStorage().write(
                      'orden_municipios',
                      controller.ordenMunicipiosCustom.toList(),
                    );
                    if (state != null) {
                      controller.actualizarElementosAplanados(state);
                    }
                    controller.update();
                  }
                }
              },
              itemBuilder: (BuildContext context, int index) {
                // HEADER FIJO
                if (index == 0) {
                  return Column(
                    key: const ValueKey('header_fijo_fecha'),
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
                              onPressed: () {
                                print(
                                  'Fecha seleccionada: ${controller.fechaSeleccionada.value}',
                                );

                                Get.offAndToNamed(
                                  Routes.ADD_FOLIOS,
                                  arguments: {
                                    'fecha': controller.fechaSeleccionada.value,
                                  },
                                );
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
                      ),
                      const SizedBox(height: 16),
                      EasyDateTimelinePage(),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                // FOOTER
                if (index == controller.elementosAplanados.length + 1) {
                  return Container(
                    key: const ValueKey('footer_texto_final'),
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "No hay más folios por mostrar",
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final item = controller.elementosAplanados[index - 1];
                final uniqueKey = item['tipo'] == 'header'
                    ? ValueKey('mun_${item['nombre']}')
                    : ValueKey(
                        'folio_${item['data'].id ?? item['data'].folioId}',
                      );

                if (item['tipo'] == 'header') {
                  return ReorderableDelayedDragStartListener(
                    key: uniqueKey,
                    index: index,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 15,
                                color: Color(0XFF1D6CFF),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item['nombre'].toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0.8,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${item['count']})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.drag_handle_rounded,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // FOLIO ITEM
                final folio = item['data'];

                final String rawColor = folio.statusColor?.toString() ?? '';
                final String cleanedColor = rawColor
                    .toUpperCase()
                    .replaceAll('#', '')
                    .replaceAll('0X', '')
                    .trim();

                final int colorInt =
                    int.tryParse(cleanedColor, radix: 16) ?? 0xFF9E9E9E;

                final Color finalColor = Color(colorInt);

                return Container(
                  key: uniqueKey,
                  child: Dismissible(
                    key: ValueKey('dismiss_${folio.id ?? folio.folioId}'),
                    direction: DismissDirection.startToEnd,
                    confirmDismiss: (dir) async =>
                        await controller.mostrarDialogoArchivar(
                          context,
                          folio,
                          () => controller.archivarFolio(folio.folioId ?? ""),
                        ),
                    background: Container(
                      color: Colors.orange,
                      padding: const EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child: const Icon(
                        Icons.archive_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    child: InkWell(
                      onLongPress: () => direccionDialog(folio: folio),
                      onTap: () => Get.toNamed(
                        Routes.DETALLES_FOLIO,
                        arguments: folio.folioId.toString(),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 12.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Leading (Cantidad y tipo de refacción)
                            SizedBox(
                              width: 55,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    folio.cantidad.toString(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      height: 1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    folio.tiporefaccion.toString(),
                                    style: const TextStyle(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Contenido central
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // LÍNEA 1: Icono + Nombre Comercial (con ellipsis si es muy largo)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.business_center_outlined,
                                        size: 18,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          folio.nombreComercial ?? 'Sin nombre',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // LÍNEA 2: Municipio - Condición - FolioId Y EL CHIP DE ESTADO AL FINAL
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${folio.municipio ?? ''} - ${folio.condicionPago ?? ''} - ${folio.folioId ?? ''}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: finalColor,
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: Text(
                                          folio.status.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
