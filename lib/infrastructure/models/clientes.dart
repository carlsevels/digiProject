class Clientes {
  int? id;
  String? nombreComercial;
  String? razonSocial;
  String? created_at;

  Clientes({this.id, this.nombreComercial, this.razonSocial, this.created_at});

  Clientes.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    nombreComercial = json['nombreComercial'];
    razonSocial = json['razonSocial'];
    created_at = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['nombreComercial'] = nombreComercial;
    data['razonSocial'] = razonSocial;
    data['created_at'] = created_at;
    return data;
  }
}
