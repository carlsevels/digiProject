import 'dart:io';

import 'package:bitacora_frontend/infrastructure/models/organigrama.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/organigrama/models/chart_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:org_chart/org_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrganigramaController extends GetxController with StateMixin {
  final isLoading = true.obs;
  RxInt rolUsuario = 0.obs;
  var rolName = "Cargando...".obs;
  var nameUser = "Cargando...".obs;

  // Variables observables para los contadores del panel izquierdo
  var totalPlantilla = 0.obs;
  var totalVacantes = 0.obs;
  var totalAsignados = 0.obs;

  late final OrgChartController<Organigrama> controllerChart =
      OrgChartController<Organigrama>(
        items: [],
        idProvider: (item) => item.id.toString(),
        toProvider: (item) => item.parent?.toString(),
        toSetter: (item, newId) {
          try {
            if (newId != null && newId.isNotEmpty && newId != 'null') {
              item.parent = int.tryParse(newId);
            } else {
              item.parent = null;
            }
          } catch (e) {
            print("Error en toSetter: $e");
          }
          return item;
        },
        boxSize: const Size(180, 90),
        spacing: ChartConfig().nodeSpacing,
        runSpacing: ChartConfig().levelSpacing,
        leafColumns: ChartConfig().leafColumnCount,
      );

  final CustomInteractiveViewerController interactiveController =
      CustomInteractiveViewerController();

  late ChartConfig config;
  late final FocusNode focusNode;

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    focusNode = FocusNode()..addListener(() {});
    config = ChartConfig();
  }

  @override
  void onReady() {
    super.onReady();
    cargarDatosFrescos();
  }

  Future<void> cargarDatosFrescos() async {
    isLoading.value = true;
    await getOrganigrama();
    await getDatos();
    update();
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        try {
          await AppDatabase.db.disconnect();
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/${AppDatabase.db}');

          if (await file.exists()) {
            await file.delete();
          }
        } catch (dbError) {
          debugPrint("Error al limpiar base de datos local: $dbError");
        }
      }

      await Supabase.instance.client.auth.signOut();
      await Get.deleteAll(force: true);
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      debugPrint("Error al cerrar sesión: $e");
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<Map<String, dynamic>?> getDatos() async {
    try {
      final miId = Supabase.instance.client.auth.currentUser?.id;
      Map<String, dynamic>? resultado;

      if (!kIsWeb) {
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
      } else {
        final response = await Supabase.instance.client
            .from('datosPersonales')
            .select('*')
            .eq('userId', miId!)
            .maybeSingle();

        if (response != null) {
          resultado = Map<String, dynamic>.from(response);
          int rolIdVal = response['rolId'] ?? 0;
          resultado['nombre_rol'] = (rolIdVal == 1) ? "Admin" : "Usuario";
        }
      }

      if (resultado != null) {
        rolName.value = resultado["nombre_rol"];
        nameUser.value = resultado["nombre"];
      }
    } catch (e) {
      print("Error al obtener datos personales: $e");
    }
    return null;
  }

  Future<void> getOrganigrama() async {
    change(null, status: RxStatus.loading());
    try {
      List<Organigrama> loadedItems = [];

      if (kIsWeb) {
        final List<dynamic> orgResponse = await Supabase.instance.client
            .from('organigrama')
            .select('id, parent, name, color, created_at, employee_id');

        final List<dynamic> dpResponse = await Supabase.instance.client
            .from('datosPersonales')
            .select('userId, nombre, apellidoMaterno, apellidoPaterno');

        print(
          "Total de datos personales descargados en Web: ${dpResponse.length}",
        );

        final Map<String, Map<String, dynamic>> dpMap = {
          for (var item in dpResponse)
            (item['userId']?.toString() ?? ''): Map<String, dynamic>.from(item),
        };

        loadedItems = orgResponse.map((element) {
          final Map<String, dynamic> row = Map<String, dynamic>.from(
            element as Map,
          );
          final rawEmpId = row['employee_id'];

          if (rawEmpId != null && rawEmpId.toString().trim().isNotEmpty) {
            final String empId = rawEmpId.toString();
            if (dpMap.containsKey(empId)) {
              final datos = dpMap[empId]!;
              row['nombre'] = datos['nombre'];
              row['apellidoMaterno'] = datos['apellidoMaterno'];
              row['apellidoPaterno'] = datos['apellidoPaterno'];
            }
          }

          return Organigrama.fromJson(row);
        }).toList();
      } else {
        final dynamic resultSet = await AppDatabase.db.execute('''
        SELECT 
            o.*,
            dp.nombre,
            dp."apellidoMaterno",
            dp."apellidoPaterno"
        FROM organigrama o
        LEFT JOIN "datosPersonales" as dp ON o.employee_id = dp."userId"
      ''');

        loadedItems = (resultSet as List)
            .map(
              (element) => Organigrama.fromJson(
                Map<String, dynamic>.from(element as Map),
              ),
            )
            .toList();
      }

      controllerChart.clearItems();
      for (var item in loadedItems) {
        controllerChart.addItem(item);
      }

      // Cálculos actualizados para las tarjetas
      totalPlantilla.value = loadedItems.length;
      totalAsignados.value = loadedItems
          .where(
            (e) => e.employee_id != null && e.employee_id.toString().isNotEmpty,
          )
          .length;
      totalVacantes.value = totalPlantilla.value - totalAsignados.value;

      controllerChart.calculatePosition();
      isLoading.value = false;

      if (loadedItems.isEmpty) {
        change(null, status: RxStatus.empty());
      } else {
        change(loadedItems, status: RxStatus.success());
      }

      update();

      print("Organigrama cargado con éxito: ${loadedItems.length} registros");
    } catch (e) {
      isLoading.value = false;
      change(null, status: RxStatus.error(e.toString()));
      print("Error al cargar organigrama: $e");
    }
  }

  final List<Color> colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
    Colors.brown,
    Colors.deepOrange,
  ];

  @override
  void dispose() {
    focusNode.dispose();
    interactiveController.dispose();
    super.dispose();
  }

  Future<void> actualizarPosicion({String? id, String? newParent}) async {
    try {
      final parsedParent =
          (newParent != null && newParent != 'null' && newParent.isNotEmpty)
          ? int.tryParse(newParent)
          : null;
      final parsedId = int.tryParse(id ?? '');

      if (kIsWeb) {
        await Supabase.instance.client
            .from('organigrama')
            .update({'parent': parsedParent})
            .eq('id', parsedId!);

        print("Posición actualizada en Supabase correctamente");
      } else {
        await AppDatabase.db.execute(
          '''
          UPDATE organigrama 
          SET "parent" = ?
          WHERE "id" = ?;
          ''',
          [parsedParent, parsedId],
        );
        print("Posición actualizada en Base de Datos Local correctamente");
      }
      return null;
    } catch (e) {
      print("Error al actualizar la posición del organigrama: $e");
      return null;
    }
  }

  void increment() => count.value++;
}
