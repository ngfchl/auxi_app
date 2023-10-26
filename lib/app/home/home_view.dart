import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/colors/gf_color.dart';

import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade200,
      body: PageView(
        controller: controller.pageController,
        onPageChanged: (index) {
          controller.initPage.value = index;
          controller.update();
        },
        children: controller.pages,
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.teal.shade300,
            currentIndex: controller.initPage.value,
            onTap: controller.changePage,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            // backgroundColor: Colors.blueGrey,
            iconSize: 18,
            selectedItemColor: GFColors.SECONDARY,
            unselectedItemColor: Colors.grey[150],
            items: controller.menuItems,
          )),
    );
  }
}
