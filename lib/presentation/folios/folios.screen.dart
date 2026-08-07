import 'dart:ui';

import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/empty_folio_web.dart';
import 'package:bitacora_frontend/presentation/folios/localWidgets/folios.empty.dart';
import 'package:bitacora_frontend/presentation/folios/responsive/movil.dart';
import 'package:bitacora_frontend/presentation/folios/responsive/web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/folios.controller.dart';

class FoliosScreen extends StatelessWidget {
  const FoliosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FoliosController>();

    final Widget mainBody = controller.obx(
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
      onError: (error) => Center(child: Text("Error: $error")),
      onEmpty: RefreshIndicator(
        color: Colors.white,
        backgroundColor: const Color(0XFF1D6CFF),
        onRefresh: () async {
          await controller.getFoliosWithDate();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: Get.size.height * 0.7,
            child: Center(
              child: kIsWeb
                  ? WebFoliosEmptyPage(needDate: true)
                  : FoliosEmptyPage(needDate: true),
            ),
          ),
        ),
      ),
      (state) {
        if (kIsWeb) {
          return WebFolioView(state: state!);
        } else {
          return MovilFolioView(state: state!);
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0XFFF8FAFC),
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
                Icons.receipt_long_outlined,
                color: Color(0xff1565C0),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Folios",
              style: TextStyle(
                color: Color(0xff1565C0),
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xff1565C0).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              tooltip: "Filtrar por fecha",
              onPressed: () {
                controller.selectDate(context);
              },
              icon: const Icon(
                Icons.filter_list_outlined,
                color: Color(0xff1565C0),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xff1565C0).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              tooltip: "Buscar folio",
              onPressed: () {
                Get.toNamed(Routes.SEARCH_FOLIO);
              },
              icon: const Icon(
                Icons.search_outlined,
                color: Color(0xff1565C0),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: mainBody,
    );
  }
}
