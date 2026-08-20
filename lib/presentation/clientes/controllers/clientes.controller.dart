import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/clientes.dart';
import 'package:bitacora_frontend/infrastructure/models/direcciones.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientesController extends GetxController
    with StateMixin<List<Clientes>> {
  //TODO: Implement ClientesController
  TextEditingController buscadorController = TextEditingController();
  RxInt rolUsuario = 0.obs;
  final Rx<Direcciones> _direccion = Direcciones().obs;
  Direcciones get direccion => this._direccion.value;
  set direccion(value) => this._direccion.value = value;

  int _page = 0;
  final int _limit = 20;
  var isLoadingMore = false.obs;
  bool _hasMoreData = true;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    _onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
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
    getClientes();
  }

  Future<void> getClientes() async {
    _page = 0;
    _hasMoreData = true;
    change(null, status: RxStatus.loading());

    try {
      final searchText = buscadorController.text.trim();
      
      var query = Supabase.instance.client.from('clientes').select();

      // Aplicar filtro de búsqueda si el texto no está vacío (ajusta las columnas según tu base de datos)
      if (searchText.isNotEmpty) {
        query = query.or('nombreComercial.ilike.%$searchText%,nombre.ilike.%$searchText%');
      }

      // Paginación en Supabase usando range
      final int from = _page * _limit;
      final int to = from + _limit - 1;
      
      final response = await query
          .range(from, to)
          .order('id', ascending: true); // Ajusta la columna de ordenamiento si es necesario

      List<Clientes> listClientes = (response as List).map((element) {
        return Clientes.fromJson(Map<String, dynamic>.from(element));
      }).toList();

      if (listClientes.length < _limit) {
        _hasMoreData = false;
      }

      if (listClientes.isEmpty) {
        change(listClientes, status: RxStatus.empty());
      } else {
        change(listClientes, status: RxStatus.success());
      }
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<void> loadMoreClientes() async {
    if (isLoadingMore.value || !_hasMoreData) return;

    isLoadingMore.value = true;
    _page++;

    try {
      final searchText = buscadorController.text.trim();
      
      var query = Supabase.instance.client.from('clientes').select();

      if (searchText.isNotEmpty) {
        query = query.or('nombreComercial.ilike.%$searchText%,nombre.ilike.%$searchText%');
      }

      final int from = _page * _limit;
      final int to = from + _limit - 1;

      final response = await query
          .range(from, to)
          .order('id', ascending: true);

      List<Clientes> moreClientes = (response as List).map((element) {
        return Clientes.fromJson(Map<String, dynamic>.from(element));
      }).toList();

      if (moreClientes.length < _limit) {
        _hasMoreData = false;
      }

      final currentList = state ?? [];
      currentList.addAll(moreClientes);

      change(currentList, status: RxStatus.success());
    } catch (e) {
      _page--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> getDireccionCliente(dynamic clienteId) async {
    try {
      // Consulta directa a Supabase para la dirección del cliente
      final resultado = await Supabase.instance.client
          .from('direcciones') // Ajusta el nombre de la tabla de direcciones si es diferente
          .select()
          .eq('clienteId', clienteId) // Ajusta la llave foránea según tu esquema
          .maybeSingle();

      print("Direccion cruda: ${jsonEncode(resultado)}");
      
      direccion = resultado != null
          ? Direcciones.fromJson(resultado)
          : Direcciones();

      print("Direccion: ${jsonEncode(direccion)}");
    } catch (e) {
      print("Error al obtener la dirección del cliente: $e");
    }
  }

  void increment() => count.value++;
}