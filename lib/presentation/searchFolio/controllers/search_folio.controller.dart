import 'dart:convert';
import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/models/historial_folios.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/detallesFolio.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/getHistorialFolio.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/update.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SearchFolioController extends GetxController with StateMixin<Folios> {
  RxInt currentStep = 0.obs;
  RxInt statusId = 0.obs;
  TextEditingController id = TextEditingController();
  final RxList<HistorialEstado> historialList = <HistorialEstado>[].obs;
  List<HistorialEstado> folioList = [];
  List<Folios> folioListovil = [];
  Folios? folio;

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

  Future<void> historialFolio(String? idFolioUuid) async {
    print("ID recibido en controlador: $idFolioUuid");
    if (idFolioUuid == null || idFolioUuid.isEmpty) return;

    try {
      historialList.clear();
      folioList.clear();
      folioListovil.clear();

      update();

      if (kIsWeb) {
        final resultSet = await Supabase.instance.client
            .from('historialestados')
            .select('*')
            .eq('folioId', idFolioUuid)
            .order('created_at', ascending: true);

        final statusList = await Supabase.instance.client
            .from('status')
            .select('*');

        final Map<String, dynamic> statusMap = {
          for (var s in statusList) s['id'].toString().trim(): s,
        };

        final Set<String> idsProcesados = {};

        for (var element in resultSet) {
          final Map<String, dynamic> item = Map<String, dynamic>.from(element);

          final registroId = item['id']?.toString();
          if (registroId != null && idsProcesados.contains(registroId)) {
            continue;
          }
          if (registroId != null) {
            idsProcesados.add(registroId);
          }

          final sId =
              (item['statusid'] ?? item['statusId'] ?? item['status_id'])
                  ?.toString()
                  .trim();

          if (sId != null && statusMap.containsKey(sId)) {
            final statusData = statusMap[sId];
            item['status'] = {
              'nombre': statusData['nombre'],
              'color': statusData['color'],
            };
          } else {
            item['status'] = {'nombre': 'Sin estatus', 'color': '0xFF9E9E9E'};
          }

          folioList.add(HistorialEstado.fromJson(item));
        }
      } else {
        final resultSet = await AppDatabase.db.getAll(getHistorialFolio(), [
          idFolioUuid,
        ]);
        folioList = resultSet
            .map(
              (element) =>
                  HistorialEstado.fromJson(Map<String, dynamic>.from(element)),
            )
            .toList();
      }

      historialList.assignAll(folioList);
      update();
    } catch (e) {
      print("Error en historialFolio: $e");
    }
  }

  Future<void> getDetailsFolio(String idBuscado) async {
    change(null, status: RxStatus.loading());
    try {
      final miId = Supabase.instance.client.auth.currentUser?.id;
      if (miId == null) {
        change(null, status: RxStatus.error("Usuario no autenticado"));
        return;
      }

      if (!kIsWeb) {
        final dynamic resultSet = await AppDatabase.db.execute(folioId(), [
          '%$idBuscado%',
        ]);

        if (resultSet.isEmpty) {
          change(null, status: RxStatus.empty());
          return;
        }
        folio = Folios.fromJson(
          Map<String, dynamic>.from(resultSet.first as Map),
        );
      } else {
        final response = await Supabase.instance.client
            .from('vista_detalle_folios')
            .select()
            .ilike('folioId', '%$idBuscado%')
            .maybeSingle();

        if (response == null) {
          print("No se encontró el folio en Supabase para: $idBuscado");
          change(null, status: RxStatus.empty());
          return;
        }

        folio = Folios.fromJson(Map<String, dynamic>.from(response));

        await historialFolio(folio!.id?.toString());
        print("folio: ${jsonEncode(folio)}");
      }

      final String historialIdTarget = folio!.folioIdHistorial ?? folio!.id ?? "";
      final ultimoRegistro = await getUltimoStatus(historialIdTarget);

      if (ultimoRegistro != null) {
        final rawStatusId = ultimoRegistro["statusId"] ?? ultimoRegistro["statusid"];
        statusId.value = rawStatusId != null ? int.tryParse(rawStatusId.toString()) ?? 0 : 0;
        currentStep.value = getStepIndex(statusId.value);
      } else {
        print(
          "ADVERTENCIA: No se encontró ningún registro en historialestados para el folioId: ${folio!.folioId}",
        );
      }

      change(folio, status: RxStatus.success());
    } catch (e) {
      print("Error detallado al cargar detalles del folio: $e");
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<Map<String, dynamic>?> getUltimoStatus(String folioIdHistorial) async {
    if (folioIdHistorial.isEmpty) {
      print("Error: El ID recibido es nulo o vacío en getUltimoStatus");
      return null;
    }
    try {
      if (!kIsWeb) {
        final List<Map<String, dynamic>> result = await AppDatabase.db.getAll(
          '''
          SELECT * FROM historialestados 
          WHERE "folioId" = ? 
          ORDER BY "created_at" DESC 
          LIMIT 1
          ''',
          [folioIdHistorial],
        );

        if (result.isNotEmpty) {
          return result.first;
        }
      } else {
        final response = await Supabase.instance.client
            .from('historialestados')
            .select()
            .eq('folioId', folioIdHistorial)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (response != null) {
          return Map<String, dynamic>.from(response);
        }
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

  Future<void> pedidoPendiente(String targetFolioId) async {
    try {
      if (!kIsWeb) {
        await AppDatabase.db.execute(insertStatusFolio(), [
          const Uuid().v4(),
          targetFolioId,
          4,
          DateTime.now().toIso8601String(),
        ]);
      } else {
        await Supabase.instance.client.from('historialestados').insert({
          'id': const Uuid().v4(),
          'folioId': targetFolioId,
          'statusId': 4,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print("Error al guardar pedido pendiente: $e");
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      id.clear();
    }
  }

  int getStepIndex(int statusId) {
    switch (statusId) {
      case 1:
        return 0; // Por iniciar
      case 2:
        return 1; // Llegada
      case 3:
        return 3; // Entregado
      case 4:
        return 0; // Pendiente
      case 5:
        return 2; // Sitio
      default:
        return 0;
    }
  }

  void increment() => count.value++;
}