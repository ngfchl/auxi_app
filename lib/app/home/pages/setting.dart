import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';

import '../../../../../utils/storage.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key, param});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        // 取消返回按钮
        automaticallyImplyLeading: false,
        // 背景透明
        backgroundColor: Colors.transparent,
        title: const Text(
          '设置中心',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            GFButton(
              onPressed: () {
                SPUtil.remove("userinfo");
                SPUtil.clear();
                Navigator.popAndPushNamed(context, '/login');
              },
              text: "退出",
              shape: GFButtonShape.square,
            ),
          ],
        ),
      ),
    );
  }
}
