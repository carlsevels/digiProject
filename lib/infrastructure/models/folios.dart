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
  bool? isArchived;
  String? calle;
  String? colonia;
  String? codigoPostal;
  String? numExt;
  String? numInt;

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
    this.calle,
    this.codigoPostal,
    this.colonia,
    this.numExt,
    this.numInt,
  });

  Folios.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    calle = json['calle']?.toString();
    codigoPostal = json['codigoPostal']?.toString();
    colonia = json['colonia']?.toString();
    numExt = json['numExt']?.toString();
    numInt = json['numInt']?.toString();
    cantidad = json['cantidad']?.toString();
    statusId = json['statusid']?.toString();
    tipofolio = json['tipofolio']?.toString();

    // Mapeo robusto que soporta bool, int (1/0) y String desde PowerSync/Supabase
    final rawArchived = json['isArchived'];
    if (rawArchived is bool) {
      isArchived = rawArchived;
    } else if (rawArchived is int) {
      isArchived = rawArchived == 1; // 1 es true, 0 es false
    } else if (rawArchived != null) {
      final str = rawArchived.toString().toLowerCase();
      isArchived = str == 'true' || str == '1';
    } else {
      isArchived = false;
    }

    nombreComercial = json['nombreComercial']?.toString();
    
    // Acepta ambas variantes (con mayúscula o minúscula) desde el JSON
    tiporefaccion = (json['tipoRefaccion'] ?? json['tiporefaccion'])?.toString();
    
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
    data['calle'] = calle;
    data['codigoPostal'] = codigoPostal;
    data['colonia'] = colonia;
    data['numExt'] = numExt;
    data['numInt'] = numInt;
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