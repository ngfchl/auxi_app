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
        searchController: controller.searchController,
        searchHintText: '搜索',
        backgroundColor: Colors.teal.withOpacity(0.3),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Get.toNamed(Routes.SEARCH, arguments: value);
          }
        },
        actions: <Widget>[
          GFIconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {},
            type: GFButtonType.transparent,
          ),
        ],
      ),
      body: PageView(
        controller: controller.pageController,
        onPageChanged: (index) {
          controller.initPage.value = index;
          controller.update();
        },
        children: controller.pages,
      ),
      drawer: GFDrawer(
        elevation: 10,
        color: Colors.teal.withOpacity(0.6),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 60,
            ),
            GFDrawerHeader(
              centerAlign: true,
              closeButton: null,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              currentAccountPicture: const GFAvatar(
                radius: 80.0,
                backgroundImage: NetworkImage(
                    "https://cdn.pixabay.com/photo/2017/12/03/18/04/christmas-balls-2995437_960_720.jpg"),
              ),
              // otherAccountsPictures: [
              //   Image(
              //     image: NetworkImage(
              //         "https://cdn.pixabay.com/photo/2019/12/20/00/03/road-4707345_960_720.jpg"),
              //     fit: BoxFit.cover,
              //   ),
              //   GFAvatar(
              //     child: Text("ab"),
              //   )
              // ],
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      controller.userinfo['user'],
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    // Text('admin@admin.com'),
                  ],
                ),
              ),
            ),
            ListTile(
              title: const Text(
                '仪表盘',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                '系统设置',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                '修改密码',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                '运行日志',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                '支持站点',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                '反馈帮助',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                '关于',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
      drawerEdgeDragWidth: 0.0,
      drawerScrimColor: Colors.white.withOpacity(0.6),
      floatingActionButton: GFIconButton(
        icon: const Icon(Icons.menu_outlined),
        color: Colors.teal.shade700,
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
