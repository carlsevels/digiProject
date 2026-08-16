import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/detallesFolio.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      Folios? folio;

      if (kIsWeb) {
        final response = await Supabase.instance.client
            .from('folios')
            .select()
            .eq('folioId', idBuscado)
            .maybeSingle();

        if (response == null) {
          change(null, status: RxStatus.empty());
          return;
        }
        folio = Folios.fromJson(Map<String, dynamic>.from(response));
      } else {
        final resultSet = await AppDatabase.db.execute(folioId(), [
          idBuscado,
        ]);
        if (resultSet.isEmpty) {
          change(null, status: RxStatus.empty());
          return;
        }
        folio = Folios.fromJson(resultSet.first);
      }

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
      if (kIsWeb) {
        final response = await Supabase.instance.client
            .from('historialestados')
            .select()
            .eq('folioId', folioId)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        return response != null ? Map<String, dynamic>.from(response) : null;
      } else {
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
      }
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