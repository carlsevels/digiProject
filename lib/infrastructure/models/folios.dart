class Folios {
  String? id;
  String? cantidad;
  String? tipofolio;
  String? nombreComercial;
  String? tiporefaccion;
  String? tiporeporte;
  String? condicionPago;
  String? status;
  String? statusId;
  String? creador;
  String? repartidor;
  String? created_at;
  String? municipio;
  String? statusColor;
  String? folioId;
  String? folioIdHistorial;
  int? isArchived;

  Folios({
    this.id,
    this.cantidad,
    this.tipofolio,
    this.nombreComercial,
    this.tiporefaccion,
    this.tiporeporte,
    this.condicionPago,
    this.status,
    this.creador,
    this.repartidor,
    this.created_at,
    this.municipio,
    this.statusColor,
    this.folioId,
    this.statusId,
    this.folioIdHistorial,
    this.isArchived,
  });

  Folios.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    cantidad = json['cantidad']?.toString();
    statusId = json['statusid']?.toString();
    tipofolio = json['tipofolio']?.toString();
    isArchived = json['isArchived'] is bool 
        ? (json['isArchived'] ? 1 : 0) 
        : int.tryParse(json['isArchived']?.toString() ?? '0') ?? 0;
    nombreComercial = json['nombreComercial']?.toString();
    tiporefaccion = json['tipoRefaccion']?.toString();
    tiporeporte = json['tipoReporte']?.toString();
    condicionPago = json['condicionPago']?.toString();
    status = json['status']?.toString();
    creador = json['creador']?.toString();
    repartidor = json['repartidor']?.toString();
    created_at = json['created_at']?.toString();
    municipio = json['municipio']?.toString();
    statusColor = json['statuscolor']?.toString();
    folioId = json['folioId']?.toString();
    folioIdHistorial = json['folio_id_historial']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cantidad'] = cantidad;
    data['isArchived'] = isArchived;
    data['statusid'] = statusId;
    data['tipofolio'] = tipofolio;
    data['nombreComercial'] = nombreComercial;
    data['tipoRefaccion'] = tiporefaccion;
    data['tipoReporte'] = tiporeporte;
    data['condicionPago'] = condicionPago;
    data['status'] = status;
    data['creador'] = creador;
    data['repartidor'] = repartidor;
    data['created_at'] = created_at;
    data['municipio'] = municipio;
    data['statuscolor'] = statusColor;
    data['folioId'] = folioId;
    data['folio_id_historial'] = folioIdHistorial;
    return data;
  }
}