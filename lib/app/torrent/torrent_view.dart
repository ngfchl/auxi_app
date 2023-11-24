import 'package:auxi_app/common/glass_widget.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../utils/logger_helper.dart' as LoggerHelper;
import '../home/models/downloader/transmission_base_torrent.dart';
import 'torrent_controller.dart';

class TorrentView extends GetView<TorrentController> {
  const TorrentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder<TorrentController>(builder: (controller) {
          return Text(controller.downloader.name);
        }),
        centerTitle: true,
      ),
      body: GlassWidget(
        child: GetBuilder<TorrentController>(builder: (controller) {
          return ListView.builder(
              itemCount: controller.torrents.length,
              itemBuilder: (BuildContext context, int index) {
                if (controller.downloader.category.toLowerCase() == 'qb') {
                  TorrentInfo torrentInfo = controller.torrents[index];
                  return _buildQbTorrentCard(torrentInfo);
                } else {
                  TransmissionBaseTorrent torrentInfo =
                      controller.torrents[index];
                  return _buildTrTorrentCard(torrentInfo);
                }
              });
        }),
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
                '添加下载器',
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: SizedBox(
              height: 180,
              // width: 100,
              child: SfLinearGauge(
                showTicks: false,
                showLabels: false,
                animateAxis: true,
                // labelPosition: LinearLabelPosition.outside,
                axisTrackStyle: const LinearAxisTrackStyle(
                  thickness: 180,
                  edgeStyle: LinearEdgeStyle.bothFlat,
                  borderWidth: 0,
                  borderColor: Color(0xff898989),
                  color: Colors.transparent,
                ),
                barPointers: <LinearBarPointer>[
                  LinearBarPointer(
                      value: torrentInfo.progress! * 100,
                      thickness: 180,
                      edgeStyle: LinearEdgeStyle.bothFlat,
                      color: Colors.green.shade100),
                ],
              )),
        ),
        GFCard(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          boxFit: BoxFit.cover,
          color: Colors.white54,
          title: GFListTile(
            title: EllipsisText(
              text: torrentInfo.name!,
              ellipsis: '...',
              maxLines: 1,
              style: const TextStyle(
                  fontSize: 14,
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
                Text(filesize(torrentInfo.size),
                    style:
                        const TextStyle(fontSize: 10, color: Colors.black38)),
              ],
            ),
            icon: Text(torrentInfo.category!,
                style: const TextStyle(fontSize: 10, color: Colors.black38)),
            description: Text(torrentInfo.savePath!,
                style: const TextStyle(fontSize: 10, color: Colors.black38)),
          ),
          content: Align(
            alignment: Alignment.centerRight,
            child: Column(
              children: [
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
                                    fontSize: 10, color: Colors.black38))
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.cloud_upload,
                                size: 12, color: Colors.black38),
                            Text(filesize(torrentInfo.uploaded),
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.black38))
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
                                    fontSize: 10, color: Colors.black38))
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.cloud_download,
                                size: 12, color: Colors.black38),
                            Text(filesize(torrentInfo.downloaded),
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.black38))
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
                              text: formatDuration(torrentInfo.timeActive!)
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
                                  .format(DateTime.fromMillisecondsSinceEpoch(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.explore,
                          size: 12,
                          color: Colors.black38,
                        ),
                        SizedBox(
                          width: 300,
                          child: EllipsisText(
                            text: torrentInfo.tracker!,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black38),
                            maxLines: 1,
                            ellipsis: '...',
                          ),
                        )
                      ],
                    ),
                    Text(
                      '${(torrentInfo.progress! * 100).toStringAsFixed(2)}%',
                      style:
                          const TextStyle(fontSize: 10, color: Colors.black38),
                    ),
                  ],
                ),
              ],
            ),
          ),
          buttonBar: GFButtonBar(
            children: <Widget>[
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.double_arrow),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.delete_forever),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.edit),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.category),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.local_offer),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.autofps_select_outlined),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.keyboard_double_arrow_up),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.autorenew),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.campaign),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.copy),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.exit_to_app),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.location_searching),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrTorrentCard(TransmissionBaseTorrent torrentInfo) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: SizedBox(
              height: 180,
              // width: 100,
              child: SfLinearGauge(
                showTicks: false,
                showLabels: false,
                animateAxis: true,
                // labelPosition: LinearLabelPosition.outside,
                axisTrackStyle: const LinearAxisTrackStyle(
                  thickness: 180,
                  edgeStyle: LinearEdgeStyle.bothFlat,
                  borderWidth: 2,
                  borderColor: Color(0xff898989),
                  color: Colors.transparent,
                ),
                barPointers: <LinearBarPointer>[
                  LinearBarPointer(
                      value: torrentInfo.percentDone! * 100,
                      thickness: 180,
                      edgeStyle: LinearEdgeStyle.bothFlat,
                      color: Colors.green.shade100),
                ],
              )),
        ),
        GFCard(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          height: 180,
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
                    style:
                        const TextStyle(fontSize: 10, color: Colors.black38)),
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
                    const Icon(Icons.upload, size: 12, color: Colors.black38),
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
                    const Icon(Icons.download, size: 12, color: Colors.black38),
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
                  style: const TextStyle(fontSize: 10, color: Colors.black38),
                ),
              ],
            ),
          ),
          buttonBar: GFButtonBar(
            children: <Widget>[
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.double_arrow),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.delete_forever),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.edit),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.category),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.local_offer),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.autofps_select_outlined),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.keyboard_double_arrow_up),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.autorenew),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.campaign),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.copy),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.exit_to_app),
              ),
              GFIconButton(
                size: 8,
                type: GFButtonType.transparent,
                onPressed: () {},
                icon: const Icon(Icons.location_searching),
              ),
            ],
          ),
        )
      ],
    );
  }
}
