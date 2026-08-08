import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/models/historial_folios.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/detallesFolio.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/getHistorialFolio.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/update.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

class DetallesFolioController extends GetxController with StateMixin<Folios> {
  //TODO: Implement DetallesFolioController
  RxInt currentStep = 0.obs;
  RxInt statusId = 0.obs;
  int? nextStatus;
  var historialList = <Folios>[].obs;
  var historialListWeb = <HistorialEstado>[].obs;

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

  Future<void> onInitDetalles({String? customId}) async {
    final String idBuscado =
        Get.arguments?.toString() ?? customId!;

    if (idBuscado.isEmpty) {
      print("Aviso: No se recibió ningún ID para cargar los detalles.");
      change(null, status: RxStatus.empty());
      return;
    }
    print("FolioId: $idBuscado");

    await getDetailsFolio(idBuscado);
  }

  @override
  void onReady() {
    super.onReady();
  }

  Future<void> getDetailsFolio(String idBuscado) async {
    change(null, status: RxStatus.loading());
    try {
      Map<String, dynamic>? dataMap;

      if (kIsWeb) {
        final response = await Supabase.instance.client
            .from(
              'vista_folios_completos',
            ) // O la vista/tabla que uses para buscar
            .select()
            .or('id.eq.$idBuscado,folioId.eq.$idBuscado')
            .limit(1)
            .maybeSingle();

        if (response == null) {
          change(null, status: RxStatus.empty());
          return;
        }
        dataMap = Map<String, dynamic>.from(response);
      } else {
        final List<dynamic> resultSet = await AppDatabase.db.execute(
          folioId(),
          [idBuscado],
        );

        if (resultSet.isEmpty) {
          change(null, status: RxStatus.empty());
          return;
        }
        dataMap = Map<String, dynamic>.from(resultSet.first);
      }

      final folio = Folios.fromJson(dataMap);

      final ultimoRegistro = await getUltimoStatus(
        folio.folioIdHistorial ?? folio.id ?? "",
      );

      if (ultimoRegistro != null) {
        statusId.value = ultimoRegistro["statusId"] as int;
        currentStep.value = getStepIndex(statusId.value);
        print("actual actualizado a: ${currentStep.value}");
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

  Future<void> historialFolio(String folioId) async {
    try {
      historialList.clear();
      List<HistorialEstado> listaProcesada = [];
      List<dynamic> resultSet = [];
      if (kIsWeb) {
        final resultSet = await Supabase.instance.client
            .from('historialestados')
            .select('*, status:statusId(nombre, color)')
            .eq('folioId', folioId)
            .order('created_at', ascending: false);

        listaProcesada = (resultSet as List).map((element) {
          return HistorialEstado.fromJson(Map<String, dynamic>.from(element));
        }).toList();
        historialListWeb.assignAll(listaProcesada);
      } else {
        resultSet = await AppDatabase.db.getAll(getHistorialFolio(), [folioId]);
        List<Folios> folio = resultSet.map((element) {
          final Map<String, dynamic> mapData = Map<String, dynamic>.from(
            element as Map,
          );
          return Folios.fromJson(mapData);
        }).toList();
        historialList.value = folio;
      }

      update();
    } catch (e) {
      print("Error en historialFolio: $e");
    }
  }

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

      // Pendiente
      case 4:
        return 0;

      // Sitio
      case 5:
        return 2;

      default:
        return 0;
    }
  }

  Widget statusFolio(int statusId) {
    switch (statusId) {
      case 1 || 4:
        return Text(
          'Empezar ruta',
          textScaleFactor: 1.3,
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case 2:
        return Text(
          'Llegada',
          textScaleFactor: 1.3,
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case 5:
        return Text(
          'Finalizar entrega',
          textScaleFactor: 1.3,
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      default:
        return SizedBox.shrink();
    }
  }

  Future<int?> changeStatus(String statusId, String folioId) async {
    int? nextStatus;

    if (folioId.isEmpty) {
      print("Error: folioId vacío en changeStatus");
      return null;
    }

    switch (statusId) {
      case "1" || "4":
        nextStatus = 2;
        break;
      case "2":
        nextStatus = 5;
        break;
      case "5":
        nextStatus = 3;
        break;
      default:
        return null;
    }

    // Se ejecuta la inserción una sola vez
    await AppDatabase.db.execute(insertStatusFolio(), [
      const Uuid().v4(),
      folioId,
      nextStatus.toString(),
      DateTime.now().toIso8601String(),
    ]);

    return nextStatus;
  }

  Future<void> pedidoPendiente(String folioId) async {
    await AppDatabase.db.execute(insertStatusFolio(), [
      const Uuid().v4(),
      folioId,
      4,
      DateTime.now().toIso8601String(),
    ]);
  }

  Future<void> llamarTelefonoSoporteTecnico() async {
    final Uri uri = Uri.parse('tel:8110294162');

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );

      if (!launched) {
        print('No existe aplicación para llamadas');
      }
    } catch (e) {
      print('Error llamada: $e');
    }
  }

  Future<void> archivarFolio(String folioId) async {
    try {
      await AppDatabase.db.execute(
        '''
        UPDATE folios 
        SET "isArchived" = true 
        WHERE "folioId" = ?;
        ''',
        [folioId],
      );
      await onInitDetalles();
      return null;
    } catch (e) {
      print("Error al archivar folio: $e");
      return null;
    }
  }

  Future<void> restaurarFolio(String folioId) async {
    try {
      await AppDatabase.db.execute(
        '''
        UPDATE folios 
        SET "isArchived" = false 
        WHERE "folioId" = ?;
        ''',
        [folioId],
      );
      await onInitDetalles();
      return null;
    } catch (e) {
      print("Error al archivar folio: $e");
      return null;
    }
  }

  Future<void> eliminarFolio(String folioId) async {
    try {
      await AppDatabase.db.execute("DELETE FROM folios WHERE folioId = ?", [
        folioId,
      ]);
      Get.toNamed(Routes.FOLIOS);
    } catch (e) {
      print("Error de SQL: ${e.toString()}");
      return null;
    }
  }
}
