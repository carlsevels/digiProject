import 'package:bitacora_frontend/infrastructure/models/status.dart';

class HistorialEstado {
  String? id;
  String? createdAt;
  int? statusid;
  String? hora;
  String? descripcion;
  String? foliold;
  StatusModel? status;

  HistorialEstado({
    this.id,
    this.createdAt,
    this.statusid,
    this.hora,
    this.descripcion,
    this.foliold,
    this.status,
  });

  HistorialEstado.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    createdAt = json['created_at']?.toString();
    
    // Soportamos variaciones en las llaves (statusid / statusId)
    final sId = json['statusid'] ?? json['statusId'];
    statusid = sId != null ? int.tryParse(sId.toString()) : null;

    hora = json['hora']?.toString();
    descripcion = json['descripcion']?.toString();
    
    // Soportamos variaciones para el folio (foliold / folioId)
    foliold = (json['foliold'] ?? json['folioId'])?.toString();

    // Verificamos si 'status' viene como un Map completo o si debemos construirlo con campos planos
    if (json['status'] is Map<String, dynamic>) {
      status = StatusModel.fromJson(json['status']);
    } else if (json['status'] is String) {
      // Si por alguna razón viene como texto plano, creamos el StatusModel manualmente
      status = StatusModel(
        nombre: json['status'],
        color: json['statuscolor']?.toString() ?? '0xFF1D6CFF',
      );
    } else {
      status = null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'statusid': statusid,
      'hora': hora,
      'descripcion': descripcion,
      'foliold': foliold,
      'status': status?.toJson(),
    };
  }
}