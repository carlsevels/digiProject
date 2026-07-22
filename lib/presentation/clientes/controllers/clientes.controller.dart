import 'dart:convert';

import 'package:bitacora_frontend/infrastructure/models/clientes.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/clientes/querys/listClientes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:powersync/sqlite3.dart';

class ClientesController extends GetxController
    with StateMixin<List<Clientes>> {
  //TODO: Implement ClientesController
  TextEditingController buscadorController = TextEditingController();
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
    getClientes();
  }

  Future<void> getClientes() async {
    _page = 0;
    _hasMoreData = true;
    change(null, status: RxStatus.loading());

    try {
      final searchText = buscadorController.text;
      final ResultSet resultSet = await AppDatabase.db.execute(
        listClientesQuery(),
        [searchText, searchText, searchText, _limit, _page * _limit],
      );

      List<Clientes> listClientes = resultSet.map((element) {
        final map = Map<String, dynamic>.from(element as Map);
        return Clientes.fromJson(map);
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
      final searchText = buscadorController.text;
      final ResultSet resultSet = await AppDatabase.db.execute(
        listClientesQuery(),
        [searchText, searchText, searchText, _limit, _page * _limit],
      );

      List<Clientes> moreClientes = resultSet.map((element) {
        final map = Map<String, dynamic>.from(element as Map);
        return Clientes.fromJson(map);
      }).toList();

      if (moreClientes.length < _limit) {
        _hasMoreData = false;
      }

      // Obtenemos la lista actual del estado y le agregamos los nuevos elementos
      final currentList = state ?? [];
      currentList.addAll(moreClientes);

      change(currentList, status: RxStatus.success());
    } catch (e) {
      _page--; // Revertir incremento si falla
    } finally {
      isLoadingMore.value = false;
    }
  }

  void increment() => count.value++;
}
