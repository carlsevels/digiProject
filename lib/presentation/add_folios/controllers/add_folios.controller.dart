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
  final RxBool isLoading = false.obs;

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
    // Evitar ejecuciones simultáneas si ya se está enviando un formulario
    if (isLoading.value) return null;

    try {
      final supabase = Supabase.instance.client;

      final String? userId =
          supabase.auth.currentUser?.id ??
          supabase.auth.currentSession?.user.id;

      if (userId == null) {
        Get.snackbar("Error", "La sesión no está activa.");
        return null;
      }

      // ============================================================
      // 1. OBTENCIÓN Y LIMPIEZA DE DATOS
      // ============================================================
      final String numReporte = numReporteController.text.trim();
      final String cantidadText = cantidadController.text.trim();
      final int cantidad = int.tryParse(cantidadText) ?? 0;

      final int tipoDoc = tipoDocumentoId.value;
      final int cliente = clienteId.value;
      final int refaccion = refaccionId.value;
      final int condicion = condicionPagoId.value;

      // ============================================================
      // 2. VALIDACIONES ESTRICTAS (ANTES DE CUALQUIER OPERACIÓN)
      // ============================================================

      // Validar Número de Reporte / Folio
      if (numReporte.isEmpty) {
        Get.snackbar(
          "Campo Requerido",
          "Por favor ingresa el número de reporte/folio.",
        );
        return null; // SE DETIENE AQUÍ: NADA LLEGA A SUPABASE
      }

      // Validar Cliente
      if (cliente == 0) {
        Get.snackbar("Campo Requerido", "Debes seleccionar un cliente.");
        return null; // SE DETIENE AQUÍ
      }

      // Validar Tipo de Documento
      if (tipoDoc == 0) {
        Get.snackbar(
          "Campo Requerido",
          "Debes seleccionar un tipo de documento.",
        );
        return null; // SE DETIENE AQUÍ
      }

      // Validar Cantidad
      if (cantidadText.isEmpty || cantidad <= 0) {
        Get.snackbar("Campo Requerido", "Debes ingresar una cantidad válida.");
        return null; // SE DETIENE AQUÍ
      }

      // Validar Condición de Pago
      if (condicion == 0) {
        Get.snackbar(
          "Campo Requerido",
          "Debes seleccionar una condición de pago.",
        );
        return null; // SE DETIENE AQUÍ
      }

      // Validar Refacción
      if (refaccion == 0) {
        Get.snackbar(
          "Campo Requerido",
          "Debes seleccionar un tipo de refacción.",
        );
        return null; // SE DETIENE AQUÍ
      }

      // Activar loader para bloquear nuevos clics
      isLoading.value = true;

      // ============================================================
      // 3. VERIFICAR DUPLICADOS EN BASE DE DATOS
      // ============================================================
      final existingFolio = await supabase
          .from('folios')
          .select('id')
          .eq('folioId', numReporte)
          .maybeSingle();

      if (existingFolio != null) {
        Get.snackbar(
          "Aviso",
          "El número de folio '$numReporte' ya está registrado.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return null;
      }

      // ============================================================
      // 4. PREPARACIÓN DE DATOS E INSERCIÓN DE FOLIO
      // ============================================================
      final String uuidUnico = const Uuid().v4();
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
        'folioId': numReporte,
        'isArchived': false,
      };

      final folioResponse = await supabase
          .from('folios')
          .insert(datosFolio)
          .select()
          .single();

      // ============================================================
      // 5. INSERCIÓN EN HISTORIAL
      // ============================================================
      final Map<String, dynamic> datosHistorial = {
        'id': const Uuid().v4(),
        'folioId': uuidUnico,
        'statusId': 1,
        'created_at': fechaSeleccionada.value,
      };

      final historialResponse = await supabase
          .from('historialestados')
          .insert(datosHistorial)
          .select()
          .single();

      // ============================================================
      // 6. LIMPIAR FORMULARIO
      // ============================================================
      cantidadController.clear();
      numReporteController.clear();

      clienteId.value = 0;
      refaccionId.value = 0;
      condicionPagoId.value = 0;
      repartidorId.value = 2;
      tipoDocumentoId.value = 0;

      // ============================================================
      // 7. NOTIFICAR Y REDIRIGIR
      // ============================================================
      Get.snackbar(
        "Guardado",
        "Registro exitoso.",
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed(Routes.FOLIOS);

      return {'folio': folioResponse, 'historial': historialResponse};
    } catch (e, stackTrace) {
      print('==========================================');
      print('❌ ERROR AL CREAR FOLIO: $e');
      print('STACKTRACE:\n$stackTrace');
      print('==========================================');

      Get.snackbar(
        "Error",
        "No se pudo guardar: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );

      return null;
    } finally {
      // Asegura que siempre libere el indicador de carga, incluso si falla
      isLoading.value = false;
    }
  }

  void increment() => count.value++;
}
