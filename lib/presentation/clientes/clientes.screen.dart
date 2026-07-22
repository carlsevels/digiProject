import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/clientes.controller.dart';

class ClientesScreen extends StatefulWidget {
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
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
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: list.isEmpty
                  ? 2
                  : list.length + 2 + (controller.isLoadingMore.value ? 1 : 0),
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

                if (index == list.length + 2) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final cliente = list[index - 2];
                return InkWell(
                  onLongPress: () async {
                    await controller.getDireccionCliente(
                      int.parse(cliente.id.toString()),
                    );
                    Get.defaultDialog(
                      backgroundColor: Color(0XFFF8FAFC),
                      title: "Detalles de Dirección",
                      titleStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF1D6CFF),
                      ),
                      middleText: "",
                      content: Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "${controller.direccion.calle ?? 'S/N'} #${controller.direccion.numExt ?? ''}"
                                    "${(controller.direccion.numInt != null && controller.direccion.numInt!.isNotEmpty) ? ' Int. ${controller.direccion.numInt}' : ''}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.map,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Colonia:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    controller.direccion.colonia ??
                                        "No especificada",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_city,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Municipio:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    controller.direccion.municipio ??
                                        "No especificado",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.markunread_mailbox,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "C.P.:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    controller.direccion.codigoPostal ??
                                        "No especificado",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      textConfirm: "Aceptar",
                      confirmTextColor: Colors.white,
                      buttonColor: Color(0XFF1D6CFF),
                      onConfirm: () => Get.back(),
                      radius: 8,
                    );
                  },
                  child: ListTile(
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
                    title: Text(
                      "${cliente.id} - ${cliente.nombreComercial} - ${cliente.razonSocial}",
                    ),
                    subtitle: Text(cliente.municipio ?? "Sin ubicación"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
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
}
