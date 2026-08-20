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
    this.colonia,
    this.codigoPostal,
    this.numExt,
    this.numInt,
  });

  Folios.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    cantidad = json['cantidad']?.toString();
    created_at = json['created_at']?.toString();
    folioId = json['folioId']?.toString();
    folioIdHistorial = json['folio_id_historial']?.toString();

    // Mapeo robusto para isArchived (bool, int o String)
    final rawArchived = json['isArchived'];
    if (rawArchived is bool) {
      isArchived = rawArchived;
    } else if (rawArchived is int) {
      isArchived = rawArchived == 1;
    } else if (rawArchived != null) {
      final str = rawArchived.toString().toLowerCase();
      isArchived = str == 'true' || str == '1';
    } else {
      isArchived = false;
    }

    // 1. Extracción de la relación 'clientes' y sus 'direcciones' en formato lista
    final cliente = json['clientes'] is Map ? json['clientes'] : {};
    nombreComercial = cliente['nombreComercial']?.toString() ?? json['nombreComercial']?.toString();

    final direccionesList = cliente['direcciones'] is List ? cliente['direcciones'] as List : [];
    if (direccionesList.isNotEmpty) {
      final dir = direccionesList.first is Map ? direccionesList.first : {};
      calle = dir['calle']?.toString();
      colonia = dir['colonia']?.toString();
      codigoPostal = dir['codigoPostal']?.toString();
      numExt = dir['numExt']?.toString();
      numInt = dir['numInt']?.toString();

      final muni = dir['municipios'] is Map ? dir['municipios'] : {};
      municipio = muni['nombre']?.toString();
    } else {
      municipio = json['municipio']?.toString();
      calle = json['calle']?.toString();
      colonia = json['colonia']?.toString();
      codigoPostal = json['codigoPostal']?.toString();
      numExt = json['numExt']?.toString();
      numInt = json['numInt']?.toString();
    }

    // 2. Extracción de catálogos
    final condPago = json['condicionPago'] is Map ? json['condicionPago'] : {};
    condicionPago = condPago['nombre']?.toString() ?? json['condicionPago']?.toString();

    final refaccion = json['typeRefaccion'] is Map ? json['typeRefaccion'] : {};
    tiporefaccion = refaccion['nombre']?.toString() ?? json['tipoRefaccion']?.toString();

    final tFolio = json['tipofolio'] is Map ? json['tipofolio'] : {};
    tipofolio = tFolio['nombre']?.toString() ?? json['tipofolio']?.toString();

    tiporeporte = json['tipoReporte']?.toString();
    creador = json['creador']?.toString();
    repartidor = json['repartidor']?.toString();

    // 3. Extracción de estatus (Soporta lista de historial o registro directo del historial)
    final historialList = json['historialestados'] is List ? json['historialestados'] as List : [];
    
    if (historialList.isNotEmpty) {
      final ultimoEstado = historialList.last is Map ? historialList.last : {};
      statusId = ultimoEstado['statusId']?.toString();
      
      final estadoRelacion = ultimoEstado['status'] is Map ? ultimoEstado['status'] : {};
      status = estadoRelacion['nombre']?.toString();
      statusColor = estadoRelacion['color']?.toString() ?? ultimoEstado['statusColor']?.toString();
    } else if (json['status'] is Map) {
      // Si viene directamente de la consulta de la tabla 'historialestados'
      final estadoRelacion = json['status'] as Map;
      statusId = json['statusId']?.toString() ?? json['status_id']?.toString();
      status = estadoRelacion['nombre']?.toString();
      statusColor = estadoRelacion['color']?.toString() ?? json['statusColor']?.toString() ?? json['statuscolor']?.toString();
    } else {
      statusId = json['statusid']?.toString();
      status = json['status']?.toString();
      statusColor = json['statusColor']?.toString() ?? json['statuscolor']?.toString();
    }
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