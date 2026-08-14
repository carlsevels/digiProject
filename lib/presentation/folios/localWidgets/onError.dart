import 'package:bitacora_frontend/presentation/folios/controllers/folios.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnErrorView extends GetView<FoliosController> {
  final String error;

  OnErrorView({super.key, required this.error});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Error: $error"));
  }
}
