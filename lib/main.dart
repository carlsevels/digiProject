import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:powersync/powersync.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await initializeDateFormatting('es', "");

  await Supabase.initialize(
    url: 'https://qraxigpgdckpnoisacqc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFyYXhpZ3BnZGNrcG5vaXNhY3FjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI5MjA1MzMsImV4cCI6MjA5ODQ5NjUzM30.MGW4lO0aYTReI5pT393kMOoW0hgZ4R0OFFwroNpkmoo',
  );

  if (!kIsWeb) {
    await AppDatabase.initialize();
  } else {
    // TODO: Si estás usando Drift/SQLite en Web, aquí debes inicializar
    // la versión compatible con WebAssembly (WASM) / IndexedDB.
  }

  final supabase = Supabase.instance.client;
  final session = supabase.auth.currentSession;

  if (session != null) {
    if (kIsWeb) {
      await AppDatabase.initialize();
    }

    await AppDatabase.db.connect(connector: MyBackendConnector(AppDatabase.db));

    await AppDatabase.db.waitForFirstSync();
  }

  runApp(Main(session != null ? Routes.FOLIOS : Routes.LOGIN));
}

void setupAuthListener(BuildContext context) {
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final AuthChangeEvent event = data.event;
    final Session? session = data.session;

    if (event == AuthChangeEvent.signedOut || session == null) {
      print("La sesión caducó o expiró");
      
      try {
        await AppDatabase.db.disconnect();
      } catch (e) {
        print("Error al desconectar PowerSync: $e");
      }

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.LOGIN, 
          (route) => false,
        );
      }
    }
  });
}

void cerrarSesionSinBorrarLocales(BuildContext context) async {
  try {
    await AppDatabase.db.disconnect();

    await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
  } catch (e) {
    print("Error al cerrar sesión de forma segura: $e");
  }

  if (context.mounted) {
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.LOGIN, (route) => false);
  }
}

class Main extends StatefulWidget {
  final String initialRoute;
  Main(this.initialRoute);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  void initState() {
    super.initState();
    setupAuthListener(context);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: widget.initialRoute,
      getPages: Nav.routes,
      locale: const Locale('es', 'ES'),
      debugShowCheckedModeBanner: false,
    );
  }
}