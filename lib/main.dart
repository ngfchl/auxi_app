import 'package:auxi_app/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';

void main() async {
  await GetStorage.init();
  // 初始化 持久化数据信息
  await SPUtil.getInstance();
  runApp(
    GetMaterialApp(
        title: "PTOOLS",
        defaultTransition: Transition.cupertino,
        debugShowCheckedModeBanner: false,
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        routingCallback: (routing) {
          print('当前路由：${routing!.current.toString()}');
        }),
  );
}
