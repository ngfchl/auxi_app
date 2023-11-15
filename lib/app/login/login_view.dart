import 'package:auxi_app/common/glass_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  GFListTile _buildLogo() {
    return const GFListTile(
      avatar: GFAvatar(
        backgroundImage: AssetImage('assets/images/ptools.jpg'),
        size: 40,
        shape: GFAvatarShape.square,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'PTools',
            style: TextStyle(
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      subTitle: Row(
        children: [
          Text(
            'PT一下，你就晓嘚',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  /// 打开服务器列表弹窗
  Widget openSelectServerSheet() {
    return controller.serverList.isNotEmpty
        ? SingleChildScrollView(
            child: ListView.builder(
                itemCount: controller.serverList.length,
                shrinkWrap: true,
                itemBuilder: (
                  BuildContext context,
                  int index,
                ) {
                  String server = controller.serverList[index];
                  return GFRadioListTile(
                    // size: GFSize.SMALL,
                    title: Text(
                      server,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    size: 18,
                    icon: const Icon(
                      Icons.computer,
                      color: Colors.white,
                    ),
                    color: Colors.transparent,
                    activeBorderColor: Colors.green,
                    focusColor: Colors.green,
                    selected: controller.serverController.text == server,
                    value: server,
                    toggleable: true,
                    groupValue: controller.serverController.text,
                    onChanged: (value) {
                      controller.serverController.text = value.toString();
                      controller.saveServer();
                      Get.back();
                    },
                    onLongPress: () {
                      print('object');
                      Get.defaultDialog(
                          title: '确认？',
                          content: const Text('确认删除当前内容？'),
                          textCancel: '取消',
                          textConfirm: '确认',
                          onConfirm: () => {});
                    },
                    inactiveIcon: null,
                  );
                }),
          )
        : const SizedBox.shrink();
  }

  /// 服务器地址设置
  Widget _buildServerWidget() {
    return Row(
      children: [
        Expanded(
          child: controller.isServerEdit
              ? Text(
                  controller.serverController.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                )
              : TextField(
                  controller: controller.serverController,
                  decoration: const InputDecoration(
                    hintText: '请输入服务器地址',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.cyan,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp("[A-Z,a-z,0-9,/,:,.]"))
                  ],
                ),
        ),
        controller.isServerEdit
            ? GFIconButton(
                onPressed: controller.editServer,
                type: GFButtonType.transparent,
                color: Colors.white,
                size: 20,
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 18,
                ),
              )
            : GFIconButton(
                onPressed: controller.saveServer,
                type: GFButtonType.transparent,
                color: Colors.white,
                size: 20,
                icon: const Icon(
                  Icons.save,
                  color: Colors.white,
                  size: 18,
                ),
              ),
      ],
    );
  }

  List<Widget> _buildUserForm() {
    return [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        child: TextField(
          controller: controller.usernameController,
          decoration: const InputDecoration(
            hintText: '请输入用户名',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          textAlign: TextAlign.center,
          autofocus: true,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade400,
            ),
          ),
        ),
        child: TextField(
          controller: controller.passwordController,
          decoration: const InputDecoration(
            hintText: '请输入密码',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          obscureText: true,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.orangeAccent,
      body: GlassWidget(
        child: Container(
          padding: const EdgeInsets.only(top: 20),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              Colors.teal.shade900.withOpacity(0.5),
              Colors.teal.shade800.withOpacity(0.5),
              Colors.teal.shade600.withOpacity(0.5),
              Colors.teal.shade300.withOpacity(0.5)
            ]),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: GFCard(
                height: 420,
                boxFit: BoxFit.cover,
                color: Colors.transparent,
                // image: Image.asset('images/ptools.jpg'),
                title: _buildLogo(),
                content: Column(
                  children: [
                    // _buildServerWidget(),
                    ..._buildUserForm(),
                  ],
                ),
                buttonBar: GFButtonBar(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GFCheckbox(
                              size: 22,
                              activeBgColor: GFColors.PRIMARY,
                              onChanged: (value) {
                                controller.isChecked = value;
                              },
                              value: controller.isChecked,
                            ),
                            const Text(
                              '记住密码',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        GFButton(
                          text: '设置服务器',
                          textStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                          onPressed: () =>
                              Get.bottomSheet(SingleChildScrollView(
                            child: Container(
                              height: 300,
                              color: Colors.teal,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              controller.serverController,
                                          decoration: const InputDecoration(
                                            hintText: '请输入服务器地址',
                                            hintStyle: TextStyle(
                                                color: Colors.white70),
                                            // border: InputBorder.none
                                          ),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.cyan,
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp("[A-Z,a-z,0-9,/,:,.,-]"))
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 75,
                                        child: GFButton(
                                          text: "清除",
                                          onPressed: controller.clearServerList,
                                          type: GFButtonType.solid,
                                          color: GFColors.DANGER,
                                          size: 24,
                                          icon: const Icon(
                                            Icons.clear_all,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 75,
                                        child: GFButton(
                                          text: "添加",
                                          onPressed: controller.saveServerList,
                                          type: GFButtonType.solid,
                                          color: GFColors.PRIMARY,
                                          size: 22,
                                          icon: const Icon(
                                            Icons.add_box,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(child: openSelectServerSheet()),
                                ],
                              ),
                            ),
                          )),
                          type: GFButtonType.transparent,
                          color: Colors.white,
                          size: 22,
                          icon: const Icon(
                            Icons.select_all_outlined,
                            color: Colors.orange,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GFButton(
                          onPressed: controller.doLogin,
                          text: "登录",
                          size: GFSize.LARGE,
                          shape: GFButtonShape.square,
                          type: GFButtonType.outline2x,
                          color: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GFButton(
                          onPressed: () => controller.box.remove('userinfo'),
                          text: "重置",
                          size: GFSize.LARGE,
                          shape: GFButtonShape.square,
                          type: GFButtonType.outline2x,
                          color: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
