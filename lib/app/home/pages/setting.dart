import 'package:auxi_app/common/glass_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';

import '../../../../../utils/storage.dart';
import 'controller/setting_controller.dart';

class SettingPage extends StatelessWidget {
  SettingPage({super.key, param});

  final controller = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return GlassWidget(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('当前服务器：${SPUtil.getString('server')}'),
            GFButton(
              onPressed: () {
                TextEditingController configController =
                    TextEditingController();
                configController.text = controller.configData;
                Get.defaultDialog(
                    title: '配置项',
                    content: TextField(
                      controller: configController,
                      maxLines: 24,
                    ),
                    textConfirm: '保存',
                    textCancel: '取消',
                    onConfirm: () {
                      Get.snackbar('保存？', '确定保存配置吗？');
                    },
                    onCancel: () {
                      Get.back();
                    });
              },
              text: "配置信息",
              shape: GFButtonShape.square,
            ),
            GFButton(
              onPressed: () {
                SPUtil.remove("userinfo");
                SPUtil.remove("isLogin");
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
