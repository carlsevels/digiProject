import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitacora_frontend/infrastructure/models/datosPersonales.dart';
import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/folios/querys/datosPersonales.query.dart';
import 'package:bitacora_frontend/presentation/folios/querys/listFolios.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/sqlite3.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoliosController extends GetxController with StateMixin<List<Folios>> {
  //TODO: Implement FoliosController
  RxInt rolUsuario = 0.obs;
  var rolName = "Cargando...".obs;
  var nameUser = "Cargando...".obs;
  final RxString fechaSeleccionada = "".obs;

  final RxList<String> ordenMunicipiosCustom = <String>[].obs;

  final now = DateTime.now();
  late final EasyDatePickerController controllerEasyDate;

  final Rx<DatosPersonales> _datosPersonales = DatosPersonales().obs;
  DatosPersonales get datosPersonales => this._datosPersonales.value;
  set datosPersonales(value) => this._datosPersonales.value = value;

  final Rxn<DateTime> _selectedDate = Rxn<DateTime>(DateTime.now());
  DateTime? get selectedDate => _selectedDate.value;
  set selectedDate(DateTime? date) => _selectedDate.value = date;

  final count = 0.obs;

  @override
  void dispose() {
    controllerEasyDate.dispose();
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();
    _onInit();
  }

  Future<void> _onInit() async {
    selectedDate ??= DateTime.now();
    // En tu onInit() del controlador
    final box = GetStorage();
    List<dynamic>? guardado = box.read('orden_municipios');
    if (guardado != null) {
      ordenMunicipiosCustom.assignAll(
        guardado.map((e) => e.toString()).toList(),
      );
    }
    await getDatos();
    controllerEasyDate = EasyDatePickerController();
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

      final ResultSet resultSet = await AppDatabase.db.execute(
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

      final getFolios = await AppDatabase.db.getAll(listFoliosQuery(), [
        fechaHoy,
      ]);

      List<Folios> listFolios = getFolios
          .map(
            (element) =>
                Folios.fromJson(Map<String, dynamic>.from(element as Map)),
          )
          .toList();

      if (listFolios.isEmpty) {
        change(listFolios, status: RxStatus.empty());
      } else {
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
      await AppDatabase.db.disconnect();

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${AppDatabase.db}');

      if (await file.exists()) {
        await file.delete();
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
    change(null, status: RxStatus.loading());
    try {
      final miId = Supabase.instance.client.auth.currentUser?.id;
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
      await AppDatabase.db.execute(
        '''
        UPDATE folios 
        SET "isArchived" = true 
        WHERE "folioId" = ?;
        ''',
        [folioId],
      );
      await getFoliosWithDate();
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
    } catch (e) {
      print("Error de SQL: ${e.toString()}");
      return null;
    }
  }

  void increment() => count.value++;
}
