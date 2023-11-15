import 'package:auxi_app/api/mysite.dart';
import 'package:auxi_app/common/glass_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key, param});

  @override
  State<StatefulWidget> createState() {
    return _DashBoardState();
  }
}

class _DashBoardState extends State<DashBoard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassWidget(
        child: Container(
          color: Colors.grey.withOpacity(0.5),
          child: Column(
            children: [
              _buildGridView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    final items = [
      GFButton(
        color: GFColors.WARNING,
        onPressed: () {
          signInAll().then((res) {
            Get.back();
            if (res.code == 0) {
              Get.snackbar(
                '签到任务',
                '签到任务信息：${res.msg}',
                colorText: Colors.white70,
                backgroundColor: Colors.teal.withOpacity(0.7),
              );
            } else {
              Get.snackbar(
                '签到失败',
                '签到任务执行出错啦：${res.msg}',
                colorText: Colors.red,
                backgroundColor: Colors.teal.withOpacity(0.7),
              );
            }
          });
        },
        text: '一键签到',
      ),
      GFButton(
        color: GFColors.WARNING,
        onPressed: () {
          getNewestStatusAll().then((res) {
            Get.back();
            if (res.code == 0) {
              Get.snackbar(
                '刷新数据',
                '刷新数据任务信息：${res.msg}',
                colorText: Colors.white70,
                backgroundColor: Colors.teal.withOpacity(0.7),
              );
            } else {
              Get.snackbar(
                '刷新数据',
                '刷新数据执行出错啦：${res.msg}',
                colorText: Colors.red,
                backgroundColor: Colors.teal.withOpacity(0.7),
              );
            }
          });
        },
        text: '刷新数据',
      ),
      // GFButton(
      //   color: GFColors.WARNING,
      //   onPressed: () {
      //     Get.snackbar("提示", '开发中');
      //   },
      //   text: '一键辅种',
      // ),
    ];
    return Container(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 1),
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            Widget item = items[index];
            return item;
          }),
    );
  }
}
