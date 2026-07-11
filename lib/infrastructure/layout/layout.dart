import 'package:bitacora_frontend/infrastructure/layout/layoutExterno.dart';
import 'package:bitacora_frontend/infrastructure/layout/layoutInterno.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Layout extends StatelessWidget {
  final Widget? child;
  Layout({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    // Initialize an observable variable for the session
    final Rxn<Session> currentSession = Rxn<Session>(
      Supabase.instance.client.auth.currentSession,
    );

    // Listen to Supabase auth changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      currentSession.value = data.session;
    });

    return Obx(() {
      // Now Obx will trigger a rebuild whenever currentSession changes
      return currentSession.value != null
          ? LayoutInterno(child: child!)
          : LayoutExterno(child: child!);
    });
  }
}
