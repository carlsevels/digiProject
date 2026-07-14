import 'package:supabase_flutter/supabase_flutter.dart';

class Routes {
  static Future<String> get initialRoute async {
    // TODO: implement method
    return LOGIN;
  }

  static const ADD_CLIENTE = '/add-cliente';
  static const ADD_FOLIOS = '/add-folios';
  static const FOLIOS = '/folios';
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const PROFILE = '/profile';
  static const DETALLES_FOLIO = '/detalles-folio';
}
