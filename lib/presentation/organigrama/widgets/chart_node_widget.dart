import 'dart:math';
import 'package:flutter/material.dart';
import 'package:org_chart/org_chart.dart';

class ChartNodeWidget extends StatelessWidget {
  final NodeBuilderDetails<Map<String, dynamic>> details;
  final double cornerRadius;

  const ChartNodeWidget({
    super.key,
    required this.details,
    this.cornerRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final Color nodeColor = (details.item['color'] as Color?) ?? Colors.blue;
    final String positionName = (details.item['name'] ?? 'Puesto').toString();

    // Validamos de forma segura si el empleado existe o es null
    final dynamic employeeData = details.item['employee'];
    final bool isOccupied = employeeData != null;

    final String displayName = isOccupied
        ? (employeeData['name'] ?? '').toString()
        : '';

    final String displayPhoto = isOccupied
        ? (employeeData['photo'] ?? '').toString()
        : '';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
        side: BorderSide(
          color: isOccupied
              ? nodeColor.withAlpha(100)
              : Colors.grey.withAlpha(100),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => details.hideNodes(center: false),
        child: Container(
          color: details.isBeingDragged
              ? Colors.green.withAlpha(80)
              : details.isOverlapped
              ? Colors.red.withAlpha(80)
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isOccupied ? nodeColor : Colors.grey[400],
                  shape: BoxShape.circle,
                  image: displayPhoto.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(displayPhoto),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: displayPhoto.isEmpty
                    ? Center(
                        child: Icon(
                          isOccupied ? Icons.person : Icons.person_add_disabled,
                          size: 16,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                isOccupied ? displayName : positionName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: isOccupied ? Colors.black87 : Colors.grey[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isOccupied) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DISPONIBLE',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
