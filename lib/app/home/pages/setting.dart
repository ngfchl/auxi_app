import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';

import '../../../../../utils/storage.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key, param});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GFButton(
            onPressed: () {
              SPUtil.remove("userinfo");
              SPUtil.remove("isLogin");
              SPUtil.remove("userData");
              Navigator.popAndPushNamed(context, '/login');
            },
            text: "退出",
            shape: GFButtonShape.square,
          ),
        ],
      ),
    );
  }
}
