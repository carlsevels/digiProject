import 'package:bitacora_frontend/infrastructure/models/refacciones.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RefaccionesController extends GetxController
    with StateMixin<List<GeneralModel>> {
  final TextEditingController nombreController = TextEditingController();
  RxInt rolUsuario = 0.obs;
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _onInit();
  }

  Future<void> _onInit() async {
    final miId = Supabase.instance.client.auth.currentUser?.id;
    if (miId == null) {
      change(null, status: RxStatus.error("Usuario no autenticado"));
      return;
    }

    // Consulta directa a Supabase para obtener el rol del usuario
    final datosRes = await Supabase.instance.client
        .from('datosPersonales')
        .select('rolId')
        .eq('userId', miId)
        .maybeSingle();

    if (datosRes == null) {
      change(null, status: RxStatus.empty());
      return;
    }

    rolUsuario.value = datosRes['rolId'] as int;
    await getRefacciones();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getRefacciones() async {
    change(null, status: RxStatus.loading());

    try {
      final searchText = nombreController.text.trim();

      // Consulta directa a Supabase para la tabla 'tipos' (refacciones)
      var query = Supabase.instance.client.from('tipos').select();

      if (searchText.isNotEmpty) {
        query = query.ilike('nombre', '%$searchText%');
      }

      final response = await query;

      List<GeneralModel> listFolios = (response as List)
          .map(
            (element) => GeneralModel.fromJson(
              Map<String, dynamic>.from(element),
            ),
          )
          .toList();

      if (listFolios.isEmpty) {
        change(listFolios, status: RxStatus.empty());
      } else {
        change(listFolios, status: RxStatus.success());
      }
    } catch (e) {
      print("Error al cargar refacciones: $e");
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<void> eliminarRefaccion(String refaccionId) async {
    try {
      // Eliminación directa en Supabase
      await Supabase.instance.client
          .from('tipos')
          .delete()
          .eq('id', refaccionId);

      await getRefacciones();
    } catch (e) {
      print("Error al eliminar refacción en Supabase: ${e.toString()}");
    }
  }

  void increment() => count.value++;
}