import 'package:bitacora_frontend/presentation/login/responsive/movil_login.dart';
import 'package:bitacora_frontend/presentation/login/responsive/web_login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/login.controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: kIsWeb ? WebLoginView() : MovilLoginVew(),
      ),
      onLoading: Scaffold(
        backgroundColor: Colors.white,
        body: kIsWeb ? WebLoginView() : MovilLoginVew(),
      ),
      onError: (error) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text("Error: $error")),
      ),
      onEmpty: Scaffold(
        backgroundColor: Colors.white,
        body: kIsWeb ? WebLoginView() : MovilLoginVew(),
      ),
    );
  }
}