import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitacora_frontend/infrastructure/models/datosPersonales.dart';
import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/folios/querys/datosPersonales.query.dart';
import 'package:bitacora_frontend/presentation/folios/querys/listFolios.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoliosController extends GetxController with StateMixin<List<Folios>> {
  //TODO: Implement FoliosController
  RxInt rolUsuario = 0.obs;
  DateTime? selectedDate;
  var rolName = "Cargando...".obs;
  var nameUser = "Cargando...".obs;
  final RxString fechaSeleccionada = "".obs;

  final Rx<DatosPersonales> _datosPersonales = DatosPersonales().obs;
  DatosPersonales get datosPersonales => this._datosPersonales.value;
  set datosPersonales(value) => this._datosPersonales.value = value;

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _onInit();
  }

  Future<void> _onInit() async {
    selectedDate ??= DateTime.now();

    // Inicializamos la variable reactiva de la fecha para evitar vacíos en la UI
    fechaSeleccionada.value = selectedDate!.toIso8601String().split('T')[0];

    await getDatos();
    await getFoliosWithDate();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getFoliosWithDate() async {
    change(null, status: RxStatus.loading());

    try {
      final miId = Supabase.instance.client.auth.currentUser?.id;
      if (miId == null) {
        change(null, status: RxStatus.error("Usuario no autenticado"));
        return;
      }

      final String fechaHoy = (selectedDate ?? DateTime.now())
          .toIso8601String()
          .split('T')[0];

      List<Folios> listFolios = [];

      if (kIsWeb) {
        final response = await Supabase.instance.client.rpc(
          'obtener_folios_web',
          params: {'fecha_filtro': fechaHoy},
        );

        // Si la respuesta es nula, vacía o contiene un elemento nulo [null]
        if (response == null ||
            (response is List && (response.isEmpty || response[0] == null))) {
          print("No se encontraron registros para la fecha: $fechaHoy");
          change([], status: RxStatus.empty());
          return;
        }

        final data = response[0];

        // Validamos por si el json_agg interno devolvió null
        if (data == null || (data is List && data.isEmpty)) {
          change([], status: RxStatus.empty());
          return;
        }

        listFolios = (data as List)
            .map(
              (element) => Folios.fromJson(Map<String, dynamic>.from(element)),
            )
            .toList();

        // Si después de mapear la lista viene vacía
        if (listFolios.isEmpty) {
          change([], status: RxStatus.empty());
          return;
        }

        print("Folios cargados en Web: ${listFolios.length}");
      } else {
        // ==========================================
        // CONSULTA LOCAL CON POWERSYNC (MÓVIL)
        // ==========================================
        final resultSet = await AppDatabase.db.execute(datosPersonalesQuery(), [
          miId,
        ]);

        if (resultSet.isNotEmpty) {
          rolUsuario.value = resultSet.first['rolId'] as int;
        }

        print(
          "Consultando folios para la fecha: $fechaHoy con rol: ${rolUsuario.value}",
        );

        final getFolios = await AppDatabase.db.getAll(listFoliosQuery(), [
          fechaHoy,
        ]);

        listFolios = getFolios
            .map(
              (element) =>
                  Folios.fromJson(Map<String, dynamic>.from(element as Map)),
            )
            .toList();
      }

      if (listFolios.isEmpty) {
        change(listFolios, status: RxStatus.empty());
      } else {
        print("listFolios: ${jsonEncode(listFolios)}");
        change(listFolios, status: RxStatus.success());
      }
    } catch (e) {
      print("Error al cargar folios: $e");
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      fechaSeleccionada.value = picked.toIso8601String().split('T')[0];

      await getFoliosWithDate();
    }
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await AppDatabase.db.disconnect();

        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/${AppDatabase.db}');

        if (await file.exists()) {
          await file.delete();
        }
      }

      await Supabase.instance.client.auth.signOut();
      await Get.deleteAll(force: true);
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      debugPrint("Error al cerrar sesión: $e");
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<Map<String, dynamic>?> getDatos() async {
    try {
      final miId = Supabase.instance.client.auth.currentUser?.id;

      if (kIsWeb) {
        // Consulta directa a Supabase en Web
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
        }
      } else {
        // Consulta local con PowerSync en Móvil
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
        }
      }
    } catch (e) {
      debugPrint("Error al obtener datos personales: $e");
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
            .update({"isArchived": true})
            .eq('folioId', folioId);
      } else {
        await AppDatabase.db.execute(
          '''
          UPDATE folios 
          SET "isArchived" = true 
          WHERE "folioId" = ?;
          ''',
          [folioId],
        );
      }
      await getFoliosWithDate();
    } catch (e) {
      print("Error al archivar folio: $e");
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
      await getFoliosWithDate();
    } catch (e) {
      print("Error de eliminación: ${e.toString()}");
    }
  }

  void increment() => count.value++;
}
