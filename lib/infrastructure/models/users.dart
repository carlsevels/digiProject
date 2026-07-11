class Users {
  int? id;
  String? nombre;
  String? apellidoPaterno;
  String? apellidoMaterno;
  int? rolId;
  String? userId;

  Users({
    this.id,
    this.nombre,
    this.apellidoPaterno,
    this.apellidoMaterno,
    this.rolId,
    this.userId,
  });

  Users.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    nombre = json['nombre'];
    apellidoPaterno = json['apellidoPaterno'];
    apellidoMaterno = json['apellidoMaterno'];
    rolId = json['rolId'];
    userId = json['userId']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['nombre'] = nombre;
    data['apellidoPaterno'] = apellidoPaterno;
    data['apellidoMaterno'] = apellidoMaterno;
    data['rolId'] = rolId;
    data['userId'] = userId;
    return data;
  }
}
