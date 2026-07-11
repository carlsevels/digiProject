class GeneralModel {
  int? id;
  String? nombre;
  String? color;
  String? created_at;

  GeneralModel({this.id, this.nombre, this.color, this.created_at});

  GeneralModel.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    nombre = json['nombre'];
    color = json['color'];
    created_at = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['nombre'] = nombre;
    data['color'] = color;
    data['created_at'] = created_at;
    return data;
  }
}
