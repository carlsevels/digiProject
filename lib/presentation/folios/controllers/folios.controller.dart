import 'dart:async';
import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/datosPersonales.dart';
import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
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
    print('CONTROLLER FOLIOS: ${identityHashCode(this)}');
    _onInit();
  }

  Future<void> _onInit() async {
    selectedDate ??= DateTime.now();
    await getDatos();
    await getFoliosWithDate();
    if (fechaSeleccionada.value.isEmpty) {
      final now = DateTime.now();
      fechaSeleccionada.value = DateTime(
        now.year,
        now.month,
        now.day,
      ).toIso8601String().split('T')[0];
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

      final response = await Supabase.instance.client
          .from('folios')
          .select('''
  *,
  clientes:clienteId (
    nombreComercial,
    razonSocial,
    direcciones (
      calle,
      colonia,
      codigoPostal,
      numExt,
      numInt,
      municipio:municipioId (
        nombre
      )
    )
  ),
  condicionPago:condicionDePagoId (
    nombre
  ),
  typeRefaccion:typeRefaccionId (
    nombre,
    color
  ),
  tipoFolio:tipoFolioId (
    nombre,
    color
  ),
  historialestados (
    id,
    statusId,
    created_at,
    status:statusId (
      nombre,
      color
    )
  )
''')
          .eq('isArchived', false)
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

  Future<void> archivarFolio(String idRegistro, {String idBuscado = ""}) async {
    try {
      print("Intentando archivar el registro con ID interno: $idRegistro");

      // Cambiamos .eq('folioId', ...) por .eq('id', ...)
      final response = await Supabase.instance.client
          .from('folios')
          .update({'isArchived': true})
          .eq('id', idRegistro) // <- Usamos el UUID único del renglón
          .select();

      print("Respuesta de Supabase al archivar: $response");

      if (response != null && (response as List).isNotEmpty) {
        Get.snackbar(
          "Éxito",
          "Folio archivado correctamente",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print(
          "⚠️ Advertencia: Ningún registro fue actualizado. Revisa si el ID existe.",
        );
      }

      await getFoliosWithDate();
    } catch (e) {
      print("❌ Error al archivar folio: $e");
      Get.snackbar(
        "Error",
        "No se pudo archivar el folio: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> eliminarFolio(String folioId) async {
    try {
      await Supabase.instance.client.from('folios').delete().eq('id', folioId);

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

  final EasyInfiniteDateTimelineController timelineController =
      EasyInfiniteDateTimelineController();

  void goToToday(Function(DateTime) onDateSelected) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    selectedDate = today;

    fechaSeleccionada.value =
        '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        timelineController.animateToDate(today);
      } catch (e, stackTrace) {
        debugPrint('❌ Error haciendo scroll a hoy: $e');
        debugPrint('$stackTrace');
      }

      await getFoliosWithDate();
      onDateSelected(today);
    });
  }

  void changeDate(DateTime date, Function(DateTime) onDateSelected) {
    final cleanDate = DateTime(date.year, date.month, date.day);

    selectedDate = cleanDate;

    fechaSeleccionada.value = cleanDate.toIso8601String().split('T')[0];

    onDateSelected(cleanDate);
  }

  void increment() => count.value++;
}
