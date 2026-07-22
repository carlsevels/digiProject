class Clientes {
  int? id;
  String? nombreComercial;
  String? razonSocial;
  String? createdAt;
  String? calle;
  String? colonia;
  String? codigoPostal;
  String? numExt;
  String? numInt;
  int? municipioId;
  int? clienteId;
  String? municipio;

  Clientes({
    this.id,
    this.nombreComercial,
    this.razonSocial,
    this.createdAt,
    this.calle,
    this.colonia,
    this.codigoPostal,
    this.numExt,
    this.numInt,
    this.municipioId,
    this.clienteId,
    this.municipio,
  });

  factory Clientes.fromJson(Map<String, dynamic> json) {
    return Clientes(
      id: (json['id'] is String) ? int.tryParse(json['id'] ?? '') : json['id'],
      nombreComercial: json['nombreComercial'],
      razonSocial: json['razonSocial'],
      createdAt: json['created_at'],
      // Mapeo basado en los alias del SQL (dirCalle, dirColonia, etc.)
      calle: json['dirCalle'],
      colonia: json['dirColonia'],
      codigoPostal: json['dirCp'],
      numExt: json['dirNumExt']?.toString(),
      numInt: json['dirNumInt']?.toString(),
      // Estos campos se mantienen para lógica interna si es necesario
      municipioId: (json['municipioId'] is String)
          ? int.tryParse(json['municipioId'] ?? '')
          : json['municipioId'],
      clienteId: (json['clienteId'] is String)
          ? int.tryParse(json['clienteId'] ?? '')
          : json['clienteId'],
      municipio: json['municipio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreComercial': nombreComercial,
      'razonSocial': razonSocial,
      'created_at': createdAt,
      'dirCalle': calle,
      'dirColonia': colonia,
      'dirCp': codigoPostal,
      'dirNumExt': numExt,
      'dirNumInt': numInt,
      'municipioId': municipioId,
      'clienteId': clienteId,
      'municipio': municipio,
    };
  }
}
