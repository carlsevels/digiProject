import 'package:bitacora_frontend/infrastructure/models/barcode.dart';
import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/detallesFolio.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/update.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SearchFolioController extends GetxController with StateMixin<Folios> {
  //TODO: Implement SearchFolioController
  RxInt currentStep = 0.obs;
  RxInt statusId = 0.obs;

  RxString idPrincipal = "".obs;

  RxBool isProcessingBarcode = false.obs;

  TextEditingController id = TextEditingController();

  final Rx<BarcodeResponse> _codeBar = BarcodeResponse().obs;
  BarcodeResponse get codeBar => this._codeBar.value;
  set codeBar(value) => this._codeBar.value = value;

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

  Future<void> onInitDetalles() async {
    if (id.text.isEmpty) {
      print("Error: El ID recibido es nulo o vacío");
      change(null, status: RxStatus.error("ID no válido"));
      return;
    }
    print("FolioId: $id");
    

    await getDetailsFolio(id.text);
  }

  Future<void> getDetailsFolio(String idBuscado) async {
    change(null, status: RxStatus.loading());
    try {
      Folios? folio;

      if (kIsWeb) {
        final response = await Supabase.instance.client.rpc(
          'buscar_folios_web',
          params: {'busqueda': idBuscado},
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

        // Limpiamos el color por si viene como String
        if (itemMap.containsKey('statuscolor')) {
          itemMap['statuscolor'] = itemMap['statuscolor']?.toString();
        }

        folio = Folios.fromJson(itemMap);
      } else {
        final resultSet = await AppDatabase.db.execute(folioId(), [
          '%$idBuscado%',
        ]);
        if (resultSet.isEmpty) {
          change(null, status: RxStatus.empty());
          return;
        }
        folio = Folios.fromJson(resultSet.first);
      }

      final ultimoRegistro = await getUltimoStatus(
        folio.folioIdHistorial ?? "",
      );

      if (ultimoRegistro != null) {
        statusId.value =
            int.tryParse(ultimoRegistro["statusId"].toString()) ?? 0;
        currentStep.value = getStepIndex(statusId.value);
      } else {
        print("ADVERTENCIA: No se encontró historial para: ${folio.folioId}");
      }

      change(folio, status: RxStatus.success());
    } catch (e) {
      print("Error en búsqueda: $e");
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

  Color parseColor(String? colorStr, {Color defaultColor = Colors.grey}) {
    if (colorStr == null || colorStr.isEmpty) return defaultColor;

    String cleanColor = colorStr.toUpperCase().replaceAll('0X', '');

    int? colorInt = int.tryParse(cleanColor, radix: 16);

    return colorInt != null ? Color(colorInt | 0xFF000000) : defaultColor;
  }

  Future<void> pedidoPendiente(String folioId) async {
    if (kIsWeb) {
      await Supabase.instance.client.from('historialestados').insert({
        'id': const Uuid().v4(),
        'folioId': folioId,
        'statusId': 4,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      await AppDatabase.db.execute(insertStatusFolio(), [
        const Uuid().v4(),
        folioId,
        4,
        DateTime.now().toIso8601String(),
      ]);
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

  Future<void> navigateToScanner(Widget scanner, context) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => scanner));
  }

  void increment() => count.value++;
}
