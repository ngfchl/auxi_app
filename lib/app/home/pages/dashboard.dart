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
        child: Column(
          children: [
            _buildGridView(),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    final items = ['设置', '修改密码', '关于'];
    return Container(
      padding: EdgeInsets.all(8),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 1),
          itemCount: items.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            String item = items[index];
            return GFButton(
              onPressed: () {
                Get.snackbar("提示", item);
              },
              text: item,
            );
          }),
    );
  }
}
