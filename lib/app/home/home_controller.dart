import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pages/index.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  var initPage = 2.obs;

  final PageController pageController = PageController(initialPage: 2);
  final List<BottomNavigationBarItem> menuItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.search_sharp),
      label: '搜索',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.data_thresholding),
      label: '数据',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '仪表盘',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.task_outlined),
      label: '任务',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: '设置',
    ),
  ];

  final List<Widget> pages = [
    const SearchPage(),
    const SitePage(),
    const DashBoard(),
    const TaskPage(),
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
