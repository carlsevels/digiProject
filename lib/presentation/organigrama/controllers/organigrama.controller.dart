import 'package:bitacora_frontend/infrastructure/models/organigrama.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/organigrama/models/chart_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:org_chart/org_chart.dart';

class OrganigramaController extends GetxController {
  final isLoading = true.obs;

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
  void onInit() async {
    super.onInit();
    focusNode = FocusNode()..addListener(() {});
    config = ChartConfig();
    await getOrganigrama();
  }
Future<void> getOrganigrama() async {
    try {
      // CAMBIO AQUÍ: ResultSet cambiado a dynamic
      final dynamic resultSet = await AppDatabase.db.execute('''
        SELECT 
            o.id,
            o.parent,
            o.name,
            o.color,
            o.created_at,
            o.employee_id,
            dp.nombre,
            dp."apellidoMaterno",
            dp."apellidoPaterno"
        FROM organigrama o
        LEFT JOIN "datosPersonales" as dp ON o.employee_id = dp."userId"
      ''');

      final List<Organigrama> loadedItems = resultSet
          .map(
            (element) =>
                Organigrama.fromJson(Map<String, dynamic>.from(element as Map)),
          )
          .toList();

      // Limpiamos y agregamos los elementos al controlador ya existente
      controllerChart.clearItems();
      for (var item in loadedItems) {
        controllerChart.addItem(item);
      }

      controllerChart.calculatePosition();
      isLoading.value = false;

      print("Organigrama cargado con éxito: ${loadedItems.length} registros");
    } catch (e) {
      isLoading.value = false;
      print("Error al cargar organigrama local: $e");
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
      await AppDatabase.db.execute(
        '''
        UPDATE organigrama 
        SET "parent" = ?
        WHERE "id" = ?;
        ''',
        [newParent, id],
      );
      return null;
    } catch (e) {
      print("Error al archivar folio: $e");
      return null;
    }
  }

  void increment() => count.value++;
}
