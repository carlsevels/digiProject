import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/folios/querys/listFolios.dart';
import 'package:get/get.dart';

class FoliosController extends GetxController with StateMixin<List<Folios>> {
  //TODO: Implement FoliosController

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

    final getFolios = await AppDatabase.db.getAll(listFoliosQuery(), []);
    List<Folios> listFolios = getFolios
        .map(
          (element) =>
              Folios.fromJson(Map<String, dynamic>.from(element as Map)),
        )
        .toList();
    if (listFolios.isEmpty) {
      change(listFolios, status: RxStatus.empty());
    } else {
      change(listFolios, status: RxStatus.success());
    }
  }

  void increment() => count.value++;
}
