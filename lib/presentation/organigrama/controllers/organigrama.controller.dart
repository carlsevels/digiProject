import 'package:bitacora_frontend/presentation/organigrama/models/chart_config.dart';
import 'package:bitacora_frontend/presentation/organigrama/utils/chart_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:org_chart/org_chart.dart';

class OrganigramaController extends GetxController {
  //TODO: Implement OrganigramaController

  final List<Map<String, dynamic>> simulatedOrgData = [
    // --- Nivel 1 (Gerencia General - Ocupado) ---
    {
      'id': '1',
      'name': 'Ana Pérez',
      'parent': null,
      'photo': 'https://randomuser.me/api/portraits/women/44.jpg',
      'color': Colors.blue,
      'hasVacancy': true,
      'position': 'Gerente General',
    },

    // --- Nivel 2 (Directores de Área) ---
    {
      'id': '2',
      'name': 'Carlos Gómez',
      'parent': '1',
      'photo': 'https://randomuser.me/api/portraits/men/32.jpg',
      'color': Colors.orange,
      'hasVacancy': true,
      'position': 'Director Financiero',
    },
    {
      'id': '3',
      'name': 'Sofía Rodríguez',
      'parent': '1',
      'photo': 'https://randomuser.me/api/portraits/women/68.jpg',
      'color': Colors.purple,
      'hasVacancy': true,
      'position': 'Directora de Tecnología',
    },
    {
      'id': '4',
      'name': 'Vacante Disponible',
      'parent': '1',
      'photo': '',
      'color': Colors.teal,
      'hasVacancy': false,
      'position': 'Director de Operaciones',
    },

    // --- Nivel 3 (Subgerentes - Reportan a Carlos ID: 2) ---
    {
      'id': '5',
      'name': 'Lucía Fernández',
      'parent': '2',
      'photo': 'https://randomuser.me/api/portraits/women/12.jpg',
      'color': Colors.indigo,
      'hasVacancy': true,
      'position': 'Subgerente de Contabilidad',
    },
    {
      'id': '6',
      'name': 'Vacante Disponible',
      'parent': '2',
      'photo': '',
      'color': Colors.indigo,
      'hasVacancy': false,
      'position': 'Subgerente de Ventas',
    },

    // --- Nivel 3 (Subgerentes - Reportan a Sofía ID: 3) ---
    {
      'id': '7',
      'name': 'Valeria Morales',
      'parent': '3',
      'photo': 'https://randomuser.me/api/portraits/women/28.jpg',
      'color': Colors.deepPurple,
      'hasVacancy': true,
      'position': 'Subgerente de Desarrollo',
    },
    {
      'id': '8',
      'name': 'David Castillo',
      'parent': '3',
      'photo': 'https://randomuser.me/api/portraits/men/18.jpg',
      'color': Colors.deepPurple,
      'hasVacancy': true,
      'position': 'Subgerente de Infraestructura',
    },
    {
      'id': '9',
      'name': 'Vacante Disponible',
      'parent': '3',
      'photo': '',
      'color': Colors.deepPurple,
      'hasVacancy': false,
      'position': 'Subgerente de Seguridad TI',
    },

    // --- Nivel 3 (Subgerentes - Reportan a Operaciones ID: 4) ---
    {
      'id': '10',
      'name': 'Fernando Herrera',
      'parent': '4',
      'photo': 'https://randomuser.me/api/portraits/men/78.jpg',
      'color': Colors.cyan,
      'hasVacancy': true,
      'position': 'Subgerente de Logística',
    },
    {
      'id': '11',
      'name': 'Camila Vargas',
      'parent': '4',
      'photo': 'https://randomuser.me/api/portraits/women/33.jpg',
      'color': Colors.cyan,
      'hasVacancy': true,
      'position': 'Subgerente de Cadena de Suministro',
    },

    // --- Nivel 4 (Especialistas - Reportan a Lucía ID: 5) ---
    {
      'id': '12',
      'name': 'Ricardo Silva',
      'parent': '5',
      'photo': 'https://randomuser.me/api/portraits/men/88.jpg',
      'color': Colors.amber,
      'hasVacancy': true,
      'position': 'Espec. Fiscal',
    },
    {
      'id': '13',
      'name': 'Vacante Disponible',
      'parent': '5',
      'photo': '',
      'color': Colors.amber,
      'hasVacancy': false,
      'position': 'Espec. Marketing',
    },

    // --- Nivel 4 (Especialistas - Reportan a Valeria ID: 7) ---
    {
      'id': '14',
      'name': 'Esteban Paredes',
      'parent': '7',
      'photo': 'https://randomuser.me/api/portraits/men/22.jpg',
      'color': Colors.brown,
      'hasVacancy': true,
      'position': 'Ingeniero de Software Senior',
    },
    {
      'id': '15',
      'name': 'Vacante Disponible',
      'parent': '7',
      'photo': '',
      'color': Colors.brown,
      'hasVacancy': false,
      'position': 'QA Engineer',
    },
  ];
  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    focusNode = FocusNode()..addListener(() {});
    // Initialize with default configuration
    config = ChartConfig(); // Initialize the controller with sample data
    controllerChart = OrgChartController<Map<String, dynamic>>(
      items: simulatedOrgData,
      idProvider: (item) => item['id'],
      toProvider: (item) => item['parent'],
      toSetter: (item, newId) => {...item, 'parent': newId},
      boxSize: const Size(180, 90),
      spacing: config.nodeSpacing,
      runSpacing: config.levelSpacing,
      leafColumns: config.leafColumnCount,
    );
  }

  late final OrgChartController<Map<String, dynamic>> controllerChart;
  // CustomInteractiveViewer controller for direct manipulation
  final CustomInteractiveViewerController interactiveController =
      CustomInteractiveViewerController();

  // Configuration for the chart
  late ChartConfig config;
  late final FocusNode focusNode;

  // Available colors for nodes
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
