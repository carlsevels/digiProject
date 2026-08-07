import 'dart:async';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db_web.dart'; // O tu archivo de base de datos
import 'package:flutter/foundation.dart'; // Necesario para kIsWeb
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LayoutInternoController extends GetxController
    with StateMixin<Map<String, dynamic>> {
  RxInt rolUsuario = 1.obs;
  var rolName = "Cargando...".obs;
  var nameUser = "Cargando...".obs;
  var currentRoute = Get.currentRoute.obs;

  // Controla si el rail menu está visible
  RxBool isWebMenuVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
    ever(Get.routing.current.obs, (_) {
      update();
    });
    getDatos();
  }

  void toggleMenu() {
    isWebMenuVisible.value = !isWebMenuVisible.value;
    update();
  }

  void cambiarRuta(String route, int index) {
    if (Get.currentRoute != route) {
      if (index == 0) {
        Get.offAllNamed(route);
      } else {
        Get.toNamed(route);
      }

      update();
    }
  }

  Future<void> getDatos() async {
    change(null, status: RxStatus.loading());
    try {
      final miId = Supabase.instance.client.auth.currentUser?.id;
      Map<String, dynamic>? resultado;

      if (kIsWeb) {
        print("--- DIAGNÓSTICO TOTAL ---");

        // 1. Traemos SOLO los datos personales primero
        final response = await Supabase.instance.client
            .from('datosPersonales')
            .select('*')
            .eq('userId', miId!)
            .maybeSingle();

        if (response != null) {
          final dynamic rolIdVal = response['rolId'];
          print(
            "ID del rol del usuario en la BD: $rolIdVal (Tipo: ${rolIdVal.runtimeType})",
          );

          String rolNameVal = 'Sin rol';

          try {
            // 2. Traemos TODA la tabla de roles sin filtros para ver qué contiene
            final List<dynamic> allRoles = await Supabase.instance.client
                .from('roles')
                .select('*');

            print("Roles encontrados en Supabase: $allRoles");

            // 3. Comparación forzada a String
            for (var r in allRoles) {
              print(
                "Comparando rol ID: ${r['id']} contra usuario rolId: $rolIdVal",
              );
              if (r['id'].toString() == rolIdVal.toString()) {
                rolNameVal = r['name']?.toString() ?? 'Sin nombre en columna';
                break;
              }
            }
          } catch (e) {
            print("ERROR FATAL AL LEER ROLES: $e");
          }

          print("Nombre de rol final determinado: $rolNameVal");

          resultado = {...response, "nombre_rol": rolNameVal};
          rolName.value = rolNameVal;
          nameUser.value = response['nombre']?.toString() ?? "Usuario";
          rolUsuario.value = (rolIdVal is int)
              ? rolIdVal
              : int.tryParse(rolIdVal.toString()) ?? 1;

          change(resultado, status: RxStatus.success());
        }
      } else {
        final status = AppDatabase.db.currentStatus;
        if (status.hasSynced != true) {
          await AppDatabase.db.statusStream.firstWhere(
            (s) => s.hasSynced == true,
          );
        }

        resultado = await AppDatabase.db.getOptional(
          '''
          SELECT dp.*, r."name" as "nombre_rol" 
          FROM "datosPersonales" dp
          INNER JOIN "roles" r ON dp."rolId" = r."id"
          WHERE dp."userId" = ?
          ''',
          [miId],
        );
      }

      if (resultado != null) {
        rolName.value = resultado["nombre_rol"]?.toString() ?? "Sin rol";
        nameUser.value = resultado["nombre"]?.toString() ?? "Usuario";
        rolUsuario.value = (resultado["rolId"] ?? 1) as int;
        change(resultado, status: RxStatus.success());
      } else {
        change(null, status: RxStatus.success());
      }
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<void> signOutAllDevices() async {
    await Supabase.instance.client.auth.signOut(scope: SignOutScope.global);
    Get.toNamed(Routes.LOGIN);
  }
}
