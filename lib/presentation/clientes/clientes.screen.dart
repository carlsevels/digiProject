import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/clientes.controller.dart';

class ClientesScreen extends StatefulWidget { // Cambiado a StatefulWidget para manejar el ScrollController
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ClientesController controller = Get.find<ClientesController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreClientes();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
              controller: _scrollController, // <--- Conectado aquí
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              // Añadimos +1 al itemCount si está cargando más elementos
              itemCount: list.isEmpty ? 2 : list.length + 2 + (controller.isLoadingMore.value ? 1 : 0),
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
                        controller: controller.buscadorController,
                        onFieldSubmitted: (value) => controller.getClientes(),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => controller.getClientes(),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0XFF64748B)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0XFF64748B)),
                          ),
                          hintText: "Buscar cliente",
                          hintStyle: const TextStyle(color: Color(0XFF64748B)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                // Indicador de carga al final del scroll
                if (index == list.length + 2) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // Lista de Clientes
                final cliente = list[index - 2];
                return ListTile(
                  titleAlignment: ListTileTitleAlignment.top,
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
                  title: Text("${cliente.id} - ${cliente.nombreComercial} - ${cliente.razonSocial}"),
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
                  ),
                  Column(
                    children: [
                      TextFormField(
                        controller: controller.buscadorController,
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: (value) => controller.getClientes(),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => controller.getClientes(),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0XFF64748B)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0XFF64748B)),
                          ),
                          hintText: "Buscar cliente",
                          hintStyle: const TextStyle(color: Color(0XFF64748B)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0XFFEFF6FF),
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
                  const SizedBox(height: 23),
                  const Text(
                    "No hay clientes",
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
                      "Todavía no has registrado ningún cliente.",
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