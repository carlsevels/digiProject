import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/detallesFolio.dart';
import 'package:confetti/confetti.dart';
import 'package:get/get.dart';
import 'package:powersync/sqlite3.dart';

class SuccessController extends GetxController with StateMixin<Folios> {
  late ConfettiController confettiController;
  RxInt statusId = 0.obs;
  @override
  void onInit() async {
    super.onInit();
    change(null, status: RxStatus.loading());

    confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    final String? id = Get.arguments?.toString();
    await getDetailsFolio(id ?? "");
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
      } else {
        print(
          "ADVERTENCIA: No se encontró ningún registro en historialestados para el folioId: ${folio.folioId}",
        );
      }

      print("Folio: ${jsonEncode(folio)}");
      change(folio, status: RxStatus.success());
      Future.delayed(const Duration(milliseconds: 300), () {
        if (confettiController.state != ConfettiControllerState.playing) {
          confettiController.play();
        }
      });
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

  @override
  void onClose() {
    confettiController.dispose();
    super.onClose();
  }
}
