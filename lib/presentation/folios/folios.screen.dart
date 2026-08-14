import 'dart:ui';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/direccionDialog.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/drawer.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/easy_date_timeline.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/onEmpty.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/onError.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/onLoading.dart';
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
            onPressed: () => controller.selectDate(context),
            icon: const Icon(Icons.filter_list_outlined),
          ),
          IconButton(
            onPressed: () => Get.toNamed(Routes.SEARCH_FOLIO),
            icon: const Icon(Icons.search_outlined),
          ),
        ],
      ),
      drawer: DrawerView(),
      body: controller.obx(
        onLoading: OnLoadingView(),
        onError: (error) => OnErrorView(error: error ?? ""),
        onEmpty: OnEmptyView(),
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
                              onPressed: () =>
                                  Get.offAndToNamed(Routes.ADD_FOLIOS),
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
                        arguments: {
                          'folioId': folio.folioId.toString(),
                          'id': folio.id ?? "",
                        },
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Column(
                          children: [
                            Text(
                              folio.cantidad.toString(),
                              style: const TextStyle(fontSize: 32, height: 1),
                            ),
                            Text(folio.tiporefaccion.toString()),
                          ],
                        ),
                        title: Row(
                          children: [
                            const Icon(
                              Icons.business_center_outlined,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                folio.nombreComercial ?? 'Sin nombre',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${folio.municipio ?? ''} - ${folio.folioId ?? ''}",
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Color(
                                  int.parse(folio.statusColor.toString()),
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                folio.status.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
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
