import 'dart:async';
import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/datosPersonales.dart';
import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoliosController extends GetxController with StateMixin<List<Folios>> {
  RxInt rolUsuario = 0.obs;
  DateTime? selectedDate;
  var rolName = "Cargando...".obs;
  var nameUser = "Cargando...".obs;
  final RxString fechaSeleccionada = "".obs;

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
    selectedDate ??= DateTime.now();
    await getDatos();
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

      final String fechaHoy = (selectedDate ?? DateTime.now())
          .toIso8601String()
          .split('T')[0];

      print(
        "Consultando folios en Supabase para la fecha: $fechaHoy con rol: ${rolUsuario.value}",
      );

      final response = await Supabase.instance.client
          .from('folios')
          .select('''
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
    ''')
          .eq('created_at', fechaHoy)
          .order(
            'created_at',
            ascending: true,
            referencedTable: 'historialestados',
          );

      List<Folios> listFolios = (response as List).map((element) {
        return Folios.fromJson(Map<String, dynamic>.from(element));
      }).toList();

      if (listFolios.isEmpty) {
        change(listFolios, status: RxStatus.empty());
      } else {
        print("listFolios con datos: ${jsonEncode(listFolios)}");
        change(listFolios, status: RxStatus.success());
      }
    } catch (e) {
      print("Error al cargar folios: $e");
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      fechaSeleccionada.value = picked.toIso8601String().split('T')[0];
      await getFoliosWithDate();
    }
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      await Get.deleteAll(force: true);
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      debugPrint("Error al cerrar sesión: $e");
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<Map<String, dynamic>?> getDatos() async {
    change(null, status: RxStatus.loading());
    try {
      final miId = Supabase.instance.client.auth.currentUser?.id;
      if (miId == null) return null;

      final resultado = await Supabase.instance.client
          .from('datosPersonales')
          .select('*, roles:rolId(name)')
          .eq('userId', miId)
          .maybeSingle();

      if (resultado != null) {
        final rolData = resultado['roles'];
        if (rolData != null && rolData is Map) {
          rolName.value = rolData['name']?.toString() ?? "Sin rol";
        }

        nameUser.value = resultado["nombre"]?.toString() ?? "Sin nombre";
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

  Future<void> archivarFolio(String folioId) async {
    try {
      await Supabase.instance.client
          .from('folios')
          .update({'isArchived': true})
          .eq('folioId', folioId);

      await getFoliosWithDate();
    } catch (e) {
      print("Error al archivar folio: $e");
    }
  }

  Future<void> eliminarFolio(String folioId) async {
    try {
      await Supabase.instance.client
          .from('folios')
          .delete()
          .eq('folioId', folioId);

      await getFoliosWithDate();
    } catch (e) {
      print("Error al eliminar folio en Supabase: ${e.toString()}");
    }
  }

  // Función auxiliar para parsear colores de manera segura
  Color parseColor(String? colorStr, {Color defaultColor = Colors.grey}) {
    if (colorStr == null || colorStr.isEmpty || colorStr == 'null') {
      return defaultColor;
    }
    String cleanColor = colorStr
        .toUpperCase()
        .replaceAll('0X', '')
        .replaceAll('#', '');
    int? colorInt = int.tryParse(cleanColor, radix: 16);
    return colorInt != null ? Color(colorInt | 0xFF000000) : defaultColor;
  }

Future<void> fetchData() async {
  final connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    print("No hay internet");
    return;
  }
}

  void increment() => count.value++;
}
