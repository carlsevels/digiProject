import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

class DetallesFolioController extends GetxController with StateMixin<Folios> {
  RxInt currentStep = 0.obs;
  RxInt statusId = 0.obs;
  int? nextStatus;
  var historialList = <Folios>[].obs;

  @override
  void onInit() {
    super.onInit();
    onInitDetalles();
  }

  @override
  void onClose() {
    print("Cerrando pantalla, limpiando recursos...");
    super.onClose();
  }

  Future<void> onInitDetalles() async {
    final String id = Get.arguments?.toString() ?? "";

    if (id.isEmpty) {
      print("Error: El ID recibido es nulo o vacío");
      change(null, status: RxStatus.error("ID no válido"));
      return;
    }
    print("FolioId: $id");

    await getDetailsFolio(id);
  }

  Future<void> getDetailsFolio(String idBuscado) async {
    change(null, status: RxStatus.loading());
    try {
      final response = await Supabase.instance.client
          .from('folios')
          .select('''
            id, 
            folioId, 
            isArchived, 
            created_at,
            cantidad,
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
          .eq('folioId', idBuscado)
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

  Future<void> historialFolio(String folioId) async {
    try {
      historialList.clear();

      final response = await Supabase.instance.client
          .from('historialestados')
          .select('''
            id,
            folioId,
            statusId,
            created_at,
            status:statusId(nombre, color)
          ''')
          .eq('folioId', folioId)
          .order('created_at', ascending: true);

      List<Folios> folio = (response as List)
          .map((element) => Folios.fromJson(Map<String, dynamic>.from(element)))
          .toList();

      historialList.value = folio;
      print("FolioId Historial cargado: $folioId");
    } catch (e) {
      print("Error en historialFolio: $e");
    }
  }

  Color parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFF22C55E);
    }
    try {
      String cleanedHex = hexColor
          .replaceAll('#', '')
          .replaceAll('0X', '')
          .replaceAll('0x', '');

      if (cleanedHex.length == 6) {
        cleanedHex = 'FF$cleanedHex';
      } else if (cleanedHex.length == 7) {
        cleanedHex = 'F$cleanedHex';
      } else if (cleanedHex.length < 6) {
        return const Color(0xFF22C55E);
      }

      return Color(int.parse(cleanedHex, radix: 16));
    } catch (e) {
      return const Color(0xFF22C55E);
    }
  }

  int getStepIndex(int statusId) {
    switch (statusId) {
      case 1:
        return 0; // Por iniciar
      case 2:
        return 1; // Llegada
      case 3:
        return 3; // Entregado
      case 4:
        return 0; // Pendiente
      case 5:
        return 2; // Sitio
      default:
        return 0;
    }
  }

  Widget statusFolio(int statusId) {
    switch (statusId) {
      case 1 || 4:
        return const Text(
          'Empezar ruta',
          textScaler: TextScaler.linear(1.3),
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case 2:
        return const Text(
          'Llegada',
          textScaler: TextScaler.linear(1.3),
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case 5:
        return const Text(
          'Finalizar entrega',
          textScaler: TextScaler.linear(1.3),
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<int?> changeStatus(String statusId, String folioId) async {
    int? nextStatus;

    if (folioId.isEmpty) {
      print("Error: folioId vacío en changeStatus");
      return null;
    }

    switch (statusId) {
      case "1" || "4":
        nextStatus = 2;
        break;
      case "2":
        nextStatus = 5;
        break;
      case "5":
        nextStatus = 3;
        break;
      default:
        return null;
    }

    await Supabase.instance.client.from('historialestados').insert({
      'id': const Uuid().v4(),
      'folioId': folioId,
      'statusId': nextStatus,
      'created_at': DateTime.now().toIso8601String(),
    });

    return nextStatus;
  }

  Future<void> pedidoPendiente(String folioId) async {
    await Supabase.instance.client.from('historialestados').insert({
      'id': const Uuid().v4(),
      'folioId': folioId,
      'statusId': 4,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> llamarTelefonoSoporteTecnico() async {
    final Uri uri = Uri.parse('tel:8110294162');

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );

      if (!launched) {
        print('No existe aplicación para llamadas');
      }
    } catch (e) {
      print('Error llamada: $e');
    }
  }

  Future<void> archivarFolio(String folioId) async {
    try {
      await Supabase.instance.client
          .from('folios')
          .update({'isArchived': true})
          .eq('folioId', folioId);

      await onInitDetalles();
    } catch (e) {
      print("Error al archivar folio: $e");
    }
  }

  Future<void> restaurarFolio(String folioId) async {
    try {
      await Supabase.instance.client
          .from('folios')
          .update({'isArchived': false})
          .eq('folioId', folioId);

      await onInitDetalles();
    } catch (e) {
      print("Error al restaurar folio: $e");
    }
  }

  Future<void> eliminarFolio(String folioId) async {
    try {
      await Supabase.instance.client
          .from('folios')
          .delete()
          .eq('folioId', folioId);

      Get.toNamed(Routes.FOLIOS);
    } catch (e) {
      print("Error al eliminar folio en Supabase: ${e.toString()}");
    }
  }
}
