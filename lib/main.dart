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

  await Supabase.initialize(
    url: 'https://qraxigpgdckpnoisacqc.supabase.co',
    anonKey: 'sb_publishable_O52dOsup-TjPfGQCMhvFFQ_GiEe6TuX',
  );

  final supabase = Supabase.instance.client;

  await Supabase.initialize(
    url: 'https://qraxigpgdckpnoisacqc.supabase.co',
    anonKey: 'sb_publishable_O52dOsup-TjPfGQCMhvFFQ_GiEe6TuX',
  );

  await AppDatabase.initialize();
  final bool tieneSesion = supabase.auth.currentUser != null;
  final String rutaInicial = tieneSesion ? Routes.FOLIOS : Routes.LOGIN;

  if (tieneSesion) {
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
