import 'package:action_slider/action_slider.dart';
import 'package:bitacora_frontend/infrastructure/models/folios.dart';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/presentation/detallesFolio/controllers/detalles_folio.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BtnSliderStatus extends GetView<DetallesFolioController> {
  final Folios? state;

  BtnSliderStatus({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ActionSlider.standard(
          height: 60,
          toggleColor: const Color(0XFF1D6CFF),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          sliderBehavior: SliderBehavior.stretch,
          backgroundColor: Colors.white,
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 20,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: controller.statusFolio(controller.statusId.value),
          ),
          action: (sliderController) async {
            sliderController.loading();
            await controller.changeStatus(
              controller.statusId.toString(),
              state?.folioIdHistorial?.toString() ?? "",
            );
            sliderController.success();

            int? nextStatus = await controller.changeStatus(
              controller.statusId.toString(),
              state?.folioIdHistorial?.toString() ?? "",
            );

            if (nextStatus == 3) {
              sliderController.success();
              await Future.delayed(const Duration(milliseconds: 500));

              Get.toNamed(Routes.SUCCESS, arguments: state?.folioId.toString());
            } else {
              sliderController.success();
              await Future.delayed(const Duration(milliseconds: 500));
              await controller.onInitDetalles();
            }

            await Future.delayed(const Duration(milliseconds: 500));
            await this.controller.onInitDetalles();
          },
        ),
      ),
    );
  }
}
