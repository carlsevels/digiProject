import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/detallesFolio.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/update.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:powersync/sqlite3.dart';
import 'package:uuid/uuid.dart';

class SearchFolioController extends GetxController with StateMixin<Folios> {
  //TODO: Implement SearchFolioController
  RxInt currentStep = 0.obs;
  RxInt statusId = 0.obs;
  TextEditingController id = TextEditingController();

  var isSearching = false.obs;
  var hasData = false.obs;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    change(null, status: RxStatus.empty());
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    id.dispose();
    super.onClose();
  }

  Future<void> onInitDetalles() async {
    if (id.text.isEmpty) {
      print("Error: El ID recibido es nulo o vacío");
      change(null, status: RxStatus.error("ID no válido"));
      return;
    }
    print("FolioId: $id");

    await getDetailsFolio(id.text);
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

      final ultimoRegistro = await getUltimoStatus(
        folio.folioIdHistorial ?? "",
      );

      if (ultimoRegistro != null) {
        statusId.value = ultimoRegistro["statusId"] as int;
        print("Status actual actualizado a: ${currentStep.value}");
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
        return result.first;
      }
      return null;
    } catch (e) {
      print("Error al obtener el último status: $e");
      return null;
    }
  }

  Color parseColor(String? colorStr, {Color defaultColor = Colors.grey}) {
    if (colorStr == null || colorStr.isEmpty) return defaultColor;

    String cleanColor = colorStr.toUpperCase().replaceAll('0X', '');

    int? colorInt = int.tryParse(cleanColor, radix: 16);

    return colorInt != null ? Color(colorInt | 0xFF000000) : defaultColor;
  }

  Future<void> pedidoPendiente(String folioId) async {
    await AppDatabase.db.execute(insertStatusFolio(), [
      const Uuid().v4(),
      folioId,
      4,
      DateTime.now().toIso8601String(),
    ]);
  }


  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      id.clear();
    }
  }

  void increment() => count.value++;
}
