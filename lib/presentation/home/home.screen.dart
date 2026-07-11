import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/home.controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(child: Obx(() => Text(controller.rolName.value))),
              ListTile(
                title: Text("Perfil"),
                onTap: () => Get.toNamed(Routes.PROFILE),
              ),
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
            IconButton(onPressed: () {}, icon: Icon(Icons.search_outlined)),
          ],
        ),
        backgroundColor: Color(0XFFF8FAFC),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Ultimos folios", textScaleFactor: 1.8),
                  TextButton(
                    onPressed: () {},
                    child: Text("Ver todo"),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Color(0XFF1D6CFF),
                      foregroundColor: Color(0XFFFFFFFF),
                    ),
                  ),
                ],
              ),
              ListTile(
                isThreeLine: true,
                contentPadding: EdgeInsets.zero,
                leading: Column(
                  children: [Text("3", textScaleFactor: 2), Text("Toner")],
                ),
                title: Text("TERNIUM"),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Color(0XFF64748B),
                        ),
                        Text(
                          "Guadalupe - Renta - 103325",
                          style: TextStyle(color: Color(0XFF64748B)),
                        ),
                      ],
                    ),
                    Container(
                      width: Get.size.width / 5,
                      child: Center(
                        child: Text(
                          "Por entregar",
                          style: TextStyle(color: Color(0XFF1D6CFF)),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        border: BoxBorder.all(color: Color(0XFF1D6CFF)),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Repartidores", textScaleFactor: 1.8),
                  TextButton(
                    onPressed: () {},
                    child: Text("Ver todo"),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Color(0XFF1D6CFF),
                      foregroundColor: Color(0XFFFFFFFF),
                    ),
                  ),
                ],
              ),
              ListTile(
                isThreeLine: true,
                contentPadding: EdgeInsets.zero,
                trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.arrow_forward_ios_sharp),
                ),
                leading: CircleAvatar(
                  child: Text("C", style: TextStyle(color: Colors.white)),
                  backgroundColor: Color(0XFF0F172A),
                ),
                title: Text("Carlos Vélez"),
                subtitle: Text(
                  "repartidor1@gmail.com",
                  style: TextStyle(color: Color(0XFF64748B)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tipos de refacciones", textScaleFactor: 1.8),
                  TextButton(
                    onPressed: () {},
                    child: Text("Ver todo"),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Color(0XFF1D6CFF),
                      foregroundColor: Color(0XFFFFFFFF),
                    ),
                  ),
                ],
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                trailing: IconButton(onPressed: () {}, icon: Icon(Icons.close)),
                leading: CircleAvatar(
                  child: Text("T", style: TextStyle(color: Colors.white)),
                  backgroundColor: Color(0XFF0F172A),
                ),
                title: Text("Toner"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Clientes", textScaleFactor: 1.8),
                  TextButton(
                    onPressed: () {},
                    child: Text("Ver todo"),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Color(0XFF1D6CFF),
                      foregroundColor: Color(0XFFFFFFFF),
                    ),
                  ),
                ],
              ),
              ListTile(
                isThreeLine: true,
                contentPadding: EdgeInsets.zero,
                trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.arrow_forward_ios_sharp),
                ),
                leading: CircleAvatar(
                  child: Text("G", style: TextStyle(color: Colors.white)),
                  backgroundColor: Color(0XFF0F172A),
                ),
                title: Text("GRUPO EMPRESARIAL ARAN"),
                subtitle: Text(
                  "Monterrey",
                  style: TextStyle(color: Color(0XFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
