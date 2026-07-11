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
                    onPressed: () {
                      Get.toNamed(Routes.FOLIOS);
                    },
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
              InkWell(
                onTap: () {},
                child: ListTile(
                  isThreeLine: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Column(
                    children: [
                      Text("3", textScaleFactor: 2),
                      Flexible(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 35),
                          child: Text(
                            "Multifuncional",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text("TERNIUM"),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Color(0XFF64748B),
                            ),
                            Flexible(
                              child: Text(
                                "Guadalupe - Renta - 103325",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Color(0XFF64748B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: const Color(0XFF1D6CFF)),
                        ),
                        child: const Text(
                          "Por entregar",
                          style: TextStyle(
                            color: Color(0XFF1D6CFF),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.0),
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
              SizedBox(height: 8.0),
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
              SizedBox(height: 8.0),
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
