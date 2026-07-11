import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/add_folios.controller.dart';

class AddFoliosScreen extends GetView<AddFoliosController> {
  const AddFoliosScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Color(0XFFF8FAFC),
        centerTitle: true,
        title: SizedBox(
          width: 120,
          child: Image.network(
            fit: BoxFit.contain,
            "https://lirp.cdn-website.com/d83902d6/dms3rep/multi/opt/logotipo-157w.png",
          ),
        ),
        automaticallyImplyActions: false,
        actions: [
          SearchAnchor(
            viewBackgroundColor: Color(0XFFF8FAFC),
            isFullScreen: true,
            viewHintText: "Buscar folio o factura",
            headerHintStyle: TextStyle(color: Color(0XFF64748B)),
            dividerColor: Color(0XFF64748B),
            viewPadding: EdgeInsets.symmetric(horizontal: 16.0),
            builder: (BuildContext context, SearchController controller) {
              return IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => controller.openView(),
              );
            },
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
                  // This triggers when the user types or opens the search view
                  final String query = controller.text;
                  return List<ListTile>.generate(5, (int index) {
                    final String item = 'Result item $index for "$query"';
                    return ListTile(
                      isThreeLine: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Column(
                        children: [
                          Text("3", textScaleFactor: 2),
                          Text("Toner"),
                        ],
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: const Color(0XFF1D6CFF),
                              ),
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
                    );
                  });
                },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nuevo folio", textScaleFactor: 2),
          SizedBox(height: 8.0),
          Text(
            "Tipo de documento",
            textScaleFactor: 1.2,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.0),
          Text("Seleccione tipo"),
        ],
      ),
    );
  }
}
