import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/controllers/folios.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FoliosEmptyPage extends GetView<FoliosController> {
  const FoliosEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff1D6CFF);
    final screenWidth = MediaQuery.of(context).size.width;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: Color(0XFFF8FAFC),
        child: Column(
          children: [
            Container(
              width: screenWidth,
              child: DrawerHeader(
                // decoration: BoxDecoration(image: imageUrl),
                curve: Curves.bounceOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.nameUser.value,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(controller.rolName.value),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text("Perfil"),
              onTap: () => Get.toNamed(Routes.PROFILE),
            ),
            ListTile(title: Text("Repartidores"), onTap: null),
            ListTile(title: Text("Refacciones"), onTap: null),
            ExpansionTile(
              title: Text("Folios"),
              children: [
                ListTile(
                  title: Text("Agregar Folio"),
                  onTap: () => Get.toNamed(Routes.ADD_FOLIOS),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("Clientes"),
              children: [
                ListTile(
                  title: Text("Agregar Cliente"),
                  onTap: () => Get.toNamed(Routes.ADD_CLIENTE),
                ),
              ],
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.logout),
              iconColor: Color(0XFFF8FAFC),
              tileColor: Color(0XFFFF3535),
              title: Text(
                "Cerrar sesion",
                style: TextStyle(color: Color(0XFFF8FAFC)),
              ),
              onTap: () => controller.signOut(),
            ),
          ],
        ),
      ),

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0XFFF8FAFC),
        title: SizedBox(
          width: 120,
          child: Image.network(
            fit: BoxFit.contain,
            "https://lirp.cdn-website.com/d83902d6/dms3rep/multi/opt/logotipo-157w.png",
          ),
        ),
        automaticallyImplyActions: false,
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.account_circle_outlined),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              controller.selectDate(context);
            },
            icon: Icon(Icons.filter_list_outlined),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.search_outlined)),
        ],
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withOpacity(.08),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 58,
                  color: primary,
                ),
              ),
              const SizedBox(height: 40),

              // Texto de Fecha Dinámico
              Text(
                controller.obtenerEtiquetaFecha(
                  DateTime.tryParse(controller.fechaSeleccionada.value) ??
                      DateTime.now(),
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: primary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "No hay folios",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                  letterSpacing: -.6,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                "Todavía no has registrado ningún folio para el día seleccionado.\nEmpieza creando el primero.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 28),

              // Badge informativo
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(.08),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Todo está al día",
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              if (controller.rolUsuario.value == 1)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () {
                      Get.toNamed(Routes.ADD_FOLIOS);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "Crear nuevo folio",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
