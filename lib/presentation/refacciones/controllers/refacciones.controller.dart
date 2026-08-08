import 'package:bitacora_frontend/infrastructure/models/refacciones.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/folios/querys/datosPersonales.query.dart';
import 'package:bitacora_frontend/presentation/refacciones/queries/refacciones.dart';
import 'package:flutter/foundation.dart';
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

    if (kIsWeb) {
      final response = await Supabase.instance.client
          .from('datosPersonales')
          .select('rolId')
          .eq('userId', miId ?? '')
          .maybeSingle();

      if (response != null && response['rolId'] != null) {
        rolUsuario.value = response['rolId'] as int;
      }
    } else {
      final dynamic resultSet = await AppDatabase.db.execute(
        datosPersonalesQuery(),
        [miId],
      );

      if (resultSet.isNotEmpty) {
        rolUsuario.value = resultSet.first['rolId'] as int;
      }
    }

    await getRefacciones();
  }

  Future<Map<String, dynamic>?> getDatos() async {
    change(null, status: RxStatus.loading());
    try {
      final miId = Supabase.instance.client.auth.currentUser?.id;
      Map<String, dynamic>? resultado;

      if (!kIsWeb) {
        final status = AppDatabase.db.currentStatus;
        if (status.hasSynced != true) {
          await AppDatabase.db.statusStream.firstWhere(
            (s) => s.hasSynced == true,
          );
        }

        resultado = await AppDatabase.db.getOptional(
          '''
          SELECT dp.*, r."name" as "nombre_rol" 
          FROM "datosPersonales" dp
          INNER JOIN "roles" r ON dp."rolId" = r."id"
          WHERE dp."userId" = ?
          ''',
          [miId],
        );
      } else {
        final response = await Supabase.instance.client
            .from('datosPersonales')
            .select('*')
            .eq('userId', miId!)
            .maybeSingle();

        if (response != null) {
          resultado = Map<String, dynamic>.from(response);
          int rolIdVal = response['rolId'] ?? 0;
          resultado['nombre_rol'] = (rolIdVal == 1) ? "Admin" : "Usuario";
        }
      }
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
    return null;
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
      List<dynamic> resultSet = [];

      if (kIsWeb) {
        final response = await Supabase.instance.client
            .from('tipos')
            .select()
            .ilike('nombre', '%${nombreController.text}%')
            .not('id', 'in', '(1, 2)');

        resultSet = response;
      } else {
        resultSet = await AppDatabase.db.execute(
          listRefacciones(nombreController.text),
        );
      }

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
      print("Error al eliminar refacción: ${e.toString()}");
      return;
    }
  }

  void increment() => count.value++;
}
