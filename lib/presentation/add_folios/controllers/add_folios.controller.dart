import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/clientes.dart';
import 'package:bitacora_frontend/infrastructure/models/refacciones.dart';
import 'package:bitacora_frontend/infrastructure/models/users.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddFoliosController extends GetxController with StateMixin {
  RxInt clienteId = 0.obs;
  RxInt refaccionId = 0.obs;
  RxInt condicionPagoId = 0.obs;
  RxInt repartidorId = 0.obs;
  RxInt tipoDocumentoId = 0.obs;
  final RxString fechaSeleccionada = "".obs;

  //Controllers
  TextEditingController cantidadController = TextEditingController();
  TextEditingController numReporteController = TextEditingController();

  final RxList<Clientes> _clientesModel = <Clientes>[].obs;
  RxList<Clientes> get clientesModel => this._clientesModel;
  set clientesModel(RxList<Clientes> value) =>
      this._clientesModel.value = value;

  final RxList<GeneralModel> _condicionPago = <GeneralModel>[].obs;
  RxList<GeneralModel> get condicionPago => this._condicionPago;
  set condicionPago(RxList<GeneralModel> value) =>
      this._condicionPago.value = value;

  final RxList<GeneralModel> _refacciones = <GeneralModel>[].obs;
  RxList<GeneralModel> get refacciones => this._refacciones;
  set refacciones(RxList<GeneralModel> value) =>
      this._refacciones.value = value;

  final RxList<Users> _reparto = <Users>[].obs;
  RxList<Users> get reparto => this._reparto;
  set reparto(RxList<Users> value) => this._reparto.value = value;

  final RxList<GeneralModel> _tipoDocumento = <GeneralModel>[].obs;
  RxList<GeneralModel> get tipoDocumento => this._tipoDocumento;
  set tipoDocumento(RxList<GeneralModel> value) =>
      this._tipoDocumento.value = value;

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    onInitFunction();
  }

  Future<void> onInitFunction() async {
    change(null, status: RxStatus.loading());
    final arguments = Get.arguments;

    if (arguments is Map) {
      final fecha = arguments['fecha'];

      if (fecha != null) {
        fechaSeleccionada.value = fecha.toString();
      }
    }

    await getClientes();
    await getRefaccion();
    await getCondicionPago();
    await getUsersReparto();
    await getTipoDocumento();

    change(null, status: RxStatus.success());
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getClientes() async {
    final response = await Supabase.instance.client.from('clientes').select();
    List<Clientes> listaProcesada = (response as List).map((row) {
      return Clientes.fromJson(Map<String, dynamic>.from(row));
    }).toList();

    final defaultItem = Clientes(
      id: 0,
      nombreComercial: "Seleccione un Cliente",
    );
    listaProcesada.insert(0, defaultItem);
    clientesModel.assignAll(listaProcesada);
  }

  Future<void> getTipoDocumento() async {
    final response = await Supabase.instance.client
        .from('tipos')
        .select()
        .inFilter('id', [1, 2]);

    List<GeneralModel> tipoDocumentoList = (response as List).map((row) {
      return GeneralModel.fromJson(Map<String, dynamic>.from(row));
    }).toList();

    final defaultItem = GeneralModel(
      id: 0,
      nombre: "Seleccione tipo de documento",
    );
    tipoDocumentoList.insert(0, defaultItem);
    tipoDocumento.assignAll(tipoDocumentoList);
  }

  Future<void> getRefaccion() async {
    final response = await Supabase.instance.client
        .from('tipos')
        .select()
        .not('id', 'in', '(1, 2)');

    List<GeneralModel> refaccionesList = (response as List).map((row) {
      return GeneralModel.fromJson(Map<String, dynamic>.from(row));
    }).toList();

    final defaultItem = GeneralModel(id: 0, nombre: "Seleccione una refacción");
    refaccionesList.insert(0, defaultItem);
    refacciones.assignAll(refaccionesList);
  }

  Future<void> getCondicionPago() async {
    final response = await Supabase.instance.client
        .from('condicionPago')
        .select();
    List<GeneralModel> condicionDePagoList = (response as List).map((row) {
      return GeneralModel.fromJson(Map<String, dynamic>.from(row));
    }).toList();

    final defaultItem = GeneralModel(
      id: 0,
      nombre: "Seleccione una condición de pago",
    );
    condicionDePagoList.insert(0, defaultItem);
    condicionPago.assignAll(condicionDePagoList);
  }

  Future<void> getUsersReparto() async {
    final response = await Supabase.instance.client
        .from('datosPersonales')
        .select()
        .eq('rolId', 2);

    List<Users> usersList = (response as List).map((row) {
      return Users.fromJson(Map<String, dynamic>.from(row));
    }).toList();
    usersList.add(Users(id: 0, nombre: "Seleccionar repartidor..."));
    reparto.assignAll(usersList);
  }

  Future<Map<String, dynamic>?> postFolio() async {
    try {
      final supabase = Supabase.instance.client;

      final String? userId =
          supabase.auth.currentUser?.id ??
          supabase.auth.currentSession?.user.id;

      if (userId == null) {
        Get.snackbar("Error", "La sesión no está activa.");
        return null;
      }

      final String uuidUnico = const Uuid().v4();
      final String fechaActual = DateTime.now().toIso8601String();

      final int cantidad = int.tryParse(cantidadController.text) ?? 0;

      final int tipoDoc = tipoDocumentoId.value;
      final int cliente = clienteId.value;
      final int refaccion = refaccionId.value;
      final int condicion = condicionPagoId.value;

      if (cliente == 0 || tipoDoc == 0) {
        Get.snackbar("Error", "Debes seleccionar valores válidos.");
        return null;
      }

      String? repartidorUuid;

      if (reparto.isNotEmpty && repartidorId.value != 0) {
        final u = reparto.firstWhere(
          (u) => u.id == repartidorId.value,
          orElse: () => Users(userId: null),
        );

        repartidorUuid = u.userId;
      }

      final Map<String, dynamic> datosFolio = {
        'id': uuidUnico,
        'tipoFolioId': tipoDoc,
        'clienteId': cliente,
        'typeRefaccionId': refaccion,
        'cantidad': cantidad,
        'condicionDePagoId': condicion,
        'repartidorId': repartidorUuid,
        'creadorId': userId,
        'created_at': fechaSeleccionada.value,
        'folioId': numReporteController.text,
        'isArchived': false,
      };

      final folioResponse = await supabase
          .from('folios')
          .insert(datosFolio)
          .select()
          .single();

      final Map<String, dynamic> datosHistorial = {
        'id': const Uuid().v4(),

        'folioId': uuidUnico,

        'statusId': 1,

        'created_at': fechaSeleccionada.value,
      };

      print('');
      print('==========================================');
      print('🟡 CREANDO HISTORIAL');
      print('==========================================');
      print('🆔 ID HISTORIAL: ${datosHistorial['id']}');
      print('🔗 FOLIO ID: ${datosHistorial['folioId']}');
      print('📊 STATUS ID: ${datosHistorial['statusId']}');
      print('📅 FECHA: ${datosHistorial['created_at']}');
      print('📦 Datos historial: $datosHistorial');

      // ============================================================
      // 8. INSERTAR HISTORIAL
      // ============================================================
      final historialResponse = await supabase
          .from('historialestados')
          .insert(datosHistorial)
          .select()
          .single();

      print('');
      print('==========================================');
      print('✅ HISTORIAL CREADO CORRECTAMENTE');
      print('==========================================');
      print('📚 Respuesta: $historialResponse');

      // ============================================================
      // 9. LIMPIAR FORMULARIO
      // ============================================================
      cantidadController.clear();
      numReporteController.clear();

      clienteId.value = 0;
      refaccionId.value = 0;
      condicionPagoId.value = 0;
      repartidorId.value = 2;
      tipoDocumentoId.value = 0;

      // ============================================================
      // 10. NOTIFICACIÓN
      // ============================================================
      Get.snackbar(
        "Guardado",
        "Registro exitoso.",
        snackPosition: SnackPosition.BOTTOM,
      );

      // ============================================================
      // 11. REGRESAR A FOLIOS
      // ============================================================
      Get.offAllNamed(Routes.FOLIOS);

      // ============================================================
      // 12. RETORNAR INFORMACIÓN
      // ============================================================
      return {'folio': folioResponse, 'historial': historialResponse};
    } catch (e, stackTrace) {
      print('');
      print('==========================================');
      print('❌ ERROR AL CREAR FOLIO');
      print('==========================================');
      print('ERROR: $e');
      print('');
      print('STACKTRACE:');
      print(stackTrace);
      print('==========================================');

      Get.snackbar(
        "Error",
        "No se pudo guardar: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );

      return null;
    }
  }

  void increment() => count.value++;
}
