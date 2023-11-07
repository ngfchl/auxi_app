import 'package:auxi_app/api/task.dart';
import 'package:get/get.dart';

import '../../../../utils/logger_helper.dart';
import '../../models/task.dart';

class TaskController extends GetxController {
  bool isLoaded = false;
  List<Schedule> dataList = [];
  Map<int, Crontab> crontabList = {};
  Map<String, Task> taskList = {};

  @override
  void onInit() {
    super.onInit();
    getTaskInfo();
    update();
  }

  void getTaskInfo() {
    getTaskList().then((value) {
      if (value.code == 0) {
        taskList = value.data;
      } else {
        Get.snackbar('', value.msg.toString());
      }
    }).catchError((e) {
      Get.snackbar('', e.toString());
    });
    getCrontabList().then((value) {
      if (value.code == 0) {
        crontabList = value.data;
        Logger.instance.w(crontabList);
      } else {
        Get.snackbar('', value.msg.toString());
      }
    }).catchError((e) {
      Get.snackbar('', e.toString());
    });
    getScheduleList().then((value) {
      if (value.code == 0) {
        dataList = value.data;
        isLoaded = true;
      } else {
        Get.snackbar('解析出错啦！', value.msg.toString());
      }
    }).catchError((e) {
      Get.snackbar('网络访问出错啦', e.toString());
    });
  }
}
