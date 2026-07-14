
import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/querys/detallesFolio.dart';
import 'package:get/get.dart';
import 'package:powersync/sqlite3.dart';

class DetallesFolioController extends GetxController with StateMixin<Folios> {
  //TODO: Implement DetallesFolioController

  @override
  void onInit() {
    super.onInit();
    _onInit();
  }

  Future<void> _onInit() async {
    final String id = Get.arguments as String;
    await getDetailsFolio(id);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
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
      change(folio, status: RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }
}
