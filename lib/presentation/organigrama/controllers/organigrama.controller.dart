import 'package:bitacora_frontend/infrastructure/models/organigrama.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:bitacora_frontend/presentation/organigrama/models/chart_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:org_chart/org_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrganigramaController extends GetxController {
  final isLoading = true.obs;

  // Inicializamos el chart inmediatamente con una lista vacía para evitar errores de tipo 'late'
  late final OrgChartController<Organigrama> controllerChart = OrgChartController<Organigrama>(
    items: [],
    idProvider: (item) => item.id.toString(),
    toProvider: (item) => item.parent?.toString(),
    toSetter: (item, newId) {
      item.parent = newId != null ? int.tryParse(newId) : null;
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
    getOrganigrama();
  }

  Future<void> getOrganigrama() async {
    try {
      List<Organigrama> loadedItems = [];

      if (kIsWeb) {
        final response = await Supabase.instance.client.from('organigrama').select('''
              id,
              parent,
              name,
              color,
              created_at,
              employee_id,
              datosPersonales:employee_id (
                nombre,
                apellidoMaterno,
                apellidoPaterno
              )
            ''');

        loadedItems = (response as List).map((element) {
          final map = Map<String, dynamic>.from(element as Map);
          if (map['datosPersonales'] != null) {
            final dp = map['datosPersonales'];
            if (dp is List && dp.isNotEmpty) {
              map['nombre'] = dp[0]['nombre'];
              map['apellidoMaterno'] = dp[0]['apellidoMaterno'];
              map['apellidoPaterno'] = dp[0]['apellidoPaterno'];
            } else if (dp is Map) {
              map['nombre'] = dp['nombre'];
              map['apellidoMaterno'] = dp['apellidoMaterno'];
              map['apellidoPaterno'] = dp['apellidoPaterno'];
            }
          }
          return Organigrama.fromJson(map);
        }).toList();
      } else {
        final resultSet = await AppDatabase.db.execute('''
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

        loadedItems = resultSet
            .map(
              (element) =>
                  Organigrama.fromJson(Map<String, dynamic>.from(element as Map)),
            )
            .toList();
      }

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

  void increment() => count.value++;
}