import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final _connectivity = Connectivity();
  final isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen((result) {
      isConnected.value = result != ConnectivityResult.none;
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    isConnected.value = result != ConnectivityResult.none;
  }
}
