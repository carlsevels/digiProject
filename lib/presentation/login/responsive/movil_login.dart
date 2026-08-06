import 'package:bitacora_frontend/presentation/login/controllers/login.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MovilLoginVew extends GetView<LoginController> {
  const MovilLoginVew({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- LOGO / IMAGEN ---
                Center(
                  child: SizedBox(
                    height: 120,
                    child: Image.asset(
                      "assets/logos/digiApp.jpeg",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- TÍTULO ---
                const Text(
                  "Bienvenido",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // --- CAMPO USUARIO ---
                TextFormField(
                  controller: controller.emailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                    labelText: "Usuario",
                  ),
                ),

                const SizedBox(height: 16),

                // --- CAMPO CONTRASEÑA ---
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

                const SizedBox(height: 24),

                // --- BOTÓN ENTRAR ---
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: const Color(0XFF1D6CFF),
                    ),
                    onPressed: () {
                      controller.signInWithEmail();
                    },
                    child: const Text(
                      "Entrar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}