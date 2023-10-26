import 'package:get/get.dart';

import '../../../utils/logger_helper.dart';
import '../../api/mysite.dart';
import '../home/models/site_status.dart';

class DashboardController extends GetxController {
  //TODO: Implement DashboardController

  List<SiteStatus> statusList = [];
  bool isLoaded = false;

  @override
  void onInit() {
    getSiteStatusList().then((value) {
      if (value.code == 0) {
        statusList = value.data;
        isLoaded = true;
      } else {
        Get.snackbar(
          'ERROR',
          value.msg.toString(),
        );
      }
      update();
    }).catchError((e, stackTrace) {
      Get.snackbar(
        'ERROR',
        e.toString(),
      );
      Logger.instance.w(e.toString());
    });

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
