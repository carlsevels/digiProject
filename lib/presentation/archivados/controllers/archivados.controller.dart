import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/archivados/querys/listFoliosArchivados.dart';
import 'package:bitacora_frontend/presentation/folios/querys/datosPersonales.query.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArchivadosController extends GetxController
    with StateMixin<List<Folios>> {
  //TODO: Implement ArchivadosController
  var isSearching = false.obs;
  TextEditingController id = TextEditingController();
  final count = 0.obs;

  RxInt rolUsuario = 0.obs;
  DateTime? selectedDate;
  var rolName = "Cargando...".obs;
  var nameUser = "Cargando...".obs;
  final RxString fechaSeleccionada = "".obs;

  @override
  void onInit() {
    super.onInit();
    _onInit();
  }

  Future<void> _onInit() async {
    selectedDate ??= DateTime.now();
    await getFoliosWithDate(id.text);
  }

  Future<void> getFoliosWithDate(String idBuscado) async {
    change(null, status: RxStatus.loading());

    try {
      final miId = Supabase.instance.client.auth.currentUser?.id;
      if (miId == null) {
        change(null, status: RxStatus.error("Usuario no autenticado"));
        return;
      }

      List<Folios> listFolios = [];

      if (kIsWeb) {
        // ==========================================
        // CONSULTA DIRECTA A SUPABASE (PARA WEB)
        // ==========================================
        var query = Supabase.instance.client
            .from('folios')
            .select()
            .eq('isArchived', true);

        if (idBuscado.isNotEmpty) {
          query = query.ilike('folioId', '%$idBuscado%');
        }

        final response = await query;
        listFolios = (response as List)
            .map((element) => Folios.fromJson(Map<String, dynamic>.from(element)))
            .toList();

        await getDatos();
      } else {
        // ==========================================
        // CONSULTA LOCAL CON POWERSYNC (MÓVIL)
        // ==========================================
        final resultSet = await AppDatabase.db.execute(
          datosPersonalesQuery(),
          [miId],
        );

        if (resultSet.isEmpty) {
          change(null, status: RxStatus.empty());
          return;
        }

        rolUsuario.value = resultSet.first['rolId'] as int;

        final String fechaHoy = (selectedDate ?? DateTime.now())
            .toIso8601String()
            .split('T')[0];

        print(
          "Consultando folios para la fecha: $fechaHoy con rol: ${rolUsuario.value}",
        );

        final getFolios = await AppDatabase.db.getAll(
          listFoliosArchivadosQuery(),
          [rolUsuario.value, idBuscado, idBuscado],
        );

        listFolios = getFolios
            .map(
              (element) =>
                  Folios.fromJson(Map<String, dynamic>.from(element as Map)),
            )
            .toList();
        await getDatos();
      }

      if (listFolios.isEmpty) {
        change(listFolios, status: RxStatus.empty());
      } else {
        print("listFolios Archivados: ${jsonEncode(listFolios)}");
        change(listFolios, status: RxStatus.success());
      }
    } catch (e) {
      print("Error al cargar folios: $e");
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<Map<String, dynamic>?> getDatos() async {
    change(null, status: RxStatus.loading());
    try {
      final miId = Supabase.instance.client.auth.currentUser?.id;

      if (kIsWeb) {
        final response = await Supabase.instance.client
            .from('datosPersonales')
            .select('*, roles!inner(name)')
            .eq('userId', miId as Object)
            .maybeSingle();

        if (response != null) {
          rolName.value = response["roles"]["name"];
          nameUser.value = response["nombre"];
          print("rolName: ${rolName.value}");
          print("nameUser: ${nameUser.value}");
        } else {
          change(null, status: RxStatus.empty());
        }
      } else {
        final status = AppDatabase.db.currentStatus;
        print("¿Ha terminado la sincronización inicial?: ${status.hasSynced}");

        if (status.hasSynced != true) {
          print("Esperando a que PowerSync sincronice...");
          await AppDatabase.db.statusStream.firstWhere(
            (s) => s.hasSynced == true,
          );
          print("¡Sincronización completada!");
        }

        final resultado = await AppDatabase.db.getOptional(
          '''
          SELECT dp.*, r."name" as "nombre_rol" 
          FROM "datosPersonales" dp
          INNER JOIN "roles" r ON dp."rolId" = r."id"
          WHERE dp."userId" = ?
          ''',
          [miId],
        );
        if (resultado != null) {
          rolName.value = resultado["nombre_rol"];
          nameUser.value = resultado["nombre"];
          print("rolName: ${rolName.value}");
          print("nameUser: ${nameUser.value}");
        } else {
          change(null, status: RxStatus.empty());
        }
      }
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
    return null;
  }

  String obtenerEtiquetaFecha(DateTime fechaSeleccionada) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final fecha = DateTime(
      fechaSeleccionada.year,
      fechaSeleccionada.month,
      fechaSeleccionada.day,
    );

    final int diferencia = hoy.difference(fecha).inDays;

    print("DEBUG: Hoy es $hoy, fecha recibida $fecha, diferencia: $diferencia");

    if (diferencia == 0) {
      return "Hoy";
    } else if (diferencia == 1) {
      return "Ayer";
    } else if (diferencia > 1 && diferencia <= 7) {
      return "Hace $diferencia días";
    } else {
      return DateFormat("d 'de' MMMM", 'es_ES').format(fechaSeleccionada);
    }
  }

  Future<void> archivarFolio(String folioId) async {
    try {
      if (kIsWeb) {
        await Supabase.instance.client
            .from('folios')
            .update({"isArchived": false})
            .eq('folioId', folioId);
      } else {
        await AppDatabase.db.execute(
          '''
          UPDATE folios 
          SET "isArchived" = false 
          WHERE "folioId" = ?;
          ''',
          [folioId],
        );
      }
      await getFoliosWithDate(id.text);
      return null;
    } catch (e) {
      print("Error al desarchivar folio: $e");
      return null;
    }
  }

  Future<void> eliminarFolio(String folioId) async {
    try {
      if (kIsWeb) {
        await Supabase.instance.client
            .from('folios')
            .delete()
            .eq('folioId', folioId);
      } else {
        await AppDatabase.db.execute("DELETE FROM folios WHERE folioId = ?", [
          folioId,
        ]);
      }
    } catch (e) {
      print("Error de SQL: ${e.toString()}");
      return null;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}