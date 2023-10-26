// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

import '../home/home_binding.dart';
import '../home/home_view.dart';
import '../login/login_binding.dart';
import '../login/login_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
  ];
}
