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
  });

  Direcciones.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    calle = json['calle'];
    clienteId = json['clienteId'];
    codigoPostal = json['codigoPostal'];
    colonia = json['colonia'];
    municipioId = json['municipioId'];
    numExt = json['numExt'];
    numInt = json['numInt'];
    created_at = json['created_at'];
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
    return data;
  }
}
