import 'package:bitacora_frontend/infrastructure/models/clientes.dart';
import 'package:bitacora_frontend/infrastructure/models/refacciones.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class AddFoliosController extends GetxController with StateMixin {
  //TODO: Implement AddFoliosController
  RxInt clienteId = 0.obs;
  RxInt refaccionId = 0.obs;
  RxInt condicionPagoId = 0.obs;

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

  Future<Map<String, dynamic>?> postFolio() async {
    try {
      final String idParaPowerSync = const Uuid().v4();

      await AppDatabase.db.execute(
        '''
 INSERT INTO folios (id, "folioId", "tipoFolioId", "clienteId", "typeRefaccionId", cantidad, "condicionDePagoId", "repartidorId", "creadorId", "statusId", created_at) 
 values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''',
        [
          idParaPowerSync,
          343,
          1,
          1,
          1,
          2,
          1,
          '0a505f2f-df52-47a8-b288-e4eb0408b74b',
          '0a505f2f-df52-47a8-b288-e4eb0408b74b',
          1,
          '2026-07-10T22:02:10Z',
        ],
      );
    } catch (e) {
      print("Error al crear: $e");
    }
  }

  void increment() => count.value++;
}
