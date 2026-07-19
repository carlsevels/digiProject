import 'package:bitacora_frontend/infrastructure/models/refacciones.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/refacciones/queries/refacciones.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:powersync/sqlite3.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RefaccionesController extends GetxController
    with StateMixin<List<GeneralModel>> {
  final TextEditingController nombreController = TextEditingController();

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _onInit();
  }

  Future<void> _onInit() async {
    await getRefacciones();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getRefacciones() async {
    change(null, status: RxStatus.loading());

    try {
      final ResultSet resultSet = await AppDatabase.db.execute(
        listRefacciones(nombreController.text),
      );

      if (resultSet.isEmpty) {
        change(null, status: RxStatus.empty());
        return;
      }

      List<GeneralModel> listFolios = resultSet
          .map(
            (element) => GeneralModel.fromJson(
              Map<String, dynamic>.from(element as Map),
            ),
          )
          .toList();
      if (listFolios.isEmpty) {
        change(listFolios, status: RxStatus.empty());
      } else {
        change(listFolios, status: RxStatus.success());
      }
    } catch (e) {
      print("Error al cargar refacciones: $e");
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<void> eliminarRefaccion(String refaccionId) async {
    try {
      await AppDatabase.db.execute("DELETE FROM tipos WHERE id = ?", [
        refaccionId,
      ]);
      await getRefacciones();
    } catch (e) {
      print("Error de SQL: ${e.toString()}");
      return null;
    }
  }

  void increment() => count.value++;
}
