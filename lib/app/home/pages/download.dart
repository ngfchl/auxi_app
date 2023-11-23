import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:proper_filesize/proper_filesize.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../common/glass_widget.dart';
import '../../../models/download.dart';
import '../../../models/transmission.dart';
import '../../../utils/logger_helper.dart' as LoggerHelper;
import 'controller/download_controller.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState
    extends State<DownloadPage> // with AutomaticKeepAliveClientMixin
{
  bool isLoaded = false;

  // List<Downloader> dataList = [];
  DownloadController controller = Get.put(DownloadController());

  // @override
  // bool get wantKeepAlive => true;

  @override
  void initState() {
    // getDownloaderList().then((value) {
    //   if (value.code == 0) {
    //     setState(() {
    //       dataList = value.data;
    //       isLoaded = true;
    //     });
    //   } else {
    //     GFToast.showToast(
    //       value.msg,
    //       context,
    //       backgroundColor: GFColors.SECONDARY,
    //     );
    //   }
    // }).catchError((e) => GFToast.showToast(e.toString(), context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GetBuilder<DownloadController>(builder: (controller) {
        return StreamBuilder<List<Downloader>>(
          stream: controller.downloadStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Downloader> data = snapshot.data!;
              LoggerHelper.Logger.instance.w(data.length);
              return GlassWidget(
                child: EasyRefresh(
                  controller: EasyRefreshController(),
                  onRefresh: () async {
                    controller.getDownloaderListFromServer();
                    controller.startPeriodicTimer();
                  },
                  child: ListView.builder(
                      itemCount: controller.dataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        Downloader downloader = controller.dataList[index];
                        return buildDownloaderCard(downloader);
                      }),
                ),
              );
            } else if (snapshot.hasError) {
              LoggerHelper.Logger.instance.w('Error 85');
              return Text('Error: ${snapshot.error}');
            } else {
              LoggerHelper.Logger.instance.w('Error 88');
              return const Center(child: GFLoader());
            }
          },
        );
      }),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(() {
            return GFIconButton(
              icon: controller.isTimerActive.value
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
              shape: GFIconButtonShape.standard,
              color: GFColors.PRIMARY.withOpacity(0.6),
              onPressed: () {
                // controller.cancelPeriodicTimer();
                controller.isTimerActive.value
                    ? controller.periodicTimer.cancel()
                    : controller.startPeriodicTimer();
                LoggerHelper.Logger.instance
                    .w(controller.periodicTimer.isActive);
                LoggerHelper.Logger.instance.w(controller.isTimerActive.value);
                controller.update();
              },
            );
          }),
          GFIconButton(
            icon: const Icon(Icons.play_arrow),
            shape: GFIconButtonShape.standard,
            color: GFColors.PRIMARY.withOpacity(0.6),
            onPressed: () {
              controller.startPeriodicTimer();
            },
          ),
          GFIconButton(
            icon: const Icon(Icons.add),
            shape: GFIconButtonShape.standard,
            color: GFColors.PRIMARY.withOpacity(0.6),
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

  Widget _buildLiveLineChart(
      Downloader downloader, ChartSeriesController? chartSeriesController) {
    if (downloader.status.isEmpty) {
      return const GFLoader();
    }
    LoggerHelper.Logger.instance.w(downloader.status);
    double chartHeight = 80;
    if (downloader.category.toLowerCase() == 'qb') {
      List<TransferInfo> dataSource = downloader.status.cast<TransferInfo>();
      chartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[dataSource.length - 1],
      );
      TransferInfo res = downloader.status.last;
      return SizedBox(
        height: chartHeight,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        decimalPlaces: 1,
                        builder: (dynamic data, dynamic point, dynamic series,
                            int pointIndex, int seriesIndex) {
                          // Logger.instance.w(data);
                          return Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade300,
                              border: Border.all(
                                  width: 2, color: Colors.teal.shade400),
                            ),
                            child: Text(
                              '${series.name}: ${filesize(point.y)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          );
                        },
                      ),
                      primaryXAxis: CategoryAxis(
                          isVisible: false,
                          majorGridLines: const MajorGridLines(width: 0),
                          labelStyle: const TextStyle(
                              fontSize: 8, color: Colors.white70),
                          edgeLabelPlacement: EdgeLabelPlacement.shift),
                      primaryYAxis: NumericAxis(
                          axisLine: const AxisLine(width: 0),
                          axisLabelFormatter: (AxisLabelRenderDetails details) {
                            return ChartAxisLabel(
                              ProperFilesize.generateHumanReadableFilesize(
                                  details.value),
                              const TextStyle(
                                  fontSize: 10, color: Colors.white70),
                            );
                          },
                          majorTickLines: const MajorTickLines(size: 0)),
                      series: [
                        AreaSeries<TransferInfo, int>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            chartSeriesController = controller;
                          },
                          animationDuration: 0,
                          dataSource: dataSource,
                          enableTooltip: true,
                          xValueMapper: (TransferInfo sales, index) => index,
                          yValueMapper: (TransferInfo sales, _) =>
                              sales.upInfoSpeed,
                          name: '上传速度',
                        ),
                        AreaSeries<TransferInfo, int>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            chartSeriesController = controller;
                          },
                          animationDuration: 0,
                          dataSource: dataSource,
                          enableTooltip: true,
                          xValueMapper: (TransferInfo sales, index) => index,
                          yValueMapper: (TransferInfo sales, _) =>
                              sales.dlInfoSpeed,
                          color: Colors.red,
                          name: '下载速度',
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '上传限速：${filesize(res.upRateLimit)}/S',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '下载限速：${filesize(res.dlInfoSpeed)}/S',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            getSpeedInfo(downloader),
          ],
        ),
      );
    } else {
      List<TransmissionStats> dataSource =
          downloader.status.cast<TransmissionStats>();
      TransmissionStats res = downloader.status.last;
      return SizedBox(
        height: chartHeight,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      primaryXAxis: CategoryAxis(
                          isVisible: false,
                          majorGridLines: const MajorGridLines(width: 0),
                          edgeLabelPlacement: EdgeLabelPlacement.shift),
                      primaryYAxis: NumericAxis(
                          axisLine: const AxisLine(width: 0),
                          axisLabelFormatter: (AxisLabelRenderDetails details) {
                            return ChartAxisLabel(
                              ProperFilesize.generateHumanReadableFilesize(
                                  details.value),
                              const TextStyle(
                                  fontSize: 10, color: Colors.white70),
                            );
                          },
                          majorTickLines: const MajorTickLines(size: 0)),
                      series: <AreaSeries<TransmissionStats, String>>[
                        AreaSeries<TransmissionStats, String>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            chartSeriesController = controller;
                          },
                          animationDuration: 0,
                          dataSource: dataSource,
                          xValueMapper: (TransmissionStats sales, index) =>
                              DateTime.now().toString(),
                          yValueMapper: (TransmissionStats sales, _) =>
                              sales.uploadSpeed,
                          enableTooltip: true,
                          name: '上传速度',
                        ),
                        AreaSeries<TransmissionStats, String>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            // _chartSeriesController = controller;
                          },
                          animationDuration: 0,
                          dataSource: dataSource,
                          xValueMapper: (TransmissionStats sales, index) =>
                              DateTime.now().toString(),
                          yValueMapper: (TransmissionStats sales, _) =>
                              sales.downloadSpeed,
                          enableTooltip: true,
                          name: '下载速度',
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '活动种子：${res.activeTorrentCount}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        '暂停种子：${res.pausedTorrentCount}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            getSpeedInfo(downloader),
          ],
        ),
      );
    }
  }

  Widget buildDownloaderCard(Downloader downloader) {
    bool connectState = true;
    // getDownloaderConnectTest(downloader.id).then((res) {
    //   connectState = res.code == 0;
    // });
    ChartSeriesController? chartSeriesController;
    return GFCard(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 5),
      padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10),
      boxFit: BoxFit.cover,
      color: Colors.transparent,
      title: GFListTile(
        padding: const EdgeInsets.all(0),
        avatar: GFAvatar(
          // shape: GFAvatarShape.square,
          backgroundImage: AssetImage(
              'assets/images/${downloader.category.toLowerCase()}.png'),
          size: 18,
        ),
        title: Text(
          downloader.name,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subTitle: Text(
          '${downloader.http}://${downloader.host}:${downloader.port}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        icon: GFIconButton(
          icon: connectState
              ? const Icon(
                  Icons.flash_on,
                  color: Colors.white70,
                  size: 24,
                )
              : const Icon(
                  Icons.flash_off,
                  color: Colors.red,
                  size: 24,
                ),
          type: GFButtonType.transparent,
          onPressed: () {
            controller.testConnect(downloader).then((res) {
              Get.snackbar(
                '下载器连接测试',
                '',
                messageText: EllipsisText(
                  text: res.msg!,
                  ellipsis: '...',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    color: res.code == 0 ? Colors.white : Colors.red,
                  ),
                ),
                colorText: res.code == 0 ? Colors.white : Colors.red,
              );
            });
          },
        ),
      ),
      content: _buildLiveLineChart(downloader, chartSeriesController),
      // buttonBar: GFButtonBar(
      //   children: <Widget>[
      //     GFButton(
      //       onPressed: () async {
      //         await getQbSpeed(downloader);
      //       },
      //       text: 'Buy',
      //     ),
      //     GFButton(
      //       onPressed: () {},
      //       text: 'Cancel',
      //     ),
      //   ],
      // ),
    );
  }

  Widget getSpeedInfo(Downloader downloader) {
    if (downloader.status.isEmpty) {
      return const GFLoader();
    }
    if (downloader.category == 'Qb') {
      TransferInfo res = downloader.status.last;

      return Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  textBaseline: TextBaseline.ideographic,
                  children: [
                    const Icon(
                      Icons.upload_outlined,
                      color: Colors.green,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${filesize(res.upInfoSpeed!)}/S',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.download_outlined,
                      color: Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${filesize(res.dlInfoSpeed!)}/S',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.cloud_upload_rounded,
                      color: Colors.green,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      filesize(res.upInfoData),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_download_rounded,
                      color: Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      filesize(res.dlInfoData),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
              ],
            ),
          ),
        ],
      );
    } else {
      TransmissionStats res = downloader.status.last;
      LoggerHelper.Logger.instance.w(res.runtimeType);
      return Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.upload_outlined,
                  color: Colors.green,
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  '${filesize(res.uploadSpeed)}/S',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(
                  Icons.download_outlined,
                  color: Colors.red,
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  '${filesize(res.downloadSpeed, 0)}/S',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(
                  Icons.cloud_upload_rounded,
                  color: Colors.green,
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  filesize(res.currentStats.uploadedBytes),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_download_rounded,
                  color: Colors.red,
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  filesize(res.currentStats.downloadedBytes),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}
