import 'package:get/get.dart';

import '../../../../presentation/searchFolio/controllers/search_folio.controller.dart';

class SearchFolioControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchFolioController>(
      () => SearchFolioController(),
    );
  }
}
