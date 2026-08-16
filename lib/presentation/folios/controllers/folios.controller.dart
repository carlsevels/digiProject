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
import 'package:powersync/sqlite3.dart' hide Row;
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

  // Lista observable ya aplanada para que la vista no tenga que procesar nada
  final RxList<dynamic> elementosAplanados = <dynamic>[].obs;

  // Método rápido para actualizar la estructura solo cuando cambian los datos o el orden
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

      actualizarElementosAplanados(listFolios);

      final datosPendientes = await AppDatabase.db.getAll(
        'SELECT * FROM ps_crud',
      );
      for (var row in datosPendientes) {
        try {
          // El campo 'data' es un string JSON que debemos decodificar
          final rawData = row['data'] as String;
          final outerMap = jsonDecode(rawData);

          final String op = outerMap['op']; // Ejemplo: 'PUT'
          final String type =
              outerMap['type']; // Ejemplo: 'folios', 'historialestados'
          final Map<String, dynamic> payload =
              outerMap['data']; // El objeto a insertar/actualizar

          // 2. Enviar a Supabase según el tipo de tabla
          if (op == 'PUT' || op == 'POST') {
            await supabase.from(type).upsert(payload);
          }

          // 3. Si se envió con éxito, eliminar de la tabla local ps_crud
          final int idRegistro = row['id'];
          await AppDatabase.db.execute('DELETE FROM ps_crud WHERE id = ?', [
            idRegistro,
          ]);

          print("Sincronizado con éxito: ID local $idRegistro");
        } catch (e) {
          print("Error al sincronizar el registro ${row['id']}: $e");
          // Opcional: Detener el ciclo o continuar con el siguiente
        }
      }

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
      final status = AppDatabase.db.currentStatus;

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

  void increment() => count.value++;
}
