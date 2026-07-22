class Direcciones {
  int? id;
  String? calle;
  String? colonia;
  String? codigoPostal;
  String? numExt;
  String? numInt;
  String? municipioId;
  String? clienteId;
  String? created_at;
  String? municipio;

  Direcciones({
    this.id,
    this.calle,
    this.clienteId,
    this.created_at,
    this.codigoPostal,
    this.colonia,
    this.municipioId,
    this.numExt,
    this.numInt,
    this.municipio,
  });

  Direcciones.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    calle = json['calle']?.toString();
    clienteId = json['clienteId']?.toString();
    codigoPostal = json['codigoPostal']?.toString();
    colonia = json['colonia']?.toString();
    municipioId = json['municipioId']?.toString();
    numExt = json['numExt']?.toString();
    numInt = json['numInt']?.toString();
    created_at = json['created_at']?.toString();
    municipio = json['municipio']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['calle'] = calle;
    data['clienteId'] = clienteId;
    data['codigoPostal'] = codigoPostal;
    data['colonia'] = colonia;
    data['municipioId'] = municipioId;
    data['numExt'] = numExt;
    data['numInt'] = numInt;
    data['created_at'] = created_at;
    data['municipio'] = municipio;
    return data;
  }
}
