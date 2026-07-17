import 'dart:async';

import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LayoutInternoController extends GetxController
    with StateMixin<Map<String, dynamic>> {
  @override
  void onInit() async {
    super.onInit();
  }

  Future<void> signOutAllDevices() async {
    await Supabase.instance.client.auth.signOut(scope: SignOutScope.global);
    Get.toNamed(Routes.LOGIN);
  }
}
