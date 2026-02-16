import 'package:get/get.dart';

class SPServicesController extends GetxController {
  // TODO: Implement service provider specific services controller
  final RxInt selectedIndex = 0.obs;


  void changeTab(int index) {
    selectedIndex.value = index;
  }
}