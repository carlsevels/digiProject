class Folios {
  int? id;
  String? cantidad;
  String? tipofolio;
  String? nombreComercial;
  String? tiporefaccion;
  String? tiporeporte;
  String? condicionPago;
  String? status;
  String? creador;
  String? repartidor;
  String? created_at;
  String? municipio;
  String? statusColor;

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
  });

  Folios.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is int) ? json['id'] : int.tryParse(json['id'].toString());
    cantidad = json['cantidad'];
    tipofolio = json['tipofolio'];
    nombreComercial = json['nombreComercial'];
    tiporefaccion = json['tipoRefaccion'];
    tiporeporte = json['tipoReporte'];
    condicionPago = json['condicionPago'];
    status = json['status'];
    creador = json['creador'];
    repartidor = json['repartidor'];
    created_at = json['created_at'];
    municipio = json['municipio'];
    statusColor = json['statusColor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cantidad'] = cantidad;
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
    data['statusColor'] = statusColor;
    return data;
  }
}
