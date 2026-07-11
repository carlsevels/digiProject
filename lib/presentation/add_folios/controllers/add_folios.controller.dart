import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddFoliosController extends GetxController {
  //TODO: Implement AddFoliosController
  RxList<String> list = <String>["Seleccionar", 'Folio', 'Factura'].obs;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<Map<String, dynamic>?> postFolio() async {
    try {
      final status = AppDatabase.db.currentStatus;
      final String idParaPowerSync = const Uuid().v4();
      print("¿Ha terminado la sincronización inicial?: ${status.hasSynced}");

      if (status.hasSynced != true) {
        print("Esperando a que PowerSync sincronice...");
        await AppDatabase.db.statusStream.firstWhere(
          (s) => s.hasSynced == true,
        );
        print("¡Sincronización completada!");
      }

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
