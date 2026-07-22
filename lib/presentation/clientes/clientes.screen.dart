import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/clientes.controller.dart';

class ClientesScreen extends GetView<ClientesController> {
  const ClientesScreen({super.key});

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
            onRefresh: () => controller.getClientes(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: list.isEmpty ? 2 : list.length + 2,
              itemBuilder: (context, index) {
                // Header
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.business, color: Color(0XFF64748B)),
                              SizedBox(width: 12),
                              Text(
                                "Clientes",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0XFF334155),
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => Get.toNamed(Routes.ADD_CLIENTE),
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

                // Buscador
                if (index == 1) {
                  return Column(
                    children: [
                      TextFormField(
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.search),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0XFF64748B)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0XFF64748B)),
                          ),
                          hintText: "Buscar cliente",
                          hintStyle: TextStyle(color: Color(0XFF64748B)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                // Lista de Clientes
                final cliente = list[index - 2];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0XFF0F172A),
                    child: Text(
                      (cliente.nombreComercial?.isNotEmpty ?? false)
                          ? cliente.nombreComercial![0].toUpperCase()
                          : "?",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(cliente.nombreComercial ?? "Sin nombre"),
                  subtitle: Text(cliente.municipio ?? "Sin ubicación"),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => _mostrarDialogoEliminar(context, cliente),
                  ),
                );
              },
            ),
          ),
        );
      },
      onLoading: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      onEmpty: const Scaffold(
        body: Center(child: Text("No hay clientes registrados")),
      ),
      onError: (error) => Scaffold(
        body: Center(
          child: Text("Error al cargar: $error", textAlign: TextAlign.center),
        ),
      ),
    );
  }

  void _mostrarDialogoEliminar(BuildContext context, dynamic cliente) {
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
                'Eliminar Cliente',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '¿Estás seguro de eliminar este cliente? Esta acción no se puede deshacer.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Color(0XFF64748B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // controller.eliminarCliente(cliente.id.toString());
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Eliminar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
