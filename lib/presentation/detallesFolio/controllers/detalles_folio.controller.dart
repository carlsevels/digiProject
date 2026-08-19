import 'dart:convert';
import 'dart:developer';

import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/detallesFolio.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/getHistorialFolio.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/update.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class DetallesFolioController extends GetxController with StateMixin<Folios> {
  RxInt currentStep = 0.obs;
  RxInt statusId = 0.obs;
  int? nextStatus;
  var historialList = <Folios>[].obs;

  String folioIdArgnt = "";

  @override
  void onInit() {
    super.onInit();
    _leerArgumentos();
    onInitDetalles();
  }

  @override
  void onClose() {
    print("Cerrando pantalla, limpiando recursos...");
    super.onClose();
  }

  void _leerArgumentos() {
    final args = Get.arguments;

    if (args is String) {
      folioIdArgnt = args;
    } else if (args is Map) {
      folioIdArgnt = args['folioId']?.toString() ?? "";
    } else {
      folioIdArgnt = args?.toString() ?? "";
    }
  }

  Future<void> onInitDetalles() async {
    await getDetailsFolio(folioIdArgnt);
  }

  @override
  void onReady() {
    super.onReady();
  }

  Future<void> getDetailsFolio(String idBuscado) async {
    change(null, status: RxStatus.loading());
    try {
      Folios? folio;

      if (kIsWeb) {
        final response = await Supabase.instance.client.rpc(
          'obtener_detalle_folio_web',
          params: {'id_buscado': idBuscado},
        );

        if (response == null ||
            (response is List && (response.isEmpty || response[0] == null))) {
          change(null, status: RxStatus.empty());
          return;
        }

        final data = response[0];
        if (data == null || (data is List && data.isEmpty)) {
          change(null, status: RxStatus.empty());
          return;
        }

        final itemMap = data is List
            ? Map<String, dynamic>.from(data[0])
            : Map<String, dynamic>.from(data);
        folio = Folios.fromJson(itemMap);
      } else {
        final resultSet = await AppDatabase.db.execute(folioId(), [idBuscado]);
        if (resultSet.isEmpty) {
          change(null, status: RxStatus.empty());
          return;
        }
        folio = Folios.fromJson(resultSet.first);
        print("folioId: ${jsonEncode(folio)}");
      }

      final ultimoRegistro = await getUltimoStatus(
        folio.folioIdHistorial ?? "",
      );

      if (ultimoRegistro != null) {
        statusId.value = ultimoRegistro["statusId"] as int;
        currentStep.value = getStepIndex(statusId.value);
        print("Status actual actualizado a: ${currentStep.value}");
      } else {
        print(
          "ADVERTENCIA: No se encontró ningún registro en historialestados para el folioId: ${folio.folioId}",
        );
      }

      print("Folio: ${jsonEncode(folio)}");
      print("state!.isArchived: ${folio.isArchived}");
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
      List<Folios> folio = [];

      if (kIsWeb) {
        final response = await Supabase.instance.client
            .from('historialestados')
            .select('*, status:statusId(nombre, color)')
            .eq('folioId', folioId)
            .order('created_at', ascending: false);

        if (response != null) {
          folio = (response as List).map((element) {
            final map = Map<String, dynamic>.from(element);

            if (map['status'] != null && map['status'] is Map) {
              final statusMap = Map<String, dynamic>.from(map['status']);
              map['status'] = statusMap['nombre'];
              map['statuscolor'] = statusMap['color']?.toString();
            }

            return Folios.fromJson(map);
          }).toList();
        }
      } else {
        final resultSet = await AppDatabase.db.getAll(getHistorialFolio(), [
          folioId,
        ]);

        folio = resultSet
            .map(
              (element) =>
                  Folios.fromJson(Map<String, dynamic>.from(element as Map)),
            )
            .toList();
      }

      historialList.value = folio;
      print("FolioId: ${folioId}");
      print("Folio Historial: ${jsonEncode(historialList)}");
    } catch (e) {
      print("Error en historial: $e");
    }
  }

  Color parseColor(String? colorStr, {Color defaultColor = Colors.grey}) {
    if (colorStr == null || colorStr.isEmpty) return defaultColor;

    String cleanColor = colorStr
        .toUpperCase()
        .replaceAll('#', '')
        .replaceAll('0X', '')
        .trim();

    if (cleanColor.length == 6) {
      cleanColor = 'FF$cleanColor';
    }

    int? colorInt = int.tryParse(cleanColor, radix: 16);

    return colorInt != null ? Color(colorInt) : defaultColor;
  }

  int getStepIndex(int statusId) {
    switch (statusId) {
      case 1:
        return 0;
      case 2:
        return 1;
      case 3:
        return 3;
      case 4:
        return 0;
      case 5:
        return 2;
      default:
        return 0;
    }
  }

  Widget statusFolio(int statusId) {
    switch (statusId) {
      case 1 || 4:
        return const Text(
          'Empezar ruta',
          textScaleFactor: 1.3,
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case 2:
        return const Text(
          'Llegada',
          textScaleFactor: 1.3,
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case 5:
        return const Text(
          'Finalizar entrega',
          textScaleFactor: 1.3,
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      default:
        return const SizedBox.shrink();
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

    final nuevoHistorial = {
      'id': const Uuid().v4(),
      'folioId': folioId,
      'statusId': nextStatus,
      'created_at': DateTime.now().toIso8601String(),
    };

    bool enviadoASupabase = false;

    try {
      print("🌐 Intentando cambiar estado en Supabase...");
      await Supabase.instance.client
          .from('historialestados')
          .insert(nuevoHistorial);
      enviadoASupabase = true;
      print("✅ Estado cambiado en Supabase.");
    } catch (e) {
      print("⚠️ Sin conexión o error en Supabase, guardando localmente: $e");
      enviadoASupabase = false;
    }

    if (!enviadoASupabase) {
      try {
        await AppDatabase.db.execute(insertStatusFolio(), [
          nuevoHistorial['id'],
          nuevoHistorial['folioId'],
          nuevoHistorial['statusId'].toString(),
          nuevoHistorial['created_at'],
        ]);
        print("💾 Cambios guardados localmente en SQLite.");
      } catch (dbError) {
        print("❌ Error crítico guardando localmente: $dbError");
        Get.snackbar("Error", "No se pudo actualizar el estado localmente.");
        return null;
      }
    }

    return nextStatus;
  }

  Future<void> pedidoPendiente(String folioId) async {
    if (folioId.isEmpty) {
      print("Error: folioId vacío en pedidoPendiente");
      return;
    }

    final nuevoHistorial = {
      'id': const Uuid().v4(),
      'folioId': folioId,
      'statusId': 4,
      'created_at': DateTime.now().toIso8601String(),
    };

    bool enviadoASupabase = false;

    try {
      print("🌐 Intentando registrar pedido pendiente en Supabase...");
      await Supabase.instance.client
          .from('historialestados')
          .insert(nuevoHistorial);
      enviadoASupabase = true;
      print("✅ Pedido pendiente registrado en Supabase.");
    } catch (e) {
      print("⚠️ Sin conexión o error en Supabase, guardando localmente: $e");
      enviadoASupabase = false;
    }

    if (!enviadoASupabase) {
      try {
        await AppDatabase.db.execute(insertStatusFolio(), [
          nuevoHistorial['id'],
          nuevoHistorial['folioId'],
          nuevoHistorial['statusId'].toString(),
          nuevoHistorial['created_at'],
        ]);
        print("💾 Pedido pendiente guardado localmente en SQLite.");
      } catch (dbError) {
        print("❌ Error crítico guardando localmente: $dbError");
        Get.snackbar(
          "Error",
          "No se pudo guardar el estado pendiente localmente.",
        );
      }
    }
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
    if (folioId.isEmpty) {
      print("Error: folioId vacío en archivarFolio");
      return;
    }

    bool enviadoASupabase = false;

    // 1. Intentar actualizar directamente en Supabase
    try {
      print("🌐 Intentando archivar folio en Supabase...");
      await Supabase.instance.client
          .from('folios')
          .update({"isArchived": true})
          .eq('folioId', folioId);

      enviadoASupabase = true;
      print("✅ Folio archivado en Supabase.");
    } catch (e) {
      print("⚠️ Sin conexión o error en Supabase, archivando localmente: $e");
      enviadoASupabase = false;
    }

    // 2. Si falló Supabase, actualizar en la base de datos local (PowerSync/SQLite)
    if (!enviadoASupabase) {
      try {
        await AppDatabase.db.execute(
          '''
        UPDATE folios 
        SET "isArchived" = true 
        WHERE "folioId" = ?;
        ''',
          [folioId],
        );
        print("💾 Folio archivado localmente en SQLite.");
      } catch (dbError) {
        print("❌ Error crítico actualizando localmente: $dbError");
        Get.snackbar("Error", "No se pudo archivar el folio localmente.");
        return;
      }
    }

    // Refrescar los detalles en pantalla
    try {
      await onInitDetalles();
    } catch (e) {
      print("Error al actualizar detalles tras archivar: $e");
    }
  }

  Future<void> restaurarFolio(String folioId) async {
    if (folioId.isEmpty) {
      print("Error: folioId vacío en restaurarFolio");
      return;
    }

    bool enviadoASupabase = false;

    // 1. Intentar actualizar directamente en Supabase
    try {
      print("🌐 Intentando restaurar folio en Supabase...");
      await Supabase.instance.client
          .from('folios')
          .update({"isArchived": false})
          .eq('folioId', folioId);

      enviadoASupabase = true;
      print("✅ Folio restaurado en Supabase.");
    } catch (e) {
      print("⚠️ Sin conexión o error en Supabase, restaurando localmente: $e");
      enviadoASupabase = false;
    }

    // 2. Si falló Supabase, actualizar en la base de datos local (PowerSync/SQLite)
    if (!enviadoASupabase) {
      try {
        await AppDatabase.db.execute(
          '''
        UPDATE folios 
        SET "isArchived" = false 
        WHERE "folioId" = ?;
        ''',
          [folioId],
        );
        print("💾 Folio restaurado localmente en SQLite.");
      } catch (dbError) {
        print("❌ Error crítico actualizando localmente: $dbError");
        Get.snackbar("Error", "No se pudo restaurar el folio localmente.");
        return;
      }
    }

    // Refrescar los detalles en pantalla
    try {
      await onInitDetalles();
    } catch (e) {
      print("Error al actualizar detalles tras restaurar: $e");
    }
  }

  Future<void> eliminarFolio(String folioId) async {
    if (folioId.isEmpty) {
      print("Error: folioId vacío en eliminarFolio");
      return;
    }

    bool eliminadoEnSupabase = false;

    // 1. Intentar eliminar directamente en Supabase
    try {
      print("🌐 Intentando eliminar folio en Supabase...");
      await Supabase.instance.client
          .from('folios')
          .delete()
          .eq('folioId', folioId);

      eliminadoEnSupabase = true;
      print("✅ Folio eliminado en Supabase.");
    } catch (e) {
      print("⚠️ Sin conexión o error en Supabase, eliminando localmente: $e");
      eliminadoEnSupabase = false;
    }

    // 2. Si falló Supabase, eliminar en la base de datos local (PowerSync/SQLite)
    if (!eliminadoEnSupabase) {
      try {
        await AppDatabase.db.execute("DELETE FROM folios WHERE folioId = ?", [
          folioId,
        ]);
        print("💾 Folio eliminado localmente en SQLite.");
      } catch (dbError) {
        print("❌ Error crítico eliminando localmente: $dbError");
        Get.snackbar("Error", "No se pudo eliminar el folio localmente.");
        return;
      }
    }

    // Redirigir a la vista de folios
    Get.offAllNamed(Routes.FOLIOS);
  }

  final SignatureController signatureControllerController = SignatureController(
    penStrokeWidth: 10,
    strokeCap: StrokeCap.butt,
    strokeJoin: StrokeJoin.miter,
    penColor: Colors.red,
    exportBackgroundColor: Colors.transparent,
    exportPenColor: Colors.black,
    onDrawStart: () => log('onDrawStart called!'),
    onDrawEnd: () => log('onDrawEnd called!'),
  );

  Future<void> exportSVG(BuildContext context) async {
    if (signatureControllerController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(key: Key('snackbarSVG'), content: Text('No content')),
      );
      return;
    }

    String? rawSVGoptimized = signatureControllerController.toRawSVG();
    if (rawSVGoptimized == null) return;

    try {
      final bytes = utf8.encode(rawSVGoptimized);

      final fileName = 'firma_${DateTime.now().millisecondsSinceEpoch}.svg';
      final filePath = 'public/$fileName';

      await Supabase.instance.client.storage
          .from('firmas')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/svg+xml'),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firma guardada y sincronizada exitosamente'),
        ),
      );
    } catch (e) {
      debugPrint('Error al guardar la firma: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al subir: $e')));
    }
  }
}
