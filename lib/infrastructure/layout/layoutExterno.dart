import 'package:flutter/material.dart';

class LayoutExterno extends StatelessWidget {
  final Widget child;

  const LayoutExterno({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(child: child);
  }
}
