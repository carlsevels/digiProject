import 'package:bitacora_frontend/infrastructure/models/refacciones.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/folios/querys/datosPersonales.query.dart';
import 'package:bitacora_frontend/presentation/refacciones/queries/refacciones.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RefaccionesController extends GetxController
    with StateMixin<List<GeneralModel>> {
  final TextEditingController nombreController = TextEditingController();
  RxInt rolUsuario = 0.obs;
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _onInit();
  }

  Future<void> _onInit() async {
    final miId = Supabase.instance.client.auth.currentUser?.id;
    if (miId == null) {
      change(null, status: RxStatus.error("Usuario no autenticado"));
      return;
    }

    if (kIsWeb) {
      final response = await Supabase.instance.client
          .from('datosPersonales')
          .select('rolId')
          .eq('userId', miId)
          .maybeSingle();

      if (response == null) {
        change(null, status: RxStatus.empty());
        return;
      }
      rolUsuario.value = response['rolId'] as int;
    } else {
      final resultSet = await AppDatabase.db.execute(
        datosPersonalesQuery(),
        [miId],
      );

      if (resultSet.isEmpty) {
        change(null, status: RxStatus.empty());
        return;
      }

      rolUsuario.value = resultSet.first['rolId'] as int;
    }

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
      List<GeneralModel> listFolios = [];
      final searchText = nombreController.text;

      if (kIsWeb) {
        var query = Supabase.instance.client.from('tipos').select();

        if (searchText.isNotEmpty) {
          query = query.ilike('nombre', '%$searchText%');
        }

        final response = await query;
        listFolios = (response as List)
            .map(
              (element) => GeneralModel.fromJson(
                Map<String, dynamic>.from(element as Map),
              ),
            )
            .toList();
      } else {
        final resultSet = await AppDatabase.db.execute(
          listRefacciones(searchText),
        );

        listFolios = resultSet
            .map(
              (element) => GeneralModel.fromJson(
                Map<String, dynamic>.from(element as Map),
              ),
            )
            .toList();
      }

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
      if (kIsWeb) {
        await Supabase.instance.client
            .from('tipos')
            .delete()
            .eq('id', refaccionId);
      } else {
        await AppDatabase.db.execute("DELETE FROM tipos WHERE id = ?", [
          refaccionId,
        ]);
      }
      await getRefacciones();
    } catch (e) {
      print("Error de SQL: ${e.toString()}");
      return null;
    }
  }

  void increment() => count.value++;
}