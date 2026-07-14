import 'dart:io';

import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';

import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', "");

  // 1. Inicializar Supabase
  await Supabase.initialize(
    url: 'https://qraxigpgdckpnoisacqc.supabase.co',
    anonKey: 'sb_publishable_O52dOsup-TjPfGQCMhvFFQ_GiEe6TuX',
  );

  final supabase = Supabase.instance.client;

  // 2. RECUPERAR SESIÓN: Esto carga el usuario del almacenamiento local
  // Se usa recoverSession() para refrescar la sesión si existe
  await Supabase.initialize(
    url: 'https://qraxigpgdckpnoisacqc.supabase.co',
    anonKey: 'sb_publishable_O52dOsup-TjPfGQCMhvFFQ_GiEe6TuX',
  );

  // 4. Inicializar DB local
  await AppDatabase.initialize();
  //await hardResetApp();
  final bool tieneSesion = supabase.auth.currentUser != null;
  final String rutaInicial = tieneSesion ? Routes.HOME : Routes.LOGIN;

  if (tieneSesion) {
    print("✅ Usuario detectado: ${supabase.auth.currentUser!.id}");
    await AppDatabase.db.connect(connector: MyBackendConnector(AppDatabase.db));
  }

  runApp(Main(rutaInicial));
}
class Main extends StatelessWidget {
  final String initialRoute;
  Main(this.initialRoute);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: initialRoute,
      getPages: Nav.routes,
      locale: const Locale('es', 'ES'),
      debugShowCheckedModeBanner: false,
    );
  }
}
