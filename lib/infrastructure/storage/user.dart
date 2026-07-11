import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const String _keyNombre = 'nombre_usuario';
  static const String _keyRol = 'rol';

  // Guardar nombre
  static Future<void> guardarNombre(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNombre, nombre);
  }

  // Obtener nombre
  static Future<String?> obtenerNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNombre);
  }

   // Guardar rol
  static Future<void> guardarRol(String rol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRol, rol);
  }

  //Obtener rol
  static Future<String?> obtenerRol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRol);
  }
}