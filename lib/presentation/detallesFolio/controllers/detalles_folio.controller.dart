import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/detallesFolio.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/update.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:powersync/sqlite3.dart';
import 'package:uuid/uuid.dart';

class DetallesFolioController extends GetxController with StateMixin<Folios> {
  //TODO: Implement DetallesFolioController
  RxInt currentStep = 0.obs;

  @override
  void onInit() {
    super.onInit();
    onInitDetalles();
  }

  @override
  void onClose() {
    print("Cerrando pantalla, limpiando recursos...");
    super.onClose();
  }

  Future<void> onInitDetalles() async {
    final String id = Get.arguments?.toString() ?? "";

    if (id.isEmpty) {
      print("Error: El ID recibido es nulo o vacío");
      change(null, status: RxStatus.error("ID no válido"));
      return;
    }
    print("FolioId: $id");
    await getDetailsFolio(id);
  }

  @override
  void onReady() {
    super.onReady();
  }

  Future<void> getDetailsFolio(String idBuscado) async {
    change(null, status: RxStatus.loading());
    try {
      final ResultSet resultSet = await AppDatabase.db.execute(folioId(), [
        idBuscado,
      ]);
      if (resultSet.isEmpty) {
        change(null, status: RxStatus.empty());
        return;
      }
      final folio = Folios.fromJson(resultSet.first);

      print("fOLIOS: ${jsonEncode(folio)}");

      final ultimoRegistro = await getUltimoStatus(
        folio.folioIdHistorial ?? "",
      );

      if (ultimoRegistro != null) {
        int statusId = ultimoRegistro["statusId"] as int;
        currentStep.value = getStepIndex(statusId);
        print("Status actual actualizado a: $statusId");
      } else {
        print(
          "ADVERTENCIA: No se encontró ningún registro en historialestados para el folioId: ${folio.folioId}",
        );
      }
      change(folio, status: RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<Map<String, dynamic>?> getUltimoStatus(String folioId) async {
    try {
      final List<Map<String, dynamic>> result = await AppDatabase.db.getAll(
        '''
      SELECT * FROM historialestados 
      WHERE "folioId" = ? 
      ORDER BY "created_at" DESC 
      LIMIT 1
      ''',
        [folioId],
      );

      if (result.isNotEmpty) {
        return result.first; // Este es el registro más reciente
      }
      return null; // No hay historial para este folio
    } catch (e) {
      print("Error al obtener el último status: $e");
      return null;
    }
  }

  Future<void> updateStatusId(int statusId, String folioId) async {
    try {
      await AppDatabase.db.execute(insertStatusFolio(), [
        const Uuid().v4(),
        folioId,
        statusId,
        DateTime.now().toIso8601String(),
      ]);

      print("Actualización completada exitosamente.");
    } catch (e) {
      print("Error crítico en updateStatusId: $e");
    }
  }

  // Función para parsear colores de forma segura
  Color parseColor(String? colorStr, {Color defaultColor = Colors.grey}) {
    if (colorStr == null || colorStr.isEmpty) return defaultColor;

    String cleanColor = colorStr.toUpperCase().replaceAll('0X', '');

    int? colorInt = int.tryParse(cleanColor, radix: 16);

    return colorInt != null ? Color(colorInt | 0xFF000000) : defaultColor;
  }

  int getStepIndex(int statusId) {
    switch (statusId) {
      // Por iniciar
      case 1:
        return 0;

      // Llegada
      case 2:
        return 1;

      // Entregado
      case 3:
        return 3;

      // Sitio
      case 5:
        return 2;

      default:
        return 0;
    }
  }
}
