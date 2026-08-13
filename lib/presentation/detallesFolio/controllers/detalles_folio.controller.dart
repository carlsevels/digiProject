import 'dart:convert';
import 'dart:developer';

import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/detallesFolio.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/getHistorialFolio.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/update.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:powersync/sqlite3.dart';
import 'package:signature/signature.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

class DetallesFolioController extends GetxController with StateMixin<Folios> {
  RxInt currentStep = 0.obs;
  RxInt statusId = 0.obs;
  int? nextStatus;
  var historialList = <Folios>[].obs;

  // Variables para guardar los datos que recibas
//  String id = "";
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

    if (args is Map) {
     //id = args['id']?.toString() ?? "";
      folioIdArgnt = args['folioId']?.toString() ?? "";
    } else if (args is String) {
     // id = args;
    }
  }

  Future<void> onInitDetalles() async {
    // print("ID recibido: $id");
    // print("FolioId recibido: $folioIdArgnt");

    // if (id.isEmpty) {
    //   print("Error: El ID recibido es nulo o vacío");
    //   change(null, status: RxStatus.error("ID no válido"));
    //   return;
    // }

    await getDetailsFolio(folioIdArgnt);
  }

  @override
  void onReady() {
    super.onReady();
  }

  Future<void> getDetailsFolio(String idBuscado) async {
    change(null, status: RxStatus.loading());
    try {
      final ResultSet resultSet = await AppDatabase.db.execute(folioId(), [
        idBuscado,
      ]);
      if (resultSet.isEmpty) {
        change(null, status: RxStatus.empty());
        return;
      }
      final folio = Folios.fromJson(resultSet.first);

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
    } catch (e) {
      print("Error al obtener el último status: $e");
      return null;
    }
  }

  Future<void> historialFolio(String folioId) async {
    try {
      historialList.clear();

      final ResultSet resultSet = await AppDatabase.db.getAll(
        getHistorialFolio(),
        [folioId],
      );

      List<Folios> folio = resultSet
          .map(
            (element) =>
                Folios.fromJson(Map<String, dynamic>.from(element as Map)),
          )
          .toList();

      historialList.value = folio;
      print("FolioId: ${folioId}");
      print("Folio Historial: ${jsonEncode(historialList)}");
    } catch (e) {
      print("Error: $e");
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

      final imageUrl = Supabase.instance.client.storage
          .from('firmas')
          .getPublicUrl(filePath);

      debugPrint('URL pública de la firma: $imageUrl');

      // final targetId = state?.id?.toString() ?? id;
      // debugPrint('Intentando actualizar el registro con ID: $targetId');

      // if (targetId.isEmpty) {
      //   debugPrint(
      //     '❌ Error: El ID está vacío, no se puede actualizar Supabase.',
      //   );
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Error: ID de folio no válido')),
      //   );
      //   return;
      // }

      // final response = await Supabase.instance.client
      //     .from('folios')
      //     .update({'url_firma': imageUrl})
      //     .eq('id', targetId.trim())
      //     .select();

      // debugPrint('✅ Respuesta de Supabase al actualizar: $response');

      // if (response == null || (response is List && response.isEmpty)) {
      //   throw 'No se pudo actualizar el registro. Revisa si el ID existe o si las políticas RLS están bloqueando la actualización.';
      // }

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
