import 'dart:convert';
import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SearchFolioController extends GetxController with StateMixin<Folios> {
  RxInt currentStep = 0.obs;
  RxInt statusId = 0.obs;
  TextEditingController id = TextEditingController();

  var isSearching = false.obs;
  var hasData = false.obs;

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    change(null, status: RxStatus.empty());
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    id.dispose();
    super.onClose();
  }

  Future<void> onInitDetalles() async {
    if (id.text.isEmpty) {
      print("Error: El ID recibido es nulo o vacío");
      change(null, status: RxStatus.error("ID no válido"));
      return;
    }
    print("FolioId: ${id.text}");

    await getDetailsFolio(id.text);
  }

  Future<void> getDetailsFolio(String idBuscado) async {
    change(null, status: RxStatus.loading());
    try {
      // Consulta actualizada con las relaciones completas adaptada a la búsqueda parcial (ilike)
      final response = await Supabase.instance.client
          .from('folios')
          .select('''
            id, 
            folioId, 
            isArchived, 
            created_at,
            cantidad,
            repartidor:repartidorId(nombre, apellidoPaterno),
            tipofolio:tipoFolioId(nombre),
            clientes:clienteId(
              nombreComercial,
              direcciones(
                calle,
                colonia,
                codigoPostal,
                numExt,
                numInt,
                municipios(nombre)
              )
            ),
            typeRefaccion:typeRefaccionId(nombre),
            condicionPago:condicionDePagoId(nombre),
            historialestados(
              statusId,
              status:statusId(nombre, color)
            )
          ''')
          .ilike('folioId', '%$idBuscado%')
          .order(
            'created_at',
            ascending: true,
            referencedTable: 'historialestados',
          )
          .maybeSingle();

      if (response == null) {
        change(null, status: RxStatus.empty());
        return;
      }

      final folio = Folios.fromJson(Map<String, dynamic>.from(response));

      final idParaHistorial =
          folio.folioIdHistorial ?? folio.folioId ?? idBuscado;

      final ultimoRegistro = await getUltimoStatus(idParaHistorial);

      if (ultimoRegistro != null) {
        statusId.value = ultimoRegistro["statusId"] as int;
        currentStep.value = getStepIndex(statusId.value);
        print("Status actual actualizado a: ${currentStep.value}");
      } else {
        // Fallback: Si el historial viene directamente en el JSON de la consulta
        if (folio.statusId != null) {
          statusId.value = int.tryParse(folio.statusId!) ?? 1;
          currentStep.value = getStepIndex(statusId.value);
        } else {
          print(
            "ADVERTENCIA: No se encontró estatus para el folioId: ${folio.folioId}",
          );
        }
      }

      print("Folio: ${jsonEncode(folio)}");
      change(folio, status: RxStatus.success());
    } catch (e) {
      print("Error al cargar detalles del folio: $e");
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<Map<String, dynamic>?> getUltimoStatus(String folioId) async {
    try {
      final response = await Supabase.instance.client
          .from('historialestados')
          .select()
          .eq('folioId', folioId)
          .order('created_at', ascending: false)
          .limit(1);

      if (response != null && (response as List).isNotEmpty) {
        return response.first as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error al obtener el último status: $e");
      return null;
    }
  }

  Color parseColor(String? colorStr, {Color defaultColor = Colors.grey}) {
    if (colorStr == null || colorStr.isEmpty) return defaultColor;

    String cleanColor = colorStr.toUpperCase().replaceAll('0X', '');

    int? colorInt = int.tryParse(cleanColor, radix: 16);

    return colorInt != null ? Color(colorInt | 0xFF000000) : defaultColor;
  }

  Future<void> pedidoPendiente(String folioId) async {
    try {
      await Supabase.instance.client.from('historialestados').insert({
        'id': const Uuid().v4(),
        'folioId': folioId,
        'statusId': 4,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Error al registrar pedido pendiente: $e");
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      id.clear();
    }
  }

  int getStepIndex(int statusId) {
    switch (statusId) {
      // Por iniciar
      case 1:
        return 0;

      // Llegada
      case 2:
        return 1;

      // Entregado
      case 3:
        return 3;

      // Pendiente
      case 4:
        return 0;

      // Sitio
      case 5:
        return 2;

      default:
        return 0;
    }
  }

  void increment() => count.value++;
}
