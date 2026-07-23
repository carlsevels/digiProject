import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBarWithoutImage extends GetView implements PreferredSizeWidget {
  final String? title;

  const AppBarWithoutImage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      title: Text(
        title ?? "",
        style: const TextStyle(color: Color(0xFF0F172A)),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 50,
            child: Image.asset(
              "assets/logos/digireyShort.png",
              opacity: const AlwaysStoppedAnimation(0.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}