import 'dart:convert';

import 'package:auxi_app/common/glass_widget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:transfer_list/transfer_list.dart';

import '../../../api/task.dart';
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
        child: EasyRefresh(
          onRefresh: () {
            controller.getTaskInfo();
            controller.update();
          },
          child: ListView(
            children: _buildTaskList(),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GFIconButton(
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
          const SizedBox(height: 72)
        ],
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
              color: Colors.grey.withOpacity(0.5),
              margin: const EdgeInsets.all(5),
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
                onTap: () {
                  Get.defaultDialog(
                    title: '运行任务',
                    middleText: '确定要运行？',
                    textCancel: '取消',
                    textConfirm: '确定',
                    backgroundColor: Colors.teal.withOpacity(0.7),
                    titleStyle: const TextStyle(color: Colors.white),
                    middleTextStyle: const TextStyle(color: Colors.white),
                    onCancel: () {
                      Get.back();
                    },
                    onConfirm: () {
                      execRemoteTask(item.id!).then((res) {
                        Get.back();
                        if (res.code == 0) {
                          Get.snackbar(
                            '执行任务',
                            '${item.name!} 任务ID：${res.msg}',
                            colorText: Colors.white70,
                            backgroundColor: Colors.teal.withOpacity(0.7),
                          );
                        } else {
                          Get.snackbar(
                            '执行任务',
                            '${item.name!} 任务执行出错啦：${res.msg}',
                            colorText: Colors.red,
                            backgroundColor: Colors.teal.withOpacity(0.7),
                          );
                        }
                      });
                    },
                  );
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
                  SizedBox(
                    width: 58,
                    height: 26,
                    child: GFButton(
                      onPressed: () {
                        Get.defaultDialog(
                          title: item.enabled! ? '关闭任务' : '开启任务',
                          middleText: item.enabled! ? '确定要？' : '确定要开启？',
                          onCancel: () {
                            Get.back();
                          },
                          onConfirm: () {
                            item.enabled!
                                ? item.enabled = false
                                : item.enabled = true;
                            editRemoteTask(item).then((res) {
                              Get.back();
                              if (res.code == 0) {
                                controller.getTaskInfo();
                                Get.snackbar(
                                  item.enabled! ? '关闭任务' : '开启任务',
                                  '${res.msg}',
                                  colorText: Colors.white70,
                                  backgroundColor: Colors.teal.withOpacity(0.7),
                                );
                              } else {
                                Get.snackbar(
                                  item.enabled! ? '关闭任务' : '开启任务',
                                  '${res.msg}',
                                  colorText: Colors.red,
                                  backgroundColor: Colors.teal.withOpacity(0.7),
                                );
                              }
                            });
                          },
                          textCancel: '取消',
                          textConfirm: '确定',
                        );
                      },
                      color:
                          item.enabled! ? GFColors.WARNING : GFColors.SUCCESS,
                      text: item.enabled! ? '禁用' : '启用',
                      size: GFSize.SMALL,
                    ),
                  ),
                  SizedBox(
                    width: 58,
                    height: 26,
                    child: GFButton(
                      onPressed: () {
                        editTask(item);
                      },
                      text: '编辑',
                      size: GFSize.SMALL,
                      color: GFColors.SECONDARY,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }
}
