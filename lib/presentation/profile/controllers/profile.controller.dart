import 'dart:async';

import 'package:bitacora_frontend/infrastructure/storage/user.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController with StateMixin {
  var nombreGuardado = "Cargando...".obs;
  StreamSubscription? _subscription;

  var subiendo = false.obs;
  var bajando = false.obs;

  var pendientesDeSubir = <String>[].obs;

  @override
  void onInit() {
    _iniciarFlujoDatos();
    change(null, status: RxStatus.success());
    super.onInit();
  }

  Future<void> _iniciarFlujoDatos() async {
    final local = await UserStorage.obtenerNombre();
    nombreGuardado.value = local ?? "Sin nombre";

    try {
      final miId = Supabase.instance.client.auth.currentUser?.id;
      if (miId == null) return;

      _subscription = Supabase.instance.client
          .from('datosPersonales')
          .stream(primaryKey: ['id'])
          .map(
            (list) => list.firstWhereOrNull((item) => item['userId'] == miId),
          )
          .listen((data) {
            if (data != null && data['nombre'] != null) {
              nombreGuardado.value = data['nombre'];
              UserStorage.guardarNombre(data['nombre']);
            }
          });
    } catch (e) {
      print("Error al conectar: $e");
    }
  }

  Future<void> cargarNombreLocal() async {
    String? nombreLocal = await UserStorage.obtenerNombre();

    if (nombreLocal != null) {
      nombreGuardado.value = nombreLocal;
      print("controller.nombreGuardado.value: ${nombreGuardado.value}");
    }
  }

  @override
  void onClose() {
    _subscription?.cancel(); // Limpieza importante
    super.onClose();
  }
}
