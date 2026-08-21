import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArchivadosController extends GetxController
    with StateMixin<List<Folios>> {
  //TODO: Implement ArchivadosController
  var isSearching = false.obs;
  TextEditingController id = TextEditingController();
  final count = 0.obs;

  RxInt rolUsuario = 0.obs;
  DateTime? selectedDate;
  var rolName = "Cargando...".obs;
  var nameUser = "Cargando...".obs;
  final RxString fechaSeleccionada = "".obs;

  @override
  void onInit() {
    super.onInit();
    _onInit();
  }

  Future<void> _onInit() async {
    selectedDate ??= DateTime.now();
    await getDatos();
    await getFoliosWithDate(id.text);
  }

  Future<void> getFoliosWithDate(String idBuscado) async {
    change(null, status: RxStatus.loading());

    try {
      final miId = Supabase.instance.client.auth.currentUser?.id;
      if (miId == null) {
        change(null, status: RxStatus.error("Usuario no autenticado"));
        return;
      }

      if (rolUsuario.value == 0) {
        final datosRes = await Supabase.instance.client
            .from('datosPersonales')
            .select('rolId')
            .eq('userId', miId)
            .maybeSingle();

        if (datosRes != null && datosRes['rolId'] != null) {
          rolUsuario.value = int.tryParse(datosRes['rolId'].toString()) ?? 0;
        }
      }

      print("Consultando todos los folios archivados en Supabase...");

      // 1. Consulta base con relaciones
      var query = Supabase.instance.client.from('folios').select('''
            *,
            clientes:clienteId (nombreComercial, razonSocial),
            condicionPago:condicionDePagoId (nombre),
            typeRefaccion:typeRefaccionId (nombre, color),
            tipoFolio:tipoFolioId (nombre, color),
            historialestados (
              id,
              statusId,
              created_at,
              status:statusId (nombre, color)
            )
          ''');

      var filteredQuery = query.eq('isArchived', true);

      if (idBuscado.trim().isNotEmpty) {
        filteredQuery = filteredQuery.ilike('folioId', '%$idBuscado%');
      }

      final response = await filteredQuery.order(
        'created_at',
        ascending: false,
      );

      List<Folios> listFolios = (response as List)
          .map((element) => Folios.fromJson(Map<String, dynamic>.from(element)))
          .toList();

      if (listFolios.isEmpty) {
        change(listFolios, status: RxStatus.empty());
      } else {
        print("listFolios Archivados encontrados: ${listFolios.length}");
        change(listFolios, status: RxStatus.success());
      }
    } catch (e) {
      print("Error al cargar folios archivados: $e");
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<Map<String, dynamic>?> getDatos() async {
    try {
      final miId = Supabase.instance.client.auth.currentUser?.id;
      if (miId == null) return null;

      // Consulta directa a Supabase con relación a la tabla roles
      final resultado = await Supabase.instance.client
          .from('datosPersonales')
          .select('*, roles:rolId(name)')
          .eq('userId', miId)
          .maybeSingle();

      if (resultado != null) {
        final rolData = resultado['roles'];
        if (rolData != null && rolData is Map) {
          rolName.value = rolData['name'] ?? "Sin rol";
        }

        nameUser.value = resultado["nombre"] ?? "Sin nombre";

        print("rolName: ${rolName.value}");
        print("nameUser: ${nameUser.value}");
      } else {
        change(null, status: RxStatus.empty());
      }
    } catch (e) {
      print("Error al obtener datos personales: $e");
      change(null, status: RxStatus.error(e.toString()));
    }
    return null;
  }

  String obtenerEtiquetaFecha(DateTime fechaSeleccionada) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final fecha = DateTime(
      fechaSeleccionada.year,
      fechaSeleccionada.month,
      fechaSeleccionada.day,
    );

    final int diferencia = hoy.difference(fecha).inDays;

    print("DEBUG: Hoy es $hoy, fecha recibida $fecha, diferencia: $diferencia");

    if (diferencia == 0) {
      return "Hoy";
    } else if (diferencia == 1) {
      return "Ayer";
    } else if (diferencia > 1 && diferencia <= 7) {
      return "Hace $diferencia días";
    } else {
      return DateFormat("d 'de' MMMM", 'es_ES').format(fechaSeleccionada);
    }
  }

  Future<void> archivarFolio(String idRegistro) async {
    try {
      await Supabase.instance.client
          .from('folios')
          .update({'isArchived': false})
          .eq('id', idRegistro);

      await getFoliosWithDate(id.text);
    } catch (e) {
      print("Error al desarchivar folio: $e");
    }
  }

  Future<void> eliminarFolio(String folioId) async {
    try {
      await Supabase.instance.client
          .from('folios')
          .delete()
          .eq('id', folioId);

      await getFoliosWithDate(id.text);
    } catch (e) {
      print("Error al eliminar folio en Supabase: ${e.toString()}");
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
