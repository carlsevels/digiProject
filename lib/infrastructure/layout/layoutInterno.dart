import 'package:bitacora_frontend/infrastructure/layout/layoutInterno.controller.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LayoutInterno extends StatelessWidget {
  final Widget? child;
  LayoutInterno({super.key, this.child});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final LayoutInternoController controller = Get.put(
      LayoutInternoController(),
    );
    final screenWidth = MediaQuery.of(context).size.width;
    return controller.obx(
      (state) => Scaffold(
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
            IconButton(onPressed: () {
              controller.selectDate(context);
            }, icon: Icon(Icons.filter_list_outlined)),
            IconButton(onPressed: () {}, icon: Icon(Icons.search_outlined)),
          ],
        ),

        body: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
