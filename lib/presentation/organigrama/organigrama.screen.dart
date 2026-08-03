import 'package:bitacora_frontend/infrastructure/models/organigrama.dart';
import 'package:bitacora_frontend/infrastructure/models/refacciones.dart';
import 'package:bitacora_frontend/presentation/organigrama/models/chart_config.dart';
import 'package:bitacora_frontend/presentation/organigrama/utils/chart_utils.dart';
import 'package:bitacora_frontend/presentation/organigrama/widgets/chart_node_widget.dart';
import 'package:bitacora_frontend/presentation/organigrama/widgets/chart_options_sidebar.dart';
import 'package:bitacora_frontend/presentation/organigrama/widgets/dialogs.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/organigrama.controller.dart';
import 'package:flutter/material.dart';
import 'package:org_chart/org_chart.dart';

class OrganigramaScreen extends GetView<OrganigramaController> {
  OrganigramaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Org Chart Example'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInstructions(context);
            },
            tooltip: 'Instructions',
          ),
        ],
      ),
      body: Row(
        children: [
          // // Left Sidebar
          // ChartOptionsSidebar(
          //   config: controller.config,
          //   controller: controller.controllerChart,
          //   interactiveViewerController: controller.interactiveController,
          //   onConfigChanged: (newConfig) {
          //     // Check if leaf column count has changed
          //     if (controller.config.leafColumnCount !=
          //         newConfig.leafColumnCount) {
          //       controller.controllerChart.leafColumns =
          //           newConfig.leafColumnCount;
          //       controller.controllerChart.calculatePosition();
          //     }

          //     controller.config = newConfig;
          //   },
          //   onAddNodePressed: () {
          //     _showAddNodeDialog(context);
          //   },
          //   onResetLayoutPressed: () {
          //     controller.controllerChart.calculatePosition();
          //     ScaffoldMessenger.of(
          //       context,
          //     ).showSnackBar(const SnackBar(content: Text('Layout reset')));
          //   },
          // ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
              child: _buildOrgChart(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrgChart(context) {
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
            optionsBuilder: (item) => _buildOptionsMenu(item),
            onOptionSelect: (item, value) {
              _handleOptionSelect(item, value, context);
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
              invertArrowKeyDirection: controller.config.invertArrowKeyDirection,
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
              enableCtrlScrollToScale: controller.config.enableCtrlScrollToScale,
            ),
            focusNode: controller.focusNode,
            linePaint: controller.config.getLinePaint(context),
            onDrop: (dragged, target, isTargetSubnode) {
              if (isTargetSubnode) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cannot drop a node onto its own child'),
                  ),
                );
                controller.controllerChart.calculatePosition();
                return;
              }
          
              if (dragged.parent == target.id) {
                controller.controllerChart.calculatePosition();
                return;
              }
          
              // Actualizamos la propiedad directamente en el objeto GeneralModel
              dragged.parent = target.id;
              controller.controllerChart.updateItem(dragged);
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

  List<PopupMenuEntry<String>> _buildOptionsMenu(Organigrama item) {
    final List<PopupMenuEntry<String>> options = [];

    if (item.parent != null) {
      options.add(
        PopupMenuItem(
          value: 'remove',
          child: const ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Remove Node'),
          ),
        ),
      );
    }

    options.addAll([
      PopupMenuItem(
        value: 'edit',
        child: const ListTile(
          leading: Icon(Icons.edit_outlined),
          title: Text('Edit Node'),
        ),
      ),
      PopupMenuItem(
        value: 'add',
        child: const ListTile(
          leading: Icon(Icons.add_circle_outline),
          title: Text('Add Child'),
        ),
      ),
      PopupMenuItem(
        value: 'color',
        child: const ListTile(
          leading: Icon(Icons.color_lens_outlined),
          title: Text('Change Color'),
        ),
      ),
    ]);

    return options;
  }

  void _handleOptionSelect(Organigrama item, dynamic value, context) {
    switch (value) {
      case 'remove':
        _removeNode(item, context);
        break;
      case 'edit':
        _handleEditNode(item, context);
        break;
      case 'add':
        _addChildNode(item, context);
        break;
      case 'color':
        _changeNodeColor(item, context);
        break;
    }
  }

  void _removeNode(Organigrama item, context) {
    try {
      controller.controllerChart.removeItem(
        item.id.toString(),
        ActionOnNodeRemoval.removeDescendants,
      );
    } catch (e) {
      _showError('Failed to remove node: ${e.toString()}', context);
    }
  }

  /// Edit an existing node
  void _handleEditNode(Organigrama item, context) async {
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

  void _addChildNode(Organigrama item, context) async {
    final result = await showDialog<Organigrama>(
      context: context,
      builder: (context) => NodeDialog(
        title: 'Add Child Node',
        initialParentId: item.name,
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

  /// Show dialog to add a new node
  void _showAddNodeDialog(context) async {
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

  /// Change the color of a node
  void _changeNodeColor(Organigrama item, context) async {
    final result = await showDialog<Color?>(
      context: context,
      builder: (context) =>
          ColorPickerDialog(colorOptions: controller.colorOptions),
    );

    if (result != null) {
      item.color = result.toString();
    }
  }

  /// Show the instructions dialog
  void _showInstructions(context) {
    showDialog(
      context: context,
      builder: (context) => const InstructionsDialog(),
    );
  }

  /// Show an error dialog
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
