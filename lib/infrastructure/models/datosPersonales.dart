class DatosPersonales {
  int? id;
  String? createdAt;
  String? nombre;
  String? apellidoPaterno;
  String? apellidoMaterno;
  String? userId;
  int? rolId;
  String? nombreRol; 

  DatosPersonales({
    this.id,
    this.createdAt,
    this.nombre,
    this.apellidoPaterno,
    this.apellidoMaterno,
    this.userId,
    this.rolId,
    this.nombreRol,
  });

  DatosPersonales.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    createdAt = json['created_at'];
    nombre = json['nombre'];
    apellidoPaterno = json['apellidoPaterno'];
    apellidoMaterno = json['apellidoMaterno'];
    userId = json['userId'];
    rolId = (json['rolId'] is String) ? int.tryParse(json['rolId']) : json['rolId'];
    nombreRol = json['nombre_rol'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['nombre'] = nombre;
    data['apellidoPaterno'] = apellidoPaterno;
    data['apellidoMaterno'] = apellidoMaterno;
    data['userId'] = userId;
    data['rolId'] = rolId;
    data['nombre_rol'] = nombreRol;
    return data;
  }
}