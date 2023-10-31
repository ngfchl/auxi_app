import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import '../routes/app_pages.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      backgroundColor: Colors.teal.shade200,
      appBar: GFAppBar(
        searchBar: true,
        backgroundColor: Colors.teal.withOpacity(0.3),
      ),
      body: PageView(
        controller: controller.pageController,
        onPageChanged: (index) {
          controller.initPage.value = index;
          controller.update();
        },
        children: controller.pages,
      ),
      drawer: Container(
        width: 280,
        color: Colors.purple.withOpacity(0.5),
        child: Column(
          children: [
            GFButton(
              onPressed: () {
                Get.toNamed(Routes.DASHBOARD);
              },
              text: 'DASHBOARD',
            ),
            GFButton(
              onPressed: () {
                Get.toNamed(Routes.SEARCH);
              },
              text: 'SITE',
            ),
            GFButton(
              onPressed: () {
                Get.toNamed(Routes.TASK);
              },
              text: 'TASK',
            ),
            GFButton(
              onPressed: () {
                Get.toNamed(Routes.SETTING);
              },
              text: 'SETTING',
            ),
            GFButton(
              onPressed: () {
                Get.toNamed(Routes.SEARCH);
                Get.snackbar('title', 'message');
              },
              text: 'SEARCH',
            ),
          ],
        ),
      ),
      drawerEdgeDragWidth: 0.0,
      drawerScrimColor: Colors.white.withOpacity(0.6),
      floatingActionButton: GFIconButton(
        icon: const Icon(Icons.menu_outlined),
        color: Colors.teal.shade100,
        size: 18,
        onPressed: () {
          _globalKey.currentState?.openDrawer();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
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
