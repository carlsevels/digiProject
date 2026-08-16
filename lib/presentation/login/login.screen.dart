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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWeb = constraints.maxWidth > 800;

              if (isWeb) {
                // --- DISEÑO RESPONSIVO PARA WEB / ESCRITORIO ---
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 440),
                      padding: const EdgeInsets.all(36.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: _buildLoginForm(),
                    ),
                  ),
                );
              } else {
                // --- DISEÑO RESPONSIVO PARA MÓVIL ---
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _buildLoginForm(),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // Widget reutilizable con los elementos del formulario
  Widget _buildLoginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 130,
          child: Image.asset(
            "assets/logos/digiApp.jpeg",
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "Bienvenido",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: controller.emailController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
            labelText: "Usuario",
          ),
        ),
        const SizedBox(height: 16),
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
        SizedBox(
          height: 50,
          child: FilledButton(
            style: FilledButton.styleFrom(
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}