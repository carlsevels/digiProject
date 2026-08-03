class Organigrama {
  int? id;
  int? parent;
  String? name;
  String? color;
  String? created_at;
  String? employee_id;
  String? email;
  String? user_created_at;
  String? nombre;
  String? apellidoMaterno;
  String? apellidoPaterno;

  Organigrama({
    this.id,
    this.parent,
    this.name,
    this.color,
    this.created_at,
    this.employee_id,
    this.email,
    this.user_created_at,
    this.nombre,
    this.apellidoMaterno,
    this.apellidoPaterno,
  });

  Organigrama.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    parent = (json['parent'] is String) ? int.tryParse(json['parent']) : json['parent'];
    name = json['name'];
    color = json['color'];
    created_at = json['created_at'];
    employee_id = json['employee_id'];
    email = json['email'];
    user_created_at = json['user_created_at'];
    nombre = json['nombre'];
    apellidoMaterno = json['apellidoMaterno'];
    apellidoPaterno = json['apellidoPaterno'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['parent'] = parent;
    data['name'] = name;
    data['color'] = color;
    data['created_at'] = created_at;
    data['employee_id'] = employee_id;
    data['email'] = email;
    data['user_created_at'] = user_created_at;
    data['nombre'] = nombre;
    data['apellidoMaterno'] = apellidoMaterno;
    data['apellidoPaterno'] = apellidoPaterno;
    return data;
  }
}