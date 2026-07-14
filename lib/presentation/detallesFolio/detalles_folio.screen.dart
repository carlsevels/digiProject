import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controllers/detalles_folio.controller.dart';
import 'package:action_slider/action_slider.dart';

class DetallesFolioScreen extends GetView<DetallesFolioController> {
  const DetallesFolioScreen({super.key});
  @override
  Widget build(BuildContext context) {
    RxInt _index = 0.obs;

    return controller.obx(
      onLoading: const Center(child: CircularProgressIndicator()),
      onEmpty: const Center(
        child: Text("Este folio no existe."),
      ), 
      (state) => Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0XFF00BC16),
          onPressed: () {},
          child: Icon(Icons.phone, color: Colors.white),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ActionSlider.standard(
              height: 50,
              toggleColor: Color(0XFF1D6CFF),
              icon: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
              child: const Text('Empezar ruta'),
              action: (controller) async {
                controller.loading();
                await Future.delayed(const Duration(seconds: 3));
                controller.success();
              },
            ),
          ),
        ),
        backgroundColor: Color(0XFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Color(0XFFF8FAFC),
          title: Text(
            state?.nombreComercial ?? "",
            style: TextStyle(color: Color(0xff0F172A)),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_outlined)),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Folio: ${state?.folioId} - ${state?.condicionPago} - ${DateFormat("d 'de' MMMM 'del' yyyy", 'es').format(DateTime.tryParse(state!.created_at.toString())!)}",
                  style: TextStyle(
                    color: Color(0XFF64748B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.0),
                Card(
                  elevation: 4,
                  color: Colors.white,
                  margin: EdgeInsets.zero,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: ListTile(
                      isThreeLine: false,
                      contentPadding: EdgeInsets.zero,
                      leading: Column(
                        children: [
                          Text(
                            state.cantidad ?? "",
                            textScaleFactor: 3.5,
                            style: TextStyle(height: 1),
                          ),
                          Flexible(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 35),
                              child: Text(
                                state.tiporefaccion ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        state.nombreComercial ?? "",
                        style: TextStyle(
                          color: Color(0XFF1D6CFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Color(0XFF64748B),
                                ),
                                Flexible(
                                  child: Text(
                                    state.municipio ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0XFF64748B),
                                    ),
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
                              color: state.status != "Por entregar"
                                  ? Color(
                                      int.parse(state.statusColor.toString()),
                                    )
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Color(
                                  int.parse(state.statusColor.toString()),
                                ),
                              ),
                            ),
                            child: Text(
                              state.status.toString(),
                              style: TextStyle(
                                color: state.status == "Por entregar"
                                    ? Color(
                                        int.parse(state.statusColor.toString()),
                                      )
                                    : Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                Text(
                  state.repartidor ?? "",
                  style: TextStyle(
                    color: Color(0XFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    height: 1.2,
                  ),
                ),
                Text(
                  "Repartidor",
                  style: TextStyle(
                    color: Color(0XFF64748B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                SizedBox(height: 24.0),
                Card(
                  color: Colors.white,
                  margin: EdgeInsets.zero,
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Detalles del Trayecto",
                              style: TextStyle(
                                color: Color(0XFF0F172A),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Get.bottomSheet(
                                  backgroundColor: Colors.white,
                                  Container(
                                    width: Get.size.width,
                                    height: Get.size.height / 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Detalles del Trayecto",
                                              style: TextStyle(
                                                color: Color(0XFF0F172A),
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                height: 1,
                                              ),
                                            ),
                                            Stepper(
                                              headerPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                  ),
                                              controlsBuilder:
                                                  (
                                                    BuildContext context,
                                                    ControlsDetails details,
                                                  ) {
                                                    return const SizedBox.shrink();
                                                  },
                                              elevation: 4,
                                              connectorColor:
                                                  WidgetStatePropertyAll<Color>(
                                                    Colors.transparent,
                                                  ),
                                              stepIconBuilder:
                                                  (stepIndex, stepState) {
                                                    switch (stepIndex) {
                                                      case 0:
                                                        return Icon(
                                                          Icons.local_shipping,
                                                          color: Color(
                                                            0xff1D6CFF,
                                                          ),
                                                        );
                                                      case 1:
                                                        return Icon(
                                                          Icons.remove,
                                                        );
                                                      case 2:
                                                        return Icon(
                                                          Icons.remove,
                                                        );
                                                      default:
                                                    }
                                                    return null;
                                                  },
                                              currentStep: _index.value,
                                              onStepCancel: () {
                                                if (_index > 0) {
                                                  _index.value -= 2;
                                                }
                                              },
                                              onStepContinue: () {
                                                if (_index <= 0) {
                                                  _index.value += 2;
                                                }
                                              },
                                              onStepTapped: (int index) {
                                                _index.value = index;
                                              },
                                              steps: [
                                                Step(
                                                  state: StepState.complete,
                                                  label: const Text(
                                                    'Por iniciar',
                                                    style: TextStyle(
                                                      color: Color(0XFF1D6CFF),
                                                    ),
                                                  ),
                                                  title: const Text('12:30'),
                                                  content: Text(
                                                    "Por iniciar ruta de reparto",
                                                  ),
                                                ),
                                                Step(
                                                  state: StepState.complete,
                                                  label: const Text('Llegada'),
                                                  title: const Text('13:23'),
                                                  content: Text(
                                                    "Legada a domicilio",
                                                  ),
                                                ),
                                                Step(
                                                  state: StepState.complete,
                                                  label: const Text('Fin'),
                                                  title: const Text('13:30'),
                                                  content: Text(
                                                    "Se entrega producto",
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.arrow_forward_ios_sharp),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 120,
                          child: Obx(
                            () => SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 500,
                                child: Stepper(
                                  type: StepperType.horizontal,

                                  currentStep: _index.value,

                                  onStepTapped: null,

                                  controlsBuilder: (_, __) {
                                    return const SizedBox.shrink();
                                  },

                                  connectorColor: const WidgetStatePropertyAll(
                                    Colors.transparent,
                                  ),

                                  stepIconBuilder: (stepIndex, stepState) {
                                    if (stepIndex == _index.value) {
                                      return const Icon(
                                        Icons.trip_origin,
                                        color: Color(0xff1D6CFF),
                                      );
                                    }

                                    if (stepIndex < _index.value) {
                                      return const Icon(
                                        Icons.local_shipping,
                                        color: Color(0xff1D6CFF),
                                      );
                                    }

                                    switch (stepIndex) {
                                      case 0:
                                        return const Icon(
                                          Icons.local_shipping,
                                          color: Colors.grey,
                                        );

                                      case 1:
                                        return const Icon(
                                          Icons.location_on,
                                          color: Colors.grey,
                                        );

                                      case 2:
                                        return const Icon(
                                          Icons.flag,
                                          color: Colors.grey,
                                        );

                                      default:
                                        return null;
                                    }
                                  },
                                  steps: [
                                    Step(
                                      title: const Text('--:--'),
                                      label: const Text('Por iniciar'),
                                      state: _index.value >= 0
                                          ? StepState.complete
                                          : StepState.indexed,
                                      content: const SizedBox(),
                                    ),

                                    Step(
                                      title: const Text('--:--'),
                                      label: const Text('Llegada'),
                                      state: _index.value >= 1
                                          ? StepState.complete
                                          : StepState.indexed,
                                      content: const SizedBox(),
                                    ),

                                    Step(
                                      title: const Text('--:--'),
                                      label: const Text('Fin'),
                                      state: _index.value >= 2
                                          ? StepState.complete
                                          : StepState.indexed,
                                      content: const SizedBox(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
