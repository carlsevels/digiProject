import 'package:bitacora_frontend/infrastructure/models/organigrama.dart';
import 'package:flutter/material.dart';

/// Dialog for adding or editing nodes
class NodeDialog extends StatefulWidget {
  final String title;
  final String initialName;
  final String? initialParentId;
  final List<Organigrama> availableParents;
  final bool isNewNode;

  const NodeDialog({
    super.key,
    required this.title,
    this.initialName = '',
    this.initialParentId,
    required this.availableParents,
    required this.isNewNode,
  });

  @override
  State<NodeDialog> createState() => _NodeDialogState();
}

class _NodeDialogState extends State<NodeDialog> {
  late final TextEditingController textController;
  String? parentId;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.initialName);
    parentId = widget.initialParentId;
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: textController,
            decoration: const InputDecoration(labelText: 'Node Name'),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          if (widget.isNewNode)
            DropdownButtonFormField<String?>(
              decoration: const InputDecoration(labelText: 'Parent Node'),
              initialValue: parentId,
              items: [
                const DropdownMenuItem(value: null, child: Text('Root Node')),
                ...widget.availableParents.map(
                  (item) => DropdownMenuItem(
                    value: item.id.toString(),
                    child: Text(item.name ?? ""),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  parentId = value;
                });
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (textController.text.trim().isNotEmpty) {
              Navigator.pop(context, {
                'name': textController.text.trim(),
                'parentId': parentId,
              });
            }
          },
          child: Text(widget.isNewNode ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}

/// Dialog for changing node color
class ColorPickerDialog extends StatelessWidget {
  final List<Color> colorOptions;

  const ColorPickerDialog({super.key, required this.colorOptions});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Color'),
      content: SizedBox(
        width: 300,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: colorOptions.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => Navigator.pop(context, colorOptions[index]),
              child: CircleAvatar(backgroundColor: colorOptions[index]),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Instructions dialog
class InstructionsDialog extends StatelessWidget {
  const InstructionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Instrucciones'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _instructionItem(
            context,
            'Toca un nodo para ocultar/mostrar sus hijos (si tiene)',
          ),
          _instructionItem(
            context,
            'Haz clic derecho / mantén presionado un nodo para más opciones',
          ),
          _instructionItem(
            context,
            'Arrastra los nodos para reorganizarlos (si está habilitado)',
          ),
          _instructionItem(
            context,
            'Usa la barra lateral para personalizar el gráfico',
          ),
          _instructionItem(
            context,
            'Pellizca para hacer zoom (si está habilitado)',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    );
  }

  Widget _instructionItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.arrow_right, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(child: Text(text)),
        ],
      ),
    );
  }
}
