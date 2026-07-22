import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/clientes.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/clientes/querys/listClientes.dart';
import 'package:get/get.dart';
import 'package:powersync/sqlite3.dart';

class ClientesController extends GetxController
    with StateMixin<List<Clientes>> {
  //TODO: Implement ClientesController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    _onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> _onInit() async {
    getClientes();
  }

  Future<void> getClientes() async {
    change(null, status: RxStatus.loading());
    try {
      final ResultSet resultSet = await AppDatabase.db.execute(
        listClientesQuery(),
      );

      if (resultSet.isNotEmpty) {
        print("Columnas encontradas: ${resultSet.first.keys}");
        print(
          "Valor de 'nombreMunicipio' en crudo: ${resultSet.first['municipio']}",
        );
      }

      final dirCount = await AppDatabase.db.execute(
        'SELECT COUNT(*) as total FROM direcciones',
      );
      final munCount = await AppDatabase.db.execute(
        'SELECT COUNT(*) as total FROM municipios',
      );

      print("DEBUG: Filas en direcciones: ${dirCount.first['total']}");
      print("DEBUG: Filas en municipios: ${munCount.first['total']}");

      List<Clientes> listClientes = resultSet.map((element) {
        final map = Map<String, dynamic>.from(element as Map);
        return Clientes.fromJson(map);
      }).toList();

      if (listClientes.isEmpty) {
        change(listClientes, status: RxStatus.empty());
      } else {
        print("listClientes: ${jsonEncode(listClientes)}");
        change(listClientes, status: RxStatus.success());
      }
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  void increment() => count.value++;
}
