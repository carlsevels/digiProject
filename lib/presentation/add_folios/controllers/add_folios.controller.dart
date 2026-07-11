import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/clientes.dart';
import 'package:bitacora_frontend/infrastructure/models/refacciones.dart';
import 'package:bitacora_frontend/infrastructure/models/users.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddFoliosController extends GetxController with StateMixin {
  //TODO: Implement AddFoliosController
  RxInt clienteId = 0.obs;
  RxInt refaccionId = 0.obs;
  RxInt condicionPagoId = 0.obs;
  RxInt repartidorId = 2.obs;
  RxInt tipoDocumentoId = 0.obs;

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
    _onInit();
  }

  Future<void> _onInit() async {
    change(null, status: RxStatus.loading());
    await getClientes();
    await getRefaccion();
    await getCondicionPago();
    await getUsersReparto();
    await getTipoDocumento();
    print("DEBUG: refacciones cargadas: ${refacciones.length}");
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
    final result = await AppDatabase.db.getAll("SELECT * FROM clientes;");
    List<Clientes> listaProcesada = result.map((row) {
      return Clientes.fromJson(Map<String, dynamic>.from(row as Map));
    }).toList();
    final defaultItem = Clientes(
      id: 0,
      nombreComercial: "Seleccione un Cliente",
    );
    listaProcesada.insert(0, defaultItem);
    clientesModel.assignAll(listaProcesada);
    clientesModel.value = listaProcesada;
  }

  Future<void> getTipoDocumento() async {
    final result = await AppDatabase.db.getAll(
      "SELECT * FROM tipos WHERE id IN (1, 2);",
    );
    List<GeneralModel> tipoDocumentoList = result.map((row) {
      return GeneralModel.fromJson(Map<String, dynamic>.from(row as Map));
    }).toList();
    final defaultItem = GeneralModel(id: 0, nombre: "Seleccione una refacción");
    tipoDocumentoList.insert(0, defaultItem);
    tipoDocumento.assignAll(tipoDocumentoList);
    tipoDocumento.value = tipoDocumentoList;
  }

  Future<void> getRefaccion() async {
    final result = await AppDatabase.db.getAll(
      "SELECT * FROM tipos WHERE id not in (1, 2);",
    );
    List<GeneralModel> refaccionesList = result.map((row) {
      return GeneralModel.fromJson(Map<String, dynamic>.from(row as Map));
    }).toList();
    final defaultItem = GeneralModel(id: 0, nombre: "Seleccione una refacción");
    refaccionesList.insert(0, defaultItem);
    refacciones.assignAll(refaccionesList);
    refacciones.value = refaccionesList;
  }

  Future<void> getCondicionPago() async {
    final result = await AppDatabase.db.getAll("SELECT * FROM condicionPago;");
    List<GeneralModel> condicionDePagoList = result.map((row) {
      return GeneralModel.fromJson(Map<String, dynamic>.from(row as Map));
    }).toList();
    final defaultItem = GeneralModel(id: 0, nombre: "Seleccione una refacción");
    condicionDePagoList.insert(0, defaultItem);
    condicionPago.assignAll(condicionDePagoList);
    condicionPago.value = condicionDePagoList;
  }

  Future<void> getUsersReparto() async {
    final result = await AppDatabase.db.getAll(
      '''SELECT * FROM "datosPersonales" WHERE "rolId" = 2;''',
    );
    List<Users> usersList = result.map((row) {
      return Users.fromJson(Map<String, dynamic>.from(row as Map));
    }).toList();

    reparto.assignAll(usersList);
    await AppDatabase.db.execute(
      "DELETE FROM folios WHERE repartidorId IS NULL OR repartidorId = 'null' OR repartidorId = '0';",
    );
    reparto.value = usersList;
  }

  Future<Map<String, dynamic>?> postFolio() async {
    try {
      // 1. Validar autenticación
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print("Error: Usuario no autenticado");
        return null;
      }

      final String idParaPowerSync = const Uuid().v4();
      final String miId = user.id;

      if (clienteId.value == 0 || tipoDocumentoId.value == 0) {
        print("Error: Debes seleccionar valores válidos");
        return null;
      }
      // 1. Obtén el UUID del repartidor de forma segura
      String? repartidorUuid;
      if (reparto.isNotEmpty && repartidorId.value != 0) {
        final user = reparto.firstWhere(
          (u) => u.id == repartidorId.value,
          orElse: () => Users(userId: null),
        );
        repartidorUuid = user.userId;
      }

      List<Object?> datosEnviados = [
        idParaPowerSync,
        numReporteController.text,
        tipoDocumentoId.value,
        clienteId.value,
        refaccionId.value,
        int.tryParse(cantidadController.text) ?? 0,
        condicionPagoId.value,
        repartidorUuid,
        miId,
        1,
        DateTime.now().toIso8601String(),
      ];

      // 3. Ejecuta
      await AppDatabase.db.execute('''
  INSERT INTO folios (id, "folioId", "tipoFolioId", "clienteId", "typeRefaccionId", cantidad, "condicionDePagoId", "repartidorId", "creadorId", "statusId", created_at) 
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
''', datosEnviados);
      print("datosEnviados: ${datosEnviados}");
      print("Folio creado con éxito: $idParaPowerSync");
    } catch (e) {
      print("Error al crear: $e");
    }
  }

  void increment() => count.value++;
}
