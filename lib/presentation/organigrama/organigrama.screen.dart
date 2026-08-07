import 'package:bitacora_frontend/infrastructure/models/organigrama.dart';
import 'package:bitacora_frontend/presentation/organigrama/widgets/chart_node_widget.dart';
import 'package:bitacora_frontend/presentation/organigrama/widgets/dialogs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/organigrama.controller.dart';
import 'package:org_chart/org_chart.dart';

class OrganigramaScreen extends StatefulWidget {
  const OrganigramaScreen({super.key});

  @override
  State<OrganigramaScreen> createState() => _OrganigramaScreenState();
}

class _OrganigramaScreenState extends State<OrganigramaScreen> {
  bool _isWebMenuVisible = true;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrganigramaController>();
    final colorScheme = Theme.of(context).colorScheme;

    final Widget mainBody = controller.obx(
      (state) => Scaffold(
        body: Row(
          children: [
            Container(
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Panel de Control RH",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Gestión de plantilla y jerarquías",
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Tarjetas de Métricas de Personal (Plantilla, Vacantes y Empleados)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                title: "Plantilla",
                                value:
                                    "${controller.controllerChart.items.length}",
                                icon: Icons.group_outlined,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                title: "Vacantes",
                                value:
                                    "${controller.controllerChart.items.where((i) => i.employee_id == null || i.employee_id.toString().trim().isEmpty).length}",
                                icon: Icons.person_off_outlined,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: _buildMetricCard(
                            context,
                            title: "Empleados Asignados",
                            value:
                                "${controller.controllerChart.items.where((i) => i.employee_id != null && i.employee_id.toString().trim().isNotEmpty).length}",
                            icon: Icons.how_to_reg_outlined,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      "Acciones Rápidas",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: const Icon(Icons.add_circle_outline),
                            title: const Text('Crear Nueva Plaza'),
                            subtitle: const Text(
                              'Añadir puesto al organigrama',
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onTap: () =>
                                _showAddNodeDialog(context, controller),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: const Icon(Icons.refresh_outlined),
                            title: const Text('Restablecer Vista'),
                            subtitle: const Text('Centrar organigrama'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onTap: () {
                              controller.controllerChart.calculatePosition();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Vista de organigrama restablecida',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Arrastra un puesto sobre otro para reorganizar la línea de reporte.",
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- LIENZO PRINCIPAL ---
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                      colorScheme.surface,
                    ],
                  ),
                ),
                child: _buildOrgChart(context, controller),
              ),
            ),
          ],
        ),
      ),
    );
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: const Color(0XFFF8FAFC),
        body: Row(
          children: [
            if (_isWebMenuVisible)
              const VerticalDivider(
                thickness: 1,
                width: 1,
                color: Color(0xFFE2E8F0),
              ),

            Expanded(
              child: Scaffold(
                backgroundColor: const Color(0XFFF8FAFC),
                body: mainBody,
              ),
            ),
          ],
        ),
      );
    }

    return mainBody;
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildOrgChart(context, OrganigramaController controller) {
    return Stack(
      children: [
        SizedBox.expand(
          child: OrgChart<Organigrama>(
            controller: controller.controllerChart,
            viewerController: controller.interactiveController,
            builder: (details) => ChartNodeWidget(
              details: details,
              cornerRadius: controller.config.cornerRadius,
            ),
            optionsBuilder: (item) =>
                _buildOptionsMenu(item, context, controller),
            onOptionSelect: (item, value) {
              _handleOptionSelect(item, value, context, controller);
            },
            isDraggable: controller.config.isDraggable,
            cornerRadius: controller.config.cornerRadius,
            arrowStyle: controller.config.arrowStyle,
            duration: controller.config.animationDuration,
            curve: controller.config.animationCurve,
            lineEndingType: controller.config.lineEndingType,
            interactionConfig: InteractionConfig(
              enableRotation: controller.config.enableRotation,
              constrainBounds: controller.config.constrainBounds,
              enableFling: controller.config.enableFling,
              scrollMode: controller.config.enablePan
                  ? ScrollMode.both
                  : ScrollMode.none,
            ),
            keyboardConfig: KeyboardConfig(
              enableKeyboardControls: controller.config.enableKeyboardControls,
              keyboardPanDistance: controller.config.keyboardPanDistance,
              keyboardZoomFactor: controller.config.keyboardZoomFactor,
              animateKeyboardTransitions:
                  controller.config.animateKeyboardTransitions,
              keyboardAnimationCurve: controller.config.keyboardAnimationCurve,
              keyboardAnimationDuration:
                  controller.config.keyboardAnimationDuration,
              invertArrowKeyDirection:
                  controller.config.invertArrowKeyDirection,
              enableKeyRepeat: controller.config.enableKeyRepeat,
              keyRepeatInitialDelay: controller.config.keyRepeatInitialDelay,
              keyRepeatInterval: controller.config.keyRepeatInterval,
            ),
            zoomConfig: ZoomConfig(
              minScale: controller.config.minScale,
              maxScale: controller.config.maxScale,
              enableZoom: controller.config.enableZoom,
              enableDoubleTapZoom: controller.config.enableDoubleTapZoom,
              doubleTapZoomFactor: controller.config.doubleTapZoomFactor,
              enableCtrlScrollToScale:
                  controller.config.enableCtrlScrollToScale,
            ),
            focusNode: controller.focusNode,
            linePaint: controller.config.getLinePaint(context),
            onDrop: (dragged, target, isTargetSubnode) async {
              try {
                if (isTargetSubnode || dragged.id == target.id) {
                  return;
                }

                if (dragged.parent == target.id) {
                  return;
                }

                dragged.parent = target.id;

                await controller.actualizarPosicion(
                  id: dragged.id.toString(),
                  newParent: target.id.toString(),
                );
                Future.delayed(const Duration(milliseconds: 200), () {
                  try {
                    controller.controllerChart.updateItem(dragged);
                  } catch (eChart) {
                    print("ERROR EN CHART: $eChart");
                  }
                });
              } catch (e, stackTrace) {
                print("💥 ERROR FATAL EN ONDROP: $e");
                print(stackTrace);
              }
            },
          ),
        ),
        if (controller.focusNode.hasFocus)
          IgnorePointer(
            child: Stack(
              children: [
                SizedBox.expand(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 4,
                          blurStyle: BlurStyle.outer,
                        ),
                      ],
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.keyboard,
                          size: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Focus Mode",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildOptionsMenu(
    Organigrama item,
    context,
    OrganigramaController controller,
  ) {
    final List<PopupMenuEntry<String>> options = [];

    if (item.parent != null) {
      options.add(
        const PopupMenuItem(
          value: 'remove',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            title: Text('Eliminar Plaza', style: TextStyle(color: Colors.red)),
          ),
        ),
      );
    }

    options.addAll([
      const PopupMenuItem(
        value: 'edit',
        child: ListTile(
          leading: Icon(Icons.edit_outlined),
          title: Text('Editar Puesto'),
        ),
      ),
      const PopupMenuItem(
        value: 'add',
        child: ListTile(
          leading: Icon(Icons.person_add_outlined),
          title: Text('Añadir Subordinado'),
        ),
      ),
      const PopupMenuItem(
        value: 'color',
        child: ListTile(
          leading: Icon(Icons.color_lens_outlined),
          title: Text('Cambiar Color de Área'),
        ),
      ),
    ]);

    return options;
  }

  void _handleOptionSelect(
    Organigrama item,
    dynamic value,
    context,
    OrganigramaController controller,
  ) {
    switch (value) {
      case 'remove':
        _removeNode(item, context, controller);
        break;
      case 'edit':
        _handleEditNode(item, context, controller);
        break;
      case 'add':
        _addChildNode(item, context, controller);
        break;
      case 'color':
        _changeNodeColor(item, context, controller);
        break;
    }
  }

  void _removeNode(
    Organigrama item,
    context,
    OrganigramaController controller,
  ) {
    try {
      controller.controllerChart.removeItem(
        item.id.toString(),
        ActionOnNodeRemoval.removeDescendants,
      );
    } catch (e) {
      _showError('Failed to remove node: ${e.toString()}', context);
    }
  }

  void _handleEditNode(
    Organigrama item,
    context,
    OrganigramaController controller,
  ) async {
    final result = await showDialog<Organigrama>(
      context: context,
      builder: (context) => NodeDialog(
        title: 'Edit Node',
        initialName: item.name ?? "",
        isNewNode: false,
        availableParents: controller.controllerChart.items,
      ),
    );

    if (result != null && result.name != null && result.name!.isNotEmpty) {
      item.name = result.name;
    }
  }

  void _addChildNode(
    Organigrama item,
    context,
    OrganigramaController controller,
  ) async {
    final result = await showDialog<Organigrama>(
      context: context,
      builder: (context) => NodeDialog(
        title: 'Add Child Node',
        initialParentId: item.id.toString(),
        isNewNode: true,
        availableParents: controller.controllerChart.items,
      ),
    );

    if (result != null && result.name != null && result.name!.isNotEmpty) {
      final newNode = Organigrama(
        id: DateTime.now().millisecondsSinceEpoch,
        parent: item.id,
        name: result.name,
        color: "",
      );

      controller.controllerChart.addItem(newNode);
    }
  }

  void _showAddNodeDialog(context, OrganigramaController controller) async {
    final result = await showDialog<Organigrama>(
      context: context,
      builder: (context) => NodeDialog(
        title: 'Add New Node',
        isNewNode: true,
        availableParents: controller.controllerChart.items,
      ),
    );

    if (result != null && result.name != null && result.name!.isNotEmpty) {
      final newNode = Organigrama(
        id: DateTime.now().millisecondsSinceEpoch,
        parent: result.parent,
        name: result.name,
        color: "",
      );

      controller.controllerChart.addItem(newNode);
    }
  }

  void _changeNodeColor(
    Organigrama item,
    context,
    OrganigramaController controller,
  ) async {
    final result = await showDialog<Color?>(
      context: context,
      builder: (context) =>
          ColorPickerDialog(colorOptions: controller.colorOptions),
    );

    if (result != null) {
      item.color = result.toString();
    }
  }

  void _showInstructions(context) {
    showDialog(
      context: context,
      builder: (context) => const InstructionsDialog(),
    );
  }

  void _showError(String message, context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
