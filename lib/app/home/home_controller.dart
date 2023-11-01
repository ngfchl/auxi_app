import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pages/index.dart';

class HomeController extends GetxController {
  var initPage = 3.obs;

  final PageController pageController = PageController(initialPage: 3);
  final List<BottomNavigationBarItem> menuItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.task),
      label: '计划任务',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings_input_composite_sharp),
      label: '我的站点',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '仪表盘',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.task_outlined),
      label: '下载器',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: '系统设置',
    ),
  ];

  final List<Widget> pages = [
    const TaskPage(),
    const MySitePage(),
    const DashBoard(),
    const DownloadPage(),
    const SettingPage(),
  ];

  @override
  void onInit() {
    super.onInit();
  }

  void changePage(int index) {
    pageController.jumpToPage(index);
    initPage.value = index;
  }
}
