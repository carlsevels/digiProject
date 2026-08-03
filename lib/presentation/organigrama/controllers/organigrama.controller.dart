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
    'parent': null,
    'name': 'Gerente General',
    'color': Colors.blue,
    'employee': {
      'name': 'Ana Pérez',
      'photo': 'https://randomuser.me/api/portraits/women/44.jpg',
    },
  },
  
  // --- Nivel 2 (Directores de Área) ---
  {
    'id': '2',
    'parent': '1',
    'name': 'Director Financiero',
    'color': Colors.orange,
    'employee': {
      'name': 'Carlos Gómez',
      'photo': 'https://randomuser.me/api/portraits/men/32.jpg',
    },
  },
  {
    'id': '3',
    'parent': '1',
    'name': 'Directora de Tecnología',
    'color': Colors.purple,
    'employee': {
      'name': 'Sofía Rodríguez',
      'photo': 'https://randomuser.me/api/portraits/women/68.jpg',
    },
  },
  {
    'id': '4',
    'parent': '1',
    'name': 'Director de Operaciones',
    'color': Colors.teal,
    'employee': null, // Vacante (Disponible)
  },

  // --- Nivel 3 (Subgerentes - Reportan a Carlos ID: 2) ---
  {
    'id': '5',
    'parent': '2',
    'name': 'Subgerente de Contabilidad',
    'color': Colors.indigo,
    'employee': {
      'name': 'Lucía Fernández',
      'photo': 'https://randomuser.me/api/portraits/women/12.jpg',
    },
  },
  {
    'id': '6',
    'parent': '2',
    'name': 'Subgerente de Ventas',
    'color': Colors.indigo,
    'employee': null, // Vacante (Disponible)
  },

  // --- Nivel 3 (Subgerentes - Reportan a Sofía ID: 3) ---
  {
    'id': '7',
    'parent': '3',
    'name': 'Subgerente de Desarrollo',
    'color': Colors.deepPurple,
    'employee': {
      'name': 'Valeria Morales',
      'photo': 'https://randomuser.me/api/portraits/women/28.jpg',
    },
  },
  {
    'id': '8',
    'parent': '3',
    'name': 'Subgerente de Infraestructura',
    'color': Colors.deepPurple,
    'employee': {
      'name': 'David Castillo',
      'photo': 'https://randomuser.me/api/portraits/men/18.jpg',
    },
  },
  {
    'id': '9',
    'parent': '3',
    'name': 'Subgerente de Seguridad TI',
    'color': Colors.deepPurple,
    'employee': null, // Vacante (Disponible)
  },

  // --- Nivel 3 (Subgerentes - Reportan a Operaciones ID: 4) ---
  {
    'id': '10',
    'parent': '4',
    'name': 'Subgerente de Logística',
    'color': Colors.cyan,
    'employee': {
      'name': 'Fernando Herrera',
      'photo': 'https://randomuser.me/api/portraits/men/78.jpg',
    },
  },
  {
    'id': '11',
    'parent': '4',
    'name': 'Subgerente de Cadena de Suministro',
    'color': Colors.cyan,
    'employee': {
      'name': 'Camila Vargas',
      'photo': 'https://randomuser.me/api/portraits/women/33.jpg',
    },
  },

  // --- Nivel 4 (Especialistas - Reportan a Lucía ID: 5) ---
  {
    'id': '12',
    'parent': '5',
    'name': 'Espec. Fiscal',
    'color': Colors.amber,
    'employee': {
      'name': 'Ricardo Silva',
      'photo': 'https://randomuser.me/api/portraits/men/88.jpg',
    },
  },
  {
    'id': '13',
    'parent': '5',
    'name': 'Espec. Marketing',
    'color': Colors.amber,
    'employee': null, // Vacante (Disponible)
  },

  // --- Nivel 4 (Especialistas - Reportan a Valeria ID: 7) ---
  {
    'id': '14',
    'parent': '7',
    'name': 'Ingeniero de Software Senior',
    'color': Colors.brown,
    'employee': {
      'name': 'Esteban Paredes',
      'photo': 'https://randomuser.me/api/portraits/men/22.jpg',
    },
  },
  {
    'id': '15',
    'parent': '7',
    'name': 'QA Engineer',
    'color': Colors.brown,
    'employee': null, // Vacante (Disponible)
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
