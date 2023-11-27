import 'package:auxi_app/common/glass_widget.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:proper_filesize/proper_filesize.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../utils/logger_helper.dart' as LoggerHelper;
import '../../models/transmission.dart';
import '../home/models/downloader/transmission_base_torrent.dart';
import 'torrent_controller.dart';

class TorrentView extends GetView<TorrentController> {
  const TorrentView({super.key});

  @override
  Widget build(BuildContext context) {
    var tooltipBehavior = TooltipBehavior(
      enable: true,
      shared: true,
      decimalPlaces: 1,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
          int seriesIndex) {
        // Logger.instance.w(data);
        return Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: Colors.teal.shade300,
            border: Border.all(width: 2, color: Colors.teal.shade400),
          ),
          child: Text(
            '${series.name}: ${filesize(point.y)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black38,
            ),
          ),
        );
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder<TorrentController>(builder: (controller) {
          return Text(controller.downloader.name);
        }),
        centerTitle: true,
      ),
      body: GlassWidget(
        child: GetBuilder<TorrentController>(builder: (controller) {
          return controller.torrents.isEmpty
              ? const GFLoader()
              : EasyRefresh(
                  controller: EasyRefreshController(),
                  onRefresh: () async {
                    controller.cancelPeriodicTimer();
                    controller.startPeriodicTimer();
                  },
                  child: Column(
                    children: [
                      if (controller.downloader.category.toLowerCase() == 'qb')
                        Container(
                          height: 20,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Row(
                            children: [
                              Obx(() {
                                return GFDropdown(
                                  padding: EdgeInsets.zero,
                                  borderRadius: BorderRadius.circular(2),
                                  // border:
                                  //     const BorderSide(color: Colors.black12, width: 1),
                                  dropdownButtonColor: Colors.white54,
                                  itemHeight: 20,
                                  value: controller.sortKey.value,
                                  onChanged: (newValue) {
                                    if (controller.sortKey.value == newValue) {
                                      controller.sortReversed.value =
                                          !controller.sortReversed.value;
                                    } else {
                                      controller.sortReversed.value = false;
                                    }
                                    LoggerHelper.Logger.instance
                                        .w(controller.sortReversed.value);
                                    controller.sortKey.value = newValue!;
                                    controller.getAllTorrents();
                                    controller.update();
                                  },
                                  items: controller.qbSortOptions
                                      .map((item) => DropdownMenuItem(
                                            value: item['value'],
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 3.0),
                                              child: Text(
                                                item['name']!,
                                                style: const TextStyle(
                                                    fontSize: 10),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                );
                              }),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Obx(
                                  () => TextField(
                                    controller:
                                        controller.searchController.value,
                                    style: const TextStyle(fontSize: 10),
                                    textAlignVertical: TextAlignVertical.bottom,
                                    decoration: const InputDecoration(
                                      // labelText: '搜索',
                                      hintText: '输入关键词...',
                                      labelStyle: TextStyle(fontSize: 10),
                                      hintStyle: TextStyle(fontSize: 10),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        size: 10,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3.0)),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      // 在这里处理搜索框输入的内容变化

                                      print('搜索框内容变化：$value');
                                      controller.searchKey.value = value;
                                      controller.filterTorrentsBySearchKey();
                                    },
                                  ),
                                ),
                              )
                              // Obx(() {
                              //   LoggerHelper.Logger.instance.w(controller.categories);
                              //   return GFDropdown(
                              //     padding: EdgeInsets.zero,
                              //     borderRadius: BorderRadius.circular(2),
                              //     // border:
                              //     //     const BorderSide(color: Colors.black12, width: 1),
                              //     dropdownButtonColor: Colors.white54,
                              //     itemHeight: 20,
                              //     value: controller.category,
                              //     onChanged: (newValue) {
                              //       LoggerHelper.Logger.instance.w(newValue);
                              //       controller.category.value = newValue! as String;
                              //       controller.update();
                              //       // controller.showTorrents.value = controller
                              //       //     .torrents.value
                              //       //     .where(
                              //       //         (element) => element.category == newValue)
                              //       //     .toList();
                              //     },
                              //     items: controller.categories
                              //         .map((item) => DropdownMenuItem(
                              //               value: item['value'],
                              //               child: SizedBox(
                              //                 height: 20,
                              //                 child: Text(
                              //                   item['name']!,
                              //                   style: const TextStyle(fontSize: 10),
                              //                   maxLines: 1,
                              //                 ),
                              //               ),
                              //             ))
                              //         .toList(),
                              //   );
                              // }),
                            ],
                          ),
                        ),
                      if (controller.downloader.category.toLowerCase() == 'tr')
                        Container(
                          height: 20,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Row(
                            children: [
                              Obx(() {
                                return GFDropdown(
                                  padding: EdgeInsets.zero,
                                  borderRadius: BorderRadius.circular(2),
                                  // border:
                                  //     const BorderSide(color: Colors.black12, width: 1),
                                  dropdownButtonColor: Colors.white54,
                                  itemHeight: 20,
                                  value: controller.sortKey.value,
                                  onChanged: (newValue) {
                                    if (controller.sortKey.value == newValue) {
                                      controller.sortReversed.value =
                                          !controller.sortReversed.value;
                                    } else {
                                      controller.sortReversed.value = false;
                                    }
                                    LoggerHelper.Logger.instance
                                        .w(controller.sortReversed.value);
                                    controller.sortKey.value = newValue!;
                                    controller.getAllTorrents();
                                    controller.update();
                                  },
                                  items: controller.trSortOptions
                                      .map((item) => DropdownMenuItem(
                                            value: item['value'],
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 3.0),
                                              child: Text(
                                                item['name']!,
                                                style: const TextStyle(
                                                    fontSize: 10),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                );
                              }),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Obx(
                                  () => TextField(
                                    controller:
                                        controller.searchController.value,
                                    style: const TextStyle(fontSize: 10),
                                    textAlignVertical: TextAlignVertical.bottom,
                                    decoration: const InputDecoration(
                                      // labelText: '搜索',
                                      hintText: '输入关键词...',
                                      labelStyle: TextStyle(fontSize: 10),
                                      hintStyle: TextStyle(fontSize: 10),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        size: 10,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3.0)),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      print('搜索框内容变化：$value');
                                      controller.searchKey.value = value;
                                      controller.filterTorrentsBySearchKey();
                                    },
                                  ),
                                ),
                              )
                              // Obx(() {
                              //   LoggerHelper.Logger.instance.w(controller.categories);
                              //   return GFDropdown(
                              //     padding: EdgeInsets.zero,
                              //     borderRadius: BorderRadius.circular(2),
                              //     // border:
                              //     //     const BorderSide(color: Colors.black12, width: 1),
                              //     dropdownButtonColor: Colors.white54,
                              //     itemHeight: 20,
                              //     value: controller.category,
                              //     onChanged: (newValue) {
                              //       LoggerHelper.Logger.instance.w(newValue);
                              //       controller.category.value = newValue! as String;
                              //       controller.update();
                              //       // controller.showTorrents.value = controller
                              //       //     .torrents.value
                              //       //     .where(
                              //       //         (element) => element.category == newValue)
                              //       //     .toList();
                              //     },
                              //     items: controller.categories
                              //         .map((item) => DropdownMenuItem(
                              //               value: item['value'],
                              //               child: SizedBox(
                              //                 height: 20,
                              //                 child: Text(
                              //                   item['name']!,
                              //                   style: const TextStyle(fontSize: 10),
                              //                   maxLines: 1,
                              //                 ),
                              //               ),
                              //             ))
                              //         .toList(),
                              //   );
                              // }),
                            ],
                          ),
                        ),
                      Expanded(
                        child: Obx(() {
                          return ListView.builder(
                              itemCount: controller.showTorrents.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (controller.downloader.category
                                        .toLowerCase() ==
                                    'qb') {
                                  TorrentInfo torrentInfo =
                                      controller.showTorrents[index];
                                  return _buildQbTorrentCard(torrentInfo);
                                } else {
                                  TransmissionBaseTorrent torrentInfo =
                                      controller.showTorrents[index];
                                  return _buildTrTorrentCard(torrentInfo);
                                }
                              });
                        }),
                      ),
                    ],
                  ),
                );
        }),
      ),
      endDrawer: GFDrawer(
        child: controller.downloader.category.toLowerCase() == 'qb'
            ? ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 100,
                    child: GetBuilder<TorrentController>(builder: (controller) {
                      return SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        tooltipBehavior: tooltipBehavior,
                        primaryXAxis: CategoryAxis(
                            isVisible: false,
                            majorGridLines: const MajorGridLines(width: 0),
                            edgeLabelPlacement: EdgeLabelPlacement.shift),
                        primaryYAxis: NumericAxis(
                            axisLine: const AxisLine(width: 0),
                            axisLabelFormatter:
                                (AxisLabelRenderDetails details) {
                              return ChartAxisLabel(
                                filesize(details.value),
                                const TextStyle(
                                    fontSize: 10, color: Colors.black38),
                              );
                            },
                            majorTickLines: const MajorTickLines(size: 0)),
                        series: [
                          AreaSeries<TransferInfo, int>(
                            animationDuration: 0,
                            dataSource: controller.statusList.value
                                .cast<TransferInfo>(),
                            enableTooltip: true,
                            xValueMapper: (TransferInfo sales, index) => index,
                            yValueMapper: (TransferInfo sales, _) =>
                                sales.upInfoSpeed,
                            name: '上传速度',
                            borderColor: Colors.black38,
                            borderWidth: 1,
                            borderDrawMode: BorderDrawMode.all,
                          ),
                          AreaSeries<TransferInfo, int>(
                            animationDuration: 0,
                            dataSource: controller.statusList.value
                                .cast<TransferInfo>(),
                            enableTooltip: true,
                            xValueMapper: (TransferInfo sales, index) => index,
                            yValueMapper: (TransferInfo sales, _) =>
                                sales.dlInfoSpeed,
                            color: Colors.red,
                            name: '下载速度',
                            borderColor: Colors.black38,
                            borderWidth: 1,
                          ),
                        ],
                      );
                    }),
                  ),
                  const ListTile(
                    title: Text('筛选'),
                    onTap: null,
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                        itemCount: controller.filters.length,
                        itemBuilder: (context, index) {
                          Map state = controller.filters[index];
                          return Obx(() {
                            return ListTile(
                              dense: true,
                              title: Text(
                                '${state['name']}${controller.torrentFilter.value == state['value'] ? "(${controller.torrents.length})" : ""}',
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              style: ListTileStyle.list,
                              selected: controller.torrentFilter.value ==
                                  state['value'],
                              selectedColor: Colors.purple,
                              onTap: () {
                                // controller.category.value = 'all_torrents';
                                controller.torrentState.value = null;
                                LoggerHelper.Logger.instance.w(state['value']);
                                controller.torrentFilter.value = state['value'];
                                controller.filterTorrentsByState();
                              },
                            );
                          });
                        }),
                  ),
                  const ListTile(
                    title: Text('状态'),
                    onTap: null,
                  ),
                  SizedBox(
                      height: 200,
                      child: ListView.builder(
                          itemCount: controller.status.length,
                          itemBuilder: (context, index) {
                            Map state = controller.status[index];
                            return Obx(() {
                              return ListTile(
                                dense: true,
                                title: Text(
                                  '${state['name']}(${controller.torrents.where((torrent) => torrent.state == state['value']).toList().length})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                style: ListTileStyle.list,
                                selected: controller.torrentState.value ==
                                    state['value'],
                                selectedColor: Colors.purple,
                                onTap: () {
                                  LoggerHelper.Logger.instance
                                      .w(state['value']);
                                  controller.torrentState.value =
                                      state['value'];
                                  controller.filterTorrentsByState();
                                },
                              );
                            });
                          })),
                  const ListTile(
                    title: Text('分类'),
                    onTap: null,
                  ),
                  SizedBox(
                    height: 200,
                    child: Obx(() {
                      return ListView.builder(
                          itemCount: controller.categories.length,
                          itemBuilder: (context, index) {
                            Map category = controller.categories[index];
                            int count = 0;
                            if (category['value'] == 'all_torrents') {
                              count = controller.torrents.length;
                            } else {
                              count = controller.torrents
                                  .where((torrent) =>
                                      torrent.category == category['value'])
                                  .toList()
                                  .length;
                            }

                            return Obx(() {
                              return ListTile(
                                title: Text(
                                  '${category['name']}($count)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                selected: controller.category.value ==
                                    category['value'],
                                selectedColor: Colors.purple,
                                onTap: () {
                                  controller.torrentFilter.value =
                                      TorrentFilter.all;
                                  controller.category.value = category['value'];
                                  controller.filterTorrentsByCategory();
                                },
                              );
                            });
                          });
                    }),
                  ),
                ],
              )
            : Column(
                children: [
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 100,
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      tooltipBehavior: tooltipBehavior,
                      primaryXAxis: CategoryAxis(
                          isVisible: false,
                          majorGridLines: const MajorGridLines(width: 0),
                          edgeLabelPlacement: EdgeLabelPlacement.none),
                      primaryYAxis: NumericAxis(
                          axisLine: const AxisLine(width: 0),
                          axisLabelFormatter: (AxisLabelRenderDetails details) {
                            return ChartAxisLabel(
                              ProperFilesize.generateHumanReadableFilesize(
                                  details.value),
                              const TextStyle(
                                  fontSize: 10, color: Colors.black38),
                            );
                          },
                          majorTickLines: const MajorTickLines(size: 0)),
                      series: <AreaSeries<TransmissionStats, int>>[
                        AreaSeries<TransmissionStats, int>(
                          animationDuration: 0,
                          dataSource: controller.statusList.value
                              .cast<TransmissionStats>(),
                          xValueMapper: (TransmissionStats sales, index) =>
                              index,
                          yValueMapper: (TransmissionStats sales, _) =>
                              sales.uploadSpeed,
                          name: '上传速度',
                          borderColor: Colors.black38,
                          borderWidth: 1,
                        ),
                        AreaSeries<TransmissionStats, int>(
                          animationDuration: 0,
                          dataSource: controller.statusList.value
                              .cast<TransmissionStats>(),
                          xValueMapper: (TransmissionStats sales, index) =>
                              index,
                          yValueMapper: (TransmissionStats sales, _) =>
                              sales.downloadSpeed,
                          enableTooltip: true,
                          name: '下载速度',
                          borderColor: Colors.black38,
                          borderWidth: 1,
                        ),
                      ],
                    ),
                  ),
                  const Text('待开发'),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(() {
            var isTimerActive = controller.isTimerActive.value;
            return GFIconButton(
              icon: isTimerActive
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
              // shape: GFIconButtonShape.standard,
              type: GFButtonType.transparent,
              color: GFColors.PRIMARY,
              onPressed: () {
                // controller.cancelPeriodicTimer();
                isTimerActive
                    ? controller.cancelPeriodicTimer()
                    : controller.startPeriodicTimer();
                LoggerHelper.Logger.instance
                    .w(controller.periodicTimer.isActive);
                LoggerHelper.Logger.instance.w(isTimerActive);
                controller.update();
              },
            );
          }),
          GFIconButton(
            icon: const Icon(Icons.add),
            shape: GFIconButtonShape.standard,
            type: GFButtonType.transparent,
            color: GFColors.PRIMARY,
            onPressed: () {
              GFToast.showToast(
                '添加种子',
                context,
                backgroundColor: GFColors.SECONDARY,
                toastBorderRadius: 5.0,
              );
            },
          ),
          const SizedBox(height: 72)
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);

    int years = duration.inDays ~/ 365;
    int months = (duration.inDays % 365) ~/ 30;
    int days = (duration.inDays % 365) % 30;
    int hours = duration.inHours % 24;
    int minutes = (duration.inMinutes % 60);
    int remainingSeconds = (duration.inSeconds % 60);

    // 构建格式化的时间间隔字符串
    List<String> parts = [];

    if (years > 0) {
      parts.add('$years年');
    }

    if (months > 0) {
      parts.add('$months月');
    }

    if (days > 0) {
      parts.add('$days天');
    }

    if (hours > 0) {
      parts.add('$hours小时');
    }

    if (minutes > 0 && duration.inHours < 1) {
      parts.add('$minutes分');
    }

    if (remainingSeconds > 0 && duration.inDays < 1) {
      parts.add('$remainingSeconds秒');
    }

    return parts.length > 2 ? parts.sublist(0, 2).join() : parts.join();
  }

  Widget _buildQbTorrentCard(TorrentInfo torrentInfo) {
    double cardHeight = 64;
    return Slidable(
      key: ValueKey(torrentInfo.infohashV1),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            return;
          },
          confirmDismiss: () async {
            return false;
          },
        ),
        children: [
          const SlidableAction(
            onPressed: null,
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
          const SlidableAction(
            onPressed: null,
            backgroundColor: Color(0xFF21B7CA),
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  Get.defaultDialog(
                      title: '',
                      middleText: '重新校验种子？',
                      onConfirm: () async {
                        await controller.controlTorrents(
                            command: 'recheck', hashes: [torrentInfo.hash!]);
                      },
                      cancel: const Text('取消'),
                      confirm: const Text('确定'));
                },
                icon: const Icon(Icons.autorenew),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'ForceStart',
                      hashes: [torrentInfo.hash!],
                      enable: !torrentInfo.forceStart!);
                },
                icon: Icon(
                  Icons.keyboard_double_arrow_up,
                  color: torrentInfo.forceStart! ? Colors.orange : Colors.blue,
                ),
              ),
            ],
          ),
          Column(
            children: [
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'command', hashes: [torrentInfo.hash!]);
                },
                icon: const Icon(Icons.local_offer),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'AutoManagement',
                      hashes: [torrentInfo.hash!],
                      enable: !torrentInfo.autoTmm!);
                },
                icon: Icon(Icons.autofps_select_outlined,
                    color: torrentInfo.autoTmm! ? Colors.green : Colors.blue),
              ),
            ],
          ),
        ],
      ),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'resume', hashes: [torrentInfo.hash!]);
                },
                icon: const Icon(Icons.play_arrow),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'SuperSeeding',
                      hashes: [torrentInfo.hash!],
                      enable: !torrentInfo.superSeeding!);
                },
                icon: Icon(Icons.double_arrow,
                    color: torrentInfo.superSeeding!
                        ? GFColors.SUCCESS
                        : GFColors.PRIMARY),
              ),

              // GFIconButton(
              //   size: 8,
              //   type: GFButtonType.transparent,
              //   onPressed: () {},
              //   icon: const Icon(Icons.category),
              // ),
            ],
          ),
          Column(
            children: [
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'delete', hashes: [torrentInfo.hash!]);
                },
                icon: const Icon(Icons.delete_forever),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'command', hashes: [torrentInfo.hash!]);
                },
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
          Column(
            children: [
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'reannounce', hashes: [torrentInfo.hash!]);
                },
                icon: const Icon(Icons.campaign),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  Clipboard.setData(ClipboardData(text: torrentInfo.hash!));
                  Get.snackbar('复制种子HASH', '种子HASH复制成功！');
                },
                icon: const Icon(Icons.copy),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  Clipboard.setData(
                      ClipboardData(text: torrentInfo.magnetUri!));
                  Get.snackbar('复制下载链接', '下载链接复制成功！');
                },
                icon: const Icon(Icons.link),
              ),
              // GFIconButton(
              //   size: 8,
              //   type: GFButtonType.transparent,
              //   onPressed: () async {
              //     await controller.controlTorrents(
              //         command: 'command', hashes: [torrentInfo.hash!]);
              //   },
              //   icon: Icon(Icons.location_searching),
              // ),
            ],
          ),
          const SlidableAction(
            // An action can be bigger than the others.
            flex: 2,
            onPressed: null,
            backgroundColor: Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: 'Archive',
          ),
          const SlidableAction(
            onPressed: null,
            flex: 2,
            backgroundColor: Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.save,
            label: 'Save',
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: SizedBox(
                      height: cardHeight,
                      // width: 100,
                      child: SfLinearGauge(
                        showTicks: false,
                        showLabels: false,
                        animateAxis: true,
                        // labelPosition: LinearLabelPosition.outside,
                        axisTrackStyle: LinearAxisTrackStyle(
                          thickness: cardHeight,
                          edgeStyle: LinearEdgeStyle.bothFlat,
                          borderWidth: 0,
                          borderColor: const Color(0xff898989),
                          color: Colors.transparent,
                        ),
                        barPointers: <LinearBarPointer>[
                          LinearBarPointer(
                              value: torrentInfo.progress! * 100,
                              thickness: cardHeight,
                              edgeStyle: LinearEdgeStyle.bothFlat,
                              color: Colors.green.shade500),
                        ],
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    Get.snackbar('单击', '单击！');
                  },
                  onLongPress: () {
                    Get.snackbar('长按', '长按！');
                  },
                  onDoubleTap: () {
                    Get.snackbar('双击', '双击！');
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    color: Colors.white38.withOpacity(0.3),
                    height: cardHeight,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            if (torrentInfo.tracker!.isNotEmpty)
                              Row(children: [
                                const Icon(
                                  Icons.link,
                                  size: 10,
                                ),
                                Text(
                                  DomainUtils.getDomainFromUrl(
                                          torrentInfo.tracker!)!
                                      .toString(),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black38),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(width: 10),
                              ]),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    filesize(torrentInfo.size),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.black38),
                                  ),
                                  // Row(
                                  //   children: [
                                  //     const Icon(
                                  //       Icons.timer,
                                  //       size: 12,
                                  //       color: Colors.black38,
                                  //     ),
                                  //     EllipsisText(
                                  //       text: formatDuration(
                                  //               torrentInfo.timeActive!)
                                  //           .toString(),
                                  //       style: const TextStyle(
                                  //           fontSize: 10,
                                  //           color: Colors.black38),
                                  //       maxLines: 1,
                                  //       ellipsis: '...',
                                  //     )
                                  //   ],
                                  // ),
                                  Text(
                                    torrentInfo.category!.isNotEmpty
                                        ? torrentInfo.category!
                                        : '未分类',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.black38),
                                  ),
                                  SizedBox(
                                    height: 12,
                                    child: GFButton(
                                      text: controller.status.firstWhere(
                                        (element) =>
                                            element['value'] ==
                                            torrentInfo.state!,
                                        orElse: () => {
                                          "name": "未知状态",
                                          "value": TorrentState.unknown
                                        },
                                      )['name'],
                                      type: GFButtonType.transparent,
                                      elevation: 0,
                                      hoverColor: Colors.green,
                                      textStyle: const TextStyle(
                                          fontSize: 10, color: Colors.black38),
                                      onPressed: () {},
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 280,
                              child: Tooltip(
                                message: torrentInfo.name!,
                                child: Text(
                                  torrentInfo.name!,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black38),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            Text(
                              '${torrentInfo.progress! * 100}%',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black38),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.upload,
                                        size: 12, color: Colors.black38),
                                    Text(filesize(torrentInfo.upSpeed),
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black38))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.cloud_upload,
                                        size: 12, color: Colors.black38),
                                    Text(filesize(torrentInfo.uploaded),
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black38))
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.download,
                                        size: 12, color: Colors.black38),
                                    Text(filesize(torrentInfo.dlSpeed),
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black38))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.cloud_download,
                                        size: 12, color: Colors.black38),
                                    Text(filesize(torrentInfo.downloaded),
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black38))
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.timer,
                                      size: 12,
                                      color: Colors.black38,
                                    ),
                                    EllipsisText(
                                      text: formatDuration(
                                              torrentInfo.timeActive!)
                                          .toString(),
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.black38),
                                      maxLines: 1,
                                      ellipsis: '...',
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.timer,
                                      size: 12,
                                      color: Colors.black38,
                                    ),
                                    EllipsisText(
                                      text: DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  torrentInfo.addedOn! * 1000))
                                          .toString(),
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.black38),
                                      maxLines: 1,
                                      ellipsis: '...',
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrTorrentCard(TransmissionBaseTorrent torrentInfo) {
    double cardHeight = 64;
    return Slidable(
      key: ValueKey(torrentInfo.id.toString()),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            return;
          },
          confirmDismiss: () async {
            return false;
          },
        ),
        children: [
          const SlidableAction(
            onPressed: null,
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
          const SlidableAction(
            onPressed: null,
            backgroundColor: Color(0xFF21B7CA),
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  Get.defaultDialog(
                      title: '',
                      middleText: '重新校验种子？',
                      onConfirm: () async {
                        await controller.controlTorrents(
                            command: 'recheck',
                            hashes: [torrentInfo.hashString!]);
                      },
                      cancel: const Text('取消'),
                      confirm: const Text('确定'));
                },
                icon: const Icon(Icons.autorenew),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'ForceStart', hashes: [torrentInfo.hashString!]);
                },
                icon: Icon(
                  Icons.keyboard_double_arrow_up,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          Column(
            children: [
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'command', hashes: [torrentInfo.hashString!]);
                },
                icon: const Icon(Icons.local_offer),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'AutoManagement',
                      hashes: [torrentInfo.hashString!]);
                },
                icon: const Icon(Icons.autofps_select_outlined,
                    color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'resume', hashes: [torrentInfo.hashString!]);
                },
                icon: const Icon(Icons.play_arrow),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'SuperSeeding',
                      hashes: [torrentInfo.hashString!]);
                },
                icon: const Icon(Icons.double_arrow, color: GFColors.PRIMARY),
              ),

              // GFIconButton(
              //   size: 8,
              //   type: GFButtonType.transparent,
              //   onPressed: () {},
              //   icon: const Icon(Icons.category),
              // ),
            ],
          ),
          Column(
            children: [
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'delete', hashes: [torrentInfo.hashString!]);
                },
                icon: const Icon(Icons.delete_forever),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'command', hashes: [torrentInfo.hashString!]);
                },
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
          Column(
            children: [
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  await controller.controlTorrents(
                      command: 'reannounce', hashes: [torrentInfo.hashString!]);
                },
                icon: const Icon(Icons.campaign),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  Clipboard.setData(
                      ClipboardData(text: torrentInfo.hashString!));
                  Get.snackbar('复制种子HASH', '种子HASH复制成功！');
                },
                icon: const Icon(Icons.copy),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () async {
                  Clipboard.setData(
                      ClipboardData(text: torrentInfo.magnetLink!));
                  Get.snackbar('复制下载链接', '下载链接复制成功！');
                },
                icon: const Icon(Icons.link),
              ),
              // GFIconButton(
              //   size: 8,
              //   type: GFButtonType.transparent,
              //   onPressed: () async {
              //     await controller.controlTorrents(
              //         command: 'command', hashes: [torrentInfo.hash!]);
              //   },
              //   icon: Icon(Icons.location_searching),
              // ),
            ],
          ),
          const SlidableAction(
            // An action can be bigger than the others.
            flex: 2,
            onPressed: null,
            backgroundColor: Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: 'Archive',
          ),
          const SlidableAction(
            onPressed: null,
            flex: 2,
            backgroundColor: Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.save,
            label: 'Save',
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: SizedBox(
                height: cardHeight, // width: 100,
                child: SfLinearGauge(
                  showTicks: false,
                  showLabels: false,
                  animateAxis: true,
                  // labelPosition: LinearLabelPosition.outside,
                  axisTrackStyle: LinearAxisTrackStyle(
                    thickness: cardHeight,
                    edgeStyle: LinearEdgeStyle.bothFlat,
                    borderWidth: 2,
                    borderColor: Color(0xff898989),
                    color: Colors.transparent,
                  ),
                  barPointers: <LinearBarPointer>[
                    LinearBarPointer(
                        value: torrentInfo.percentDone! * 100,
                        thickness: cardHeight,
                        edgeStyle: LinearEdgeStyle.bothFlat,
                        color: Colors.green.shade100),
                  ],
                )),
          ),
          GestureDetector(
            onTap: () {
              Get.snackbar('单击', '单击！');
            },
            onLongPress: () {
              Get.snackbar('长按', '长按！');
            },
            onDoubleTap: () {
              Get.snackbar('双击', '双击！');
            },
            child: GFCard(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              height: cardHeight,
              boxFit: BoxFit.cover,
              color: Colors.white54,
              title: GFListTile(
                padding: EdgeInsets.zero,
                title: EllipsisText(
                  text: torrentInfo.name!,
                  ellipsis: '...',
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold),
                ),
                subTitle: Row(
                  children: [
                    const Icon(
                      Icons.format_size,
                      color: Colors.black38,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(torrentInfo.percentDone.toString(),
                        style: const TextStyle(
                            fontSize: 10, color: Colors.black38)),
                    const SizedBox(width: 3),
                  ],
                ),
                // icon: Text(torrentInfo.!,
                //     style: const TextStyle(fontSize: 10, color: Colors.black38)),
                // description: Text(torrentInfo.savePath!,
                //     style: const TextStyle(fontSize: 10, color: Colors.black38)),
              ),
              content: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.upload,
                            size: 12, color: Colors.black38),
                        Text(filesize(torrentInfo.rateUpload),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black38))
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.cloud_upload,
                            size: 12, color: Colors.black38),
                        Text(torrentInfo.percentDone.toString(),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black38))
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.download,
                            size: 12, color: Colors.black38),
                        Text(filesize(torrentInfo.rateDownload),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black38))
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.cloud_download,
                            size: 12, color: Colors.black38),
                        Text(filesize(torrentInfo.status),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black38))
                      ],
                    ),
                    Text(
                      '${(torrentInfo.percentDone! * 100).toStringAsFixed(2)}%',
                      style:
                          const TextStyle(fontSize: 10, color: Colors.black38),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
