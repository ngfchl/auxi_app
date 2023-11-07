import 'dart:convert';

import 'package:auxi_app/common/glass_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:transfer_list/transfer_list.dart';

import '../models/task.dart';
import 'controller/task_controller.dart';

class TaskPage extends StatelessWidget {
  TaskPage({super.key, param});

  final controller = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // appBar: AppBar(
      //   title: const Text('计划任务'),
      // ),
      body: GlassWidget(
        child: ListView(
          children: _buildTaskList(),
        ),
      ),
      floatingActionButton: GFIconButton(
        icon: const Icon(Icons.add),
        shape: GFIconButtonShape.standard,
        color: GFColors.PRIMARY.withOpacity(0.6),
        onPressed: () {
          GFToast.showToast(
            '添加任务',
            context,
            backgroundColor: GFColors.PRIMARY,
            toastBorderRadius: 5.0,
          );
        },
      ),
    );
  }

  editTask(Schedule task) {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const GFTypography(
                text: '编辑任务',
                type: GFTypographyType.typo4,
                textColor: Colors.white70,
                dividerColor: Colors.white70,
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: GFDropdown(
                    dropdownColor: Colors.teal.withOpacity(0.8),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    hint: const Text(
                      '请选择任务！',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    icon: const Icon(
                      Icons.task,
                      color: Colors.white,
                    ),
                    // elevation: 10,
                    isExpanded: true,
                    padding: const EdgeInsets.all(0),
                    // borderRadius: BorderRadius.circular(10),
                    border:
                        const BorderSide(color: Colors.transparent, width: 1),
                    dropdownButtonColor: Colors.teal.shade300,
                    value: task.task,
                    onChanged: (newValue) {},
                    items: controller.taskList.values
                        .map((value) => DropdownMenuItem(
                              value: value.task,
                              child: Text(value.desc!),
                            ))
                        .toList(),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GFToggle(
                      onChanged: (val) {},
                      value: task.enabled!,
                      type: GFToggleType.square,
                      enabledText: '开启',
                      disabledText: '禁用',
                    ),
                    const Text(
                      '开启任务',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: TextField(
                  controller: TextEditingController(text: task.name),
                  decoration: const InputDecoration(
                    hintText: '请输入任务名称',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                  ),
                  textAlign: TextAlign.left,
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
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: TextField(
                  controller: TextEditingController(
                    text: controller.crontabList[task.crontab!]!.minute!,
                  ),
                  decoration: const InputDecoration(
                    hintText: '运行时间：分钟',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                  ),
                  textAlign: TextAlign.left,
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
                    bottom: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                child: TextField(
                  controller: TextEditingController(
                    text: controller.crontabList[task.crontab!]!.hour!,
                  ),
                  decoration: const InputDecoration(
                    hintText: '运行时间：小时',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                  ),
                  textAlign: TextAlign.left,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: TransferList(
                  leftList: const [
                    'Dog',
                    'Cat',
                    'Mouse',
                    'Rabbit',
                    'Lion',
                    'Tiger',
                    'Fox',
                    'Wolf'
                  ],
                  rightList: json.decode(task.args!),
                  onChange: (leftList, rightList) {
                    // your logic
                  },
                  listBackgroundColor: Colors.teal.withOpacity(0.6),
                  textStyle: const TextStyle(color: Colors.white),
                  tileSplashColor: Colors.white,
                  checkboxFillColor: Colors.transparent,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GFButton(
                      onPressed: () {
                        Get.back();
                      },
                      color: GFColors.SUCCESS,
                      text: '取消',
                      size: GFSize.SMALL,
                    ),
                    GFButton(
                      onPressed: () {},
                      text: '保存',
                      color: GFColors.DANGER,
                      size: GFSize.SMALL,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.teal.shade300,
    );
  }

  List<Widget> _buildTaskList() {
    return controller.dataList
        .map((item) => GFCard(
              color: Colors.teal.shade300.withOpacity(0.3),
              padding:
                  const EdgeInsets.only(left: 0, right: 0, top: 8, bottom: 8),
              border: Border.all(
                color: Colors.teal.shade300,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              title: GFListTile(
                icon: Card(
                  color: Colors.orange,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      controller.crontabList[item.crontab!]!.express!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onLongPress: () {
                  Get.snackbar('title', '删除任务？');
                },
                padding: const EdgeInsets.all(0),
                title: Text(
                  item.name!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.lightGreenAccent,
                  ),
                ),
                subTitle: Text(
                  controller.taskList[item.task!]!.desc!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.cyan,
                  ),
                ),

                // description: Text(
                //   controller.taskList[item.task!]!.desc!,
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: Colors.lightBlue,
                //   ),
                // ),
              ),
              buttonBar: GFButtonBar(
                children: <Widget>[
                  item.enabled!
                      ? GFButton(
                          onPressed: () {
                            Get.defaultDialog(
                              title: '关闭任务',
                              middleText: '确定要关闭？',
                              onCancel: () {
                                Get.back();
                              },
                              onConfirm: () {
                                Get.snackbar('关闭', '关闭任务？');
                              },
                              textCancel: '取消',
                              textConfirm: '确定',
                            );
                          },
                          color: GFColors.DANGER,
                          text: '关闭',
                          size: GFSize.SMALL,
                        )
                      : GFButton(
                          onPressed: () {
                            Get.defaultDialog(
                              title: '开启任务',
                              middleText: '确定要开启？',
                              onCancel: () {
                                Get.back();
                              },
                              onConfirm: () {
                                Get.snackbar('开启', '开启任务？');
                              },
                              textCancel: '取消',
                              textConfirm: '确定',
                            );
                          },
                          color: GFColors.SUCCESS,
                          text: '开启',
                          size: GFSize.SMALL,
                        ),
                  GFButton(
                    onPressed: () {
                      Get.defaultDialog(
                        title: '运行任务',
                        middleText: '确定要运行？',
                        onCancel: () {
                          Get.back();
                        },
                        onConfirm: () {
                          Get.snackbar('运行任务', '运行任务？');
                        },
                        textCancel: '取消',
                        textConfirm: '确定',
                      );
                    },
                    text: '运行',
                    size: GFSize.SMALL,
                    color: GFColors.SECONDARY,
                  ),
                  GFButton(
                    onPressed: () {
                      editTask(item);
                    },
                    text: '编辑',
                    size: GFSize.SMALL,
                  ),
                ],
              ),
            ))
        .toList();
  }
}
