import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var initialRoute = await Routes.initialRoute;
  await AppDatabase.initialize();
  await Supabase.initialize(
    url: 'https://qraxigpgdckpnoisacqc.supabase.co',
    anonKey: 'sb_publishable_O52dOsup-TjPfGQCMhvFFQ_GiEe6TuX',
  );
  runApp(Main(initialRoute));
}

class Main extends StatelessWidget {
  final String initialRoute;
  Main(this.initialRoute);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: initialRoute,
      getPages: Nav.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
