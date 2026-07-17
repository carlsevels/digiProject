import 'dart:async';
import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/datosPersonales.dart';
import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/folios/querys/datosPersonales.query.dart';
import 'package:bitacora_frontend/presentation/folios/querys/listFolios.dart';
import 'package:get/get.dart';
import 'package:powersync/sqlite3.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoliosController extends GetxController with StateMixin<List<Folios>> {
  //TODO: Implement FoliosController

  final Rx<DatosPersonales> _datosPersonales = DatosPersonales().obs;
  DatosPersonales get datosPersonales => this._datosPersonales.value;
  set datosPersonales(value) => this._datosPersonales.value = value;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    _onInit();
  }

  Future<void> _onInit() async {
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

    final miId = Supabase.instance.client.auth.currentUser?.id;

    final ResultSet resultSet = await AppDatabase.db.execute(
      datosPersonalesQuery(),
      [miId],
    );

    final datosPersonalesData = resultSet.first;
    final int rolUsuario = datosPersonalesData['rolId'] as int;
    final getFolios = await AppDatabase.db.getAll(listFoliosQuery(), [
      rolUsuario,
      rolUsuario,
    ]);

    List<Folios> listFolios = getFolios
        .map(
          (element) =>
              Folios.fromJson(Map<String, dynamic>.from(element as Map)),
        )
        .toList();

    if (listFolios.isEmpty) {
      change(listFolios, status: RxStatus.empty());
    } else {
      print("listFolios: ${jsonEncode(listFolios)}");
      change(listFolios, status: RxStatus.success());
    }
  }

  void increment() => count.value++;
}
