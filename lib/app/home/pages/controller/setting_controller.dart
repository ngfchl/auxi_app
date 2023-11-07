import 'package:get/get.dart';

import '../../../../api/settings.dart';

class SettingController extends GetxController {
  bool isLoaded = false;
  String configData = '';

  @override
  void onInit() {
    getSystemConfigFromServer();
    super.onInit();
  }

  getSystemConfigFromServer() {
    getSystemConfig().then((value) {
      if (value.code == 0) {
        configData = value.data;
        isLoaded = true;
      } else {
        Get.snackbar('解析出错啦！', value.msg.toString());
      }
    }).catchError((e) {
      Get.snackbar('网络访问出错啦', e.toString());
    });
    update();
  }
}
