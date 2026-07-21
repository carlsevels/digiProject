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
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: Get.size.width,
                  height: Get.size.height / 3.5,
                  child: Image.asset("assets/logos/digirey.png"),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Bienvenido", textScaleFactor: 2),

                    TextFormField(
                      controller: controller.emailController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                        labelText: "Usuario",
                      ),
                    ),

                    const SizedBox(height: 8),

                    Obx(
                      () => TextFormField(
                        obscureText: !controller.showPassword.value,
                        controller: controller.passwordController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.password_outlined),
                          suffixIcon: IconButton(
                            onPressed: () {
                              controller.showPassword.value =
                                  !controller.showPassword.value;
                            },
                            icon: Icon(
                              controller.showPassword.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.remove_red_eye_outlined,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                          labelText: "Contraseña",
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: Get.width,
                      child: FilledButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          backgroundColor: const Color(0XFF1D6CFF),
                        ),
                        onPressed: () {
                          controller.signInWithEmail();
                        },
                        child: const Text("Entrar"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
