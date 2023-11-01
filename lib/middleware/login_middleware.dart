import 'package:auxi_app/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../app/routes/app_pages.dart';

class LoginMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    print(route);
    if (SPUtil.getBool('isLogin') == false) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}
