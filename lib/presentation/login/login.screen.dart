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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: Get.size.width,
                height: Get.size.height / 3,
                child: Image.asset("assets/logos/digirey.png"),
              ),
              Flexible(
                child: Container(
                  height: Get.size.height / 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Bienvenido", textScaleFactor: 2),
                      TextFormField(
                        controller: controller.emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                          label: Text("Usuario"),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        controller: controller.passwordController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.password_outlined),
                          border: OutlineInputBorder(),
                          label: Text("Contraseña"),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Center(
                        child: Container(
                          width: Get.size.width,
                          child: FilledButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              backgroundColor: Color(0XFF1D6CFF),
                            ),
                            onPressed: () {
                              controller.signInWithEmail();
                            },
                            child: Text("Entrar"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
