class StatusModel {
  int? id;
  String? createdAt;
  String? nombre;
  String? color;

  StatusModel({
    this.id,
    this.createdAt,
    this.nombre,
    this.color,
  });

  StatusModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at']?.toString();
    nombre = json['nombre']?.toString();
    color = json['color']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'nombre': nombre,
      'color': color,
    };
  }
}