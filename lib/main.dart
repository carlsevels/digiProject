import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', "");

  await Supabase.initialize(
    url: 'https://qraxigpgdckpnoisacqc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFyYXhpZ3BnZGNrcG5vaXNhY3FjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI5MjA1MzMsImV4cCI6MjA5ODQ5NjUzM30.MGW4lO0aYTReI5pT393kMOoW0hgZ4R0OFFwroNpkmoo',
  );

  await AppDatabase.initialize();

  final supabase = Supabase.instance.client;
  final session = supabase.auth.currentSession;

  if (session != null) {
    await AppDatabase.initialize();

    await AppDatabase.db.connect(connector: MyBackendConnector(AppDatabase.db));

    await AppDatabase.db.waitForFirstSync();
  }

  runApp(Main(session != null ? Routes.FOLIOS : Routes.LOGIN));
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
