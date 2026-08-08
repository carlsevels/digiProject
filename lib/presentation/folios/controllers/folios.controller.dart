import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitacora_frontend/infrastructure/models/datosPersonales.dart';
import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/models/historial_folios.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/getHistorialFolio.dart';
import 'package:bitacora_frontend/presentation/folios/querys/datosPersonales.query.dart';
import 'package:bitacora_frontend/presentation/folios/querys/listFolios.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class FoliosController extends GetxController with StateMixin<List<Folios>> {
  //TODO: Implement FoliosController
  RxInt rolUsuario = 0.obs;
  DateTime? selectedDate;
  var rolName = "Cargando...".obs;
  var nameUser = "Cargando...".obs;
  final RxString fechaSeleccionada = "".obs;
  var folioSeleccionado = Rxn<Folios>();
  RxInt statusId = 0.obs;
  RxInt currentStep = 0.obs;
  final RxList<HistorialEstado> historialList = <HistorialEstado>[].obs;
  List<HistorialEstado> folioList = [];
  List<Folios> folioListovil = [];
  final Rx<DatosPersonales> _datosPersonales = DatosPersonales().obs;
  DatosPersonales get datosPersonales => this._datosPersonales.value;
  set datosPersonales(value) => this._datosPersonales.value = value;

  final count = 0.obs;
  // Variables observables en tu FoliosController
  final folioExpandidoId = RxnString(); // o Rx<String?>(null)

  // Método para alternar la expansión y evitar duplicados
  void alternarExpansion(String? id, Folios? folio) {
    if (folioExpandidoId.value == id) {
      folioExpandidoId.value = null; // Cierra si ya estaba abierto
    } else {
      folioExpandidoId.value = id; // Abre el nuevo
      if (id != null && folio != null) {
        folioSeleccionado.value = folio;
        historialFolio(id); // Carga el historial una sola vez
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    onInitDetallesFolio();
  }

  Future<void> onInitDetallesFolio() async {
    selectedDate ??= DateTime.now();
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

      int rolId = 0;
      List<Folios> listFolios = [];

      if (!kIsWeb) {
        final dynamic resultSet = await AppDatabase.db.execute(
          datosPersonalesQuery(),
          [miId],
        );

        if (resultSet.isEmpty) {
          change(null, status: RxStatus.empty());
          return;
        }

        rolId = resultSet.first['rolId'] as int;
        rolUsuario.value = rolId;

        final rawFolios = await AppDatabase.db.getAll(listFoliosQuery(), [
          fechaHoy,
        ]);

        listFolios = rawFolios
            .map(
              (element) =>
                  Folios.fromJson(Map<String, dynamic>.from(element as Map)),
            )
            .toList();
      } else {
        final userResponse = await Supabase.instance.client
            .from('datosPersonales')
            .select('rolId')
            .eq('userId', miId)
            .maybeSingle();

        if (userResponse == null || userResponse['rolId'] == null) {
          change(null, status: RxStatus.empty());
          return;
        }

        rolId = userResponse['rolId'] as int;
        rolUsuario.value = rolId;

        final List<dynamic> rawFolios = await Supabase.instance.client
            .from('vista_folios_completos')
            .select()
            .eq('created_at', fechaHoy)
            .order('created_at', ascending: false);

        listFolios = [];
        for (var element in rawFolios) {
          final map = Map<String, dynamic>.from(element as Map);
          listFolios.add(Folios.fromJson(map));
        }
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

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      confirmText: "Aceptar",
      cancelText: "Cancelar",
      helpText: "Buscar fecha",
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1D6CFF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF1D6CFF)),
            ),
          ),
          child: child!,
        );
      },
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

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        try {
          await AppDatabase.db.disconnect();
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/${AppDatabase.db}');

          if (await file.exists()) {
            await file.delete();
          }
        } catch (dbError) {
          debugPrint("Error al limpiar base de datos local: $dbError");
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

      if (resultado != null) {
        rolName.value = resultado["nombre_rol"];
        nameUser.value = resultado["nombre"];
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
      if (!kIsWeb) {
        await AppDatabase.db.execute(
          '''
          UPDATE folios 
          SET "isArchived" = true 
          WHERE "folioId" = ?;
          ''',
          [folioId],
        );
      } else {
        await Supabase.instance.client
            .from('folios')
            .update({'isArchived': true})
            .eq('folioId', folioId);
      }
      await getFoliosWithDate();
    } catch (e) {
      print("Error al archivar folio: $e");
    }
  }

  Future<void> eliminarFolio(String folioId) async {
    try {
      if (!kIsWeb) {
        await AppDatabase.db.execute("DELETE FROM folios WHERE folioId = ?", [
          folioId,
        ]);
      } else {
        await Supabase.instance.client
            .from('folios')
            .delete()
            .eq('folioId', folioId);
      }
    } catch (e) {
      print("Error al eliminar folio: ${e.toString()}");
    }
  }

  void increment() => count.value++;
}
