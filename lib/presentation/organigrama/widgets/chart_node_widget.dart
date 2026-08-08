import 'package:bitacora_frontend/infrastructure/models/organigrama.dart';
import 'package:flutter/material.dart';
import 'package:org_chart/org_chart.dart';

class ChartNodeWidget extends StatelessWidget {
  final NodeBuilderDetails<Organigrama> details;
  final double cornerRadius;

  const ChartNodeWidget({
    super.key,
    required this.details,
    this.cornerRadius = 8.0,
  });

  Color _parseColor(String? colorStr) {
    switch (colorStr?.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'cyan':
        return Colors.cyan;
      case 'amber':
        return Colors.amber;
      case 'brown':
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Organigrama model = details.item;

    final Color nodeColor = _parseColor(model.color);
    final String positionName = model.name ?? 'Puesto';
    final bool isOccupied = model.nombre != null && model.nombre!.isNotEmpty;
    final String displayName = isOccupied
        ? '${model.nombre} ${model.apellidoPaterno ?? ''} ${model.apellidoMaterno ?? ''}'
              .trim()
        : positionName;

    return SizedBox(
      width: 180,
      height: 90,
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.zero,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
          side: BorderSide(
            color: isOccupied ? nodeColor.withAlpha(150) : Colors.white,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isOccupied ? nodeColor : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isOccupied ? Icons.person : Icons.person_add_disabled,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: isOccupied ? Colors.black87 : Colors.grey[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
