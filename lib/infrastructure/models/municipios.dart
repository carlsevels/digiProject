class Municipios {
  int? id;
  String? nombre;
  String? created_at;

  Municipios({this.id, this.nombre, this.created_at});

  Municipios.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    nombre = json['nombre'];
    created_at = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['nombre'] = nombre;
    data['created_at'] = created_at;
    return data;
  }
}
