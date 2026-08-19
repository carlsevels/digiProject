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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoliosController extends GetxController with StateMixin<List<Folios>> {
  //TODO: Implement FoliosController
  RxInt rolUsuario = 0.obs;
  var rolName = "Cargando...".obs;
  var nameUser = "Cargando...".obs;
  final RxString fechaSeleccionada = "".obs;
  final supabase = Supabase.instance.client;
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
    final box = GetStorage();
    List<dynamic>? guardado = box.read('orden_municipios');
    if (guardado != null) {
      ordenMunicipiosCustom.assignAll(
        guardado.map((e) => e.toString()).toList(),
      );
    }
    await getDatos();
    controllerEasyDate = EasyDatePickerController();

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

  final RxList<dynamic> elementosAplanados = <dynamic>[].obs;

  void actualizarElementosAplanados(List<dynamic> stateData) {
    final Map<String, List<dynamic>> foliosPorMunicipio = {};
    for (var folio in stateData) {
      final municipio =
          (folio.municipio != null && folio.municipio!.trim().isNotEmpty)
          ? folio.municipio!
          : 'Sin Municipio';
      foliosPorMunicipio.putIfAbsent(municipio, () => []).add(folio);
    }

    List<String> municipiosDisponibles = foliosPorMunicipio.keys.toList();
    if (ordenMunicipiosCustom.isEmpty) {
      ordenMunicipiosCustom.assignAll(municipiosDisponibles);
    } else {
      for (var m in municipiosDisponibles) {
        if (!ordenMunicipiosCustom.contains(m)) {
          ordenMunicipiosCustom.add(m);
        }
      }
      ordenMunicipiosCustom.removeWhere(
        (m) => !foliosPorMunicipio.containsKey(m),
      );
    }

    final List<dynamic> tempLista = [];
    for (var municipio in ordenMunicipiosCustom) {
      if (foliosPorMunicipio.containsKey(municipio)) {
        final listaFolios = foliosPorMunicipio[municipio]!;
        tempLista.add({
          'tipo': 'header',
          'nombre': municipio,
          'count': listaFolios.length,
        });
        for (var folio in listaFolios) {
          tempLista.add({'tipo': 'folio', 'data': folio});
        }
      }
    }
    elementosAplanados.assignAll(tempLista);
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

        if (response == null ||
            (response is List && (response.isEmpty || response[0] == null))) {
          print("No se encontraron registros para la fecha: $fechaHoy");
          change([], status: RxStatus.empty());
          return;
        }

        final data = response[0];

        if (data == null || (data is List && data.isEmpty)) {
          change([], status: RxStatus.empty());
          return;
        }

        listFolios = (data as List)
            .map(
              (element) => Folios.fromJson(Map<String, dynamic>.from(element)),
            )
            .toList();

        if (listFolios.isEmpty) {
          change([], status: RxStatus.empty());
          return;
        }

        print("Folios cargados en Web: ${listFolios.length}");
      } else {
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
        print("listFolios: ${jsonEncode(listFolios)}");
      }

      actualizarElementosAplanados(listFolios);

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

  Future<void> forzarSincronizacionManual() async {
    try {
      Get.snackbar(
        "Sincronización",
        "Verificando conexión y datos pendientes...",
      );

      // PowerSync sincroniza automáticamente en segundo plano cuando hay red.
      // Solo recargamos los datos locales para refrescar la interfaz.
      await getFoliosWithDate();

      Get.snackbar("Éxito", "Vista actualizada correctamente.");
    } catch (e) {
      print("Error al sincronizar: $e");
      Get.snackbar("Error", "No se pudo actualizar: $e");
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
      final status = AppDatabase.db.currentStatus;
      if (!kIsWeb) {
        await AppDatabase.db.disconnect();

        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/${AppDatabase.db}');

        if (await file.exists()) {
          await file.delete();
        }
      }

      await Supabase.instance.client.auth.signOut();

      await AppDatabase.db.disconnect();

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

  Future<bool?> mostrarDialogoArchivar(
    BuildContext context,
    dynamic folio,
    Function onConfirm,
  ) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFE8F0FE),
                  child: Icon(
                    Icons.archive_outlined,
                    size: 40,
                    color: Color(0xFF1A73E8),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Archivar Folio',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  '¿Estás seguro de enviar el folio #${folio.folioId ?? ""} al archivo?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        onConfirm();
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Archivar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> mostrarDialogoEliminar(
    BuildContext context,
    dynamic folio,
    Function onConfirm,
  ) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFFEECEC),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 40,
                    color: Color(0xFFD9534F),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Eliminar Folio',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  '¿Estás seguro de eliminar el folio #${folio.folioId ?? ""}? Esta acción no se puede deshacer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        onConfirm();
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD9534F),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> syncPendingData() async {
    try {
      final supabase = Supabase.instance.client;

      // 1. Notificar al usuario que comenzó el proceso
      Get.snackbar(
        "Sincronización",
        "Buscando datos pendientes...",
        snackPosition: SnackPosition.BOTTOM,
      );

      final datosPendientes = await AppDatabase.db.getAll(
        'SELECT * FROM ps_crud',
      );

      if (datosPendientes.isEmpty) {
        Get.snackbar(
          "Sincronización",
          "No hay folios ni historiales pendientes por sincronizar.",
        );
        return;
      }

      List<Map<String, dynamic>> registrosFolios = [];
      List<Map<String, dynamic>> registrosHistorial = [];

      for (var row in datosPendientes) {
        final rawData = row['data'] as String;
        final outerMap = jsonDecode(rawData);
        final String type = outerMap['type'];

        if (type == 'folios') {
          registrosFolios.add({'id_crud': row['id'], ...outerMap});
        } else if (type == 'historialestados') {
          registrosHistorial.add({'id_crud': row['id'], ...outerMap});
        }
      }

      if (registrosFolios.isEmpty && registrosHistorial.isEmpty) {
        Get.snackbar(
          "Sincronización",
          "No se encontraron registros pendientes válidos.",
        );
        return;
      }

      List<Map<String, dynamic>> payloadsFolios = [];
      List<int> idsCrudFolios = [];

      List<Map<String, dynamic>> payloadsHistorial = [];
      List<int> idsCrudHistorial = [];

      // Preparar folios
      for (var folioItem in registrosFolios) {
        final opFolio = folioItem['op'];
        if (opFolio == 'PUT' || opFolio == 'POST' || opFolio == 'PATCH') {
          payloadsFolios.add(folioItem['data']);
          idsCrudFolios.add(folioItem['id_crud']);
        }
      }

      // Preparar historiales
      for (var historialItem in registrosHistorial) {
        final opHistorial = historialItem['op'];
        if (opHistorial == 'PUT' ||
            opHistorial == 'POST' ||
            opHistorial == 'PATCH') {
          payloadsHistorial.add(historialItem['data']);
          idsCrudHistorial.add(historialItem['id_crud']);
        }
      }

      int totalSincronizados = 0;

      // 2. Subir Folios
      if (payloadsFolios.isNotEmpty) {
        await supabase.from('folios').upsert(payloadsFolios);
        totalSincronizados += payloadsFolios.length;

        for (var idCrud in idsCrudFolios) {
          await AppDatabase.db.execute('DELETE FROM ps_crud WHERE id = ?', [
            idCrud,
          ]);
        }
      }

      // 3. Subir Historiales
      if (payloadsHistorial.isNotEmpty) {
        await supabase.from('historialestados').upsert(payloadsHistorial);
        totalSincronizados += payloadsHistorial.length;

        for (var idCrud in idsCrudHistorial) {
          await AppDatabase.db.execute('DELETE FROM ps_crud WHERE id = ?', [
            idCrud,
          ]);
        }
      }

      Get.snackbar(
        "¡Sincronización Exitosa!",
        "Se sincronizaron $totalSincronizados registros (${payloadsFolios.length} folios y ${payloadsHistorial.length} historiales) correctamente.",
        duration: const Duration(seconds: 4),
      );
    } catch (e, stackTrace) {
      // Imprime el error exacto y la traza completa en la consola para depuración
      print("❌ Error crítico durante la sincronización masiva: $e");
      print("🔍 StackTrace: $stackTrace");

      // Muestra un mensaje detallado al usuario incluyendo el error exacto
      Get.snackbar(
        "Error de Sincronización",
        "Ocurrió un problema: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  void increment() => count.value++;
}
