import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/folios.empty.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/archivados.controller.dart';

class ArchivadosScreen extends GetView<ArchivadosController> {
  const ArchivadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF8FAFC),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0XFF64748B)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Color(0XFF64748B), height: 1.0),
        ),
        backgroundColor: const Color(0XFFF8FAFC),
        actions: [
          IconButton(
            onPressed: () {
              controller.getFoliosWithDate(controller.id.text);
            },
            icon: Icon(Icons.search, color: Color(0XFF64748B)),
          ),
        ],
        title: TextField(
          controller: controller.id,
          onSubmitted: (value) {
            controller.getFoliosWithDate(value);
          },
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar por ID de Folio...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Color(0XFF64748B)),
          ),
          style: const TextStyle(color: Color(0xff0F172A), fontSize: 18),
          keyboardType: TextInputType.number,
        ),
        centerTitle: true,
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
            await controller.getFoliosWithDate(controller.id.text);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Center(child: FoliosEmptyPage(needDate: false)),
            ),
          ),
        ),
        (state) {
          return RefreshIndicator(
            color: Colors.white,
            backgroundColor: const Color(0XFF1D6CFF),
            onRefresh: () => controller.getFoliosWithDate(controller.id.text),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.archive_outlined,
                            color: Color(0XFF64748B),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Archivados",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0XFF334155),
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
                    direction: DismissDirection.horizontal,
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        return await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Dialog(
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
                                        backgroundColor: Color(0xFFE8F5E9),
                                        child: Icon(
                                          Icons.settings_backup_restore_rounded,
                                          size: 40,
                                          color: Color(0xFF319F43),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Restaurar Folio',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        '¿Estás seguro de restaurar este folio?',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                              backgroundColor: const Color(
                                                0xFF319F43,
                                              ),
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Restaurar'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ) ??
                            false;
                      }

                      if (direction == DismissDirection.endToStart) {
                        return await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Dialog(
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
                                      const Text(
                                        '¿Estás seguro de eliminar este folio?',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                              controller.eliminarFolio(
                                                folio.folioId ?? "",
                                              );
                                              Navigator.pop(context, true);
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
                              ),
                            ) ??
                            false;
                      }

                      return true;
                    },
                    background: Container(
                      color: const Color(0xFF10B981),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.settings_backup_restore_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Restaurar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    secondaryBackground: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Eliminar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 28,
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
