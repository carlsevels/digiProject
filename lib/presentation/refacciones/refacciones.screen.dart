import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/refacciones/responsive/movil_refacciones.dart';
import 'package:bitacora_frontend/presentation/refacciones/responsive/web_refacciones.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/refacciones.controller.dart';

class RefaccionesScreen extends GetView<RefaccionesController> {
  const RefaccionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) {
        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Color(0XFF64748B)),
            centerTitle: false,
            scrolledUnderElevation: 0.0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(color: Colors.grey.shade200, height: 1.0),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xff1565C0).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.precision_manufacturing_outlined,
                    color: Color(0xff1565C0),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Refacciones",
                  style: TextStyle(
                    color: Color(0xff1565C0),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          body: kIsWeb ? WebRefaccionesView() : MovilRefaccionesView(),
        );
      },
      onLoading: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: SizedBox(
                  width: 120,
                  child: Image.asset(
                    fit: BoxFit.contain,
                    "assets/logos/digiApp.jpeg",
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),

      onEmpty: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: SizedBox(
            width: 120,
            child: Obx(
              () => Image.asset(
                fit: BoxFit.contain,
                controller.rolUsuario.value == 1
                    ? "assets/logos/digiAdmin.jpeg"
                    : "assets/logos/digiRepartidores.jpeg",
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.precision_manufacturing_outlined,
                                color: Color(0XFF64748B),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Refacciones",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0XFF334155),
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => Get.toNamed(Routes.ADD_REFACCION),
                            icon: const Icon(
                              Icons.add,
                              color: Color(0XFF1D6CFF),
                            ),
                            label: const Text(
                              "Agregar",
                              style: TextStyle(color: Color(0XFF1D6CFF)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                  Column(
                    children: [
                      TextFormField(
                        controller: controller.nombreController,
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: (value) =>
                            controller.getRefacciones(),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => controller.getRefacciones(),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0XFF64748B)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0XFF64748B)),
                          ),
                          hintText: "Buscar refaccion",
                          hintStyle: const TextStyle(color: Color(0XFF64748B)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0XFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: Color(0XFF1D6CFF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "No hay refacciones",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      "Todavía no has registrado ninguna refacción para el día seleccionado. Empieza creando la primera.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onError: (error) => Scaffold(body: Center(child: Text("Error: $error"))),
    );
  }
}
