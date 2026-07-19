import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/refacciones.controller.dart';

class RefaccionesScreen extends GetView<RefaccionesController> {
  const RefaccionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) {
        final list = state ?? [];

        return Scaffold(
          appBar: AppBar(
            title: SizedBox(
              width: 120,
              child: Image.network(
                fit: BoxFit.contain,
                "https://lirp.cdn-website.com/d83902d6/dms3rep/multi/opt/logotipo-157w.png",
              ),
            ),
            centerTitle: true,
          ),
          body: RefreshIndicator(
            color: Colors.white,
            backgroundColor: const Color(0XFF1D6CFF),
            onRefresh: () => controller.getRefacciones(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: list.isEmpty ? 3 : list.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
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
                  );
                }

                if (index == 1) {
                  return Column(
                    children: [
                      TextFormField(
                        controller: controller.nombreController,
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                          controller.getRefacciones();
                        },
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              controller.getRefacciones();
                            },
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
                  );
                }

                final refaccion = list[index - 2];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0XFF0F172A),
                    child: Text(
                      refaccion.nombre!.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Color(0xFFFEE2E2),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 40,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Eliminar Refacción',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  '¿Estás seguro de eliminar esta refacción? Esta acción no se puede deshacer.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text(
                                          'Cancelar',
                                          style: TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                          controller.eliminarRefaccion(
                                            refaccion.id.toString(),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFDC2626,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Eliminar',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  title: Text(refaccion.nombre.toString()),
                );
              },
            ),
          ),
        );
      },
      onLoading: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      onEmpty: Scaffold(
        appBar: AppBar(
          title: SizedBox(
            width: 120,
            child: Image.network(
              fit: BoxFit.contain,
              "https://lirp.cdn-website.com/d83902d6/dms3rep/multi/opt/logotipo-157w.png",
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
