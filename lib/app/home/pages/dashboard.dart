import 'package:auxi_app/api/mysite.dart';
import 'package:auxi_app/common/glass_widget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/site_status.dart';

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

  List<SiteStatus> statusList = [];
  TooltipBehavior? _tooltipBehavior;
  int uploaded = 0;
  int downloaded = 0;
  int seedVol = 0;

  @override
  void initState() {
    initPieChartData();
    super.initState();
  }

  void initPieChartData() {
    getSiteStatusList().then((value) {
      if (value.code == 0) {
        setState(() {
          statusList = value.data;
          statusList.sort((SiteStatus a, SiteStatus b) =>
              b.statusUploaded!.compareTo(a.statusUploaded!));
          // statusList.shuffle();

          for (var element in statusList) {
            uploaded += element.statusUploaded!;
            downloaded += element.statusDownloaded!;
            seedVol += element.statusSeedVolume!;
          }
          _tooltipBehavior = TooltipBehavior(
            enable: true,
            header: '',
            canShowMarker: false,
            activationMode: ActivationMode.singleTap,
            builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
              return Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.teal.shade300,
                  border: Border.all(width: 2, color: Colors.teal.shade400),
                ),
                child: Text(
                  '${data.mySiteNickname}: ${filesize(data.statusUploaded)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              );
            },
          );
        });
      } else {
        Get.snackbar(
          'Error',
          value.msg!,
          backgroundColor: Colors.teal,
        );
      }
    }).catchError((e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.teal,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassWidget(
        child: Container(
          color: Colors.grey.withOpacity(0.5),
          child: Column(
            children: [
              _buildGridView(),
              Expanded(
                child: EasyRefresh(
                  onRefresh: initPieChartData,
                  child: ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.teal.withOpacity(0.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.upload,
                                  color: Colors.green,
                                  size: 14,
                                ),
                                const SizedBox(width: 0.5),
                                Text(
                                  '下载量${filesize(uploaded)}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.download,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 0.5),
                                Text(
                                  '下载量${filesize(downloaded)}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.cloud_upload,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 0.5),
                                Text(
                                  '做种量${filesize(seedVol)}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildSmartLabelPieChart(),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the circular charts with pie series.
  Widget _buildSmartLabelPieChart() {
    return SizedBox(
      height: 280,
      child: SfCircularChart(
        title: ChartTitle(
            text: '站点上传数据汇总',
            textStyle: const TextStyle(
              fontSize: 14,
              color: Colors.white60,
            )),
        centerX: '47%',
        series: _gettSmartLabelPieSeries(),
        tooltipBehavior: _tooltipBehavior,
        enableMultiSelection: true,
      ),
    );
  }

  /// Returns the pie series with smart data labels.
  List<PieSeries<SiteStatus, String>> _gettSmartLabelPieSeries() {
    return <PieSeries<SiteStatus, String>>[
      PieSeries<SiteStatus, String>(
        name: '站点上传数据汇总',
        dataSource: statusList,
        xValueMapper: (SiteStatus data, _) => data.mySiteNickname!,
        yValueMapper: (SiteStatus data, _) => data.statusUploaded,
        dataLabelMapper: (SiteStatus data, _) =>
            '${data.mySiteNickname!}: ${filesize(data.statusUploaded)}',
        enableTooltip: true,
        explode: true,
        explodeIndex: 0,
        explodeOffset: '10%',
        radius: '80%',
        dataLabelSettings: const DataLabelSettings(
          margin: EdgeInsets.zero,
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
          textStyle: TextStyle(
            fontSize: 8.8,
            color: Colors.white60,
          ),
          showZeroValue: false,
          connectorLineSettings: ConnectorLineSettings(
            type: ConnectorType.curve,
            length: '20%',
          ),
          labelIntersectAction: LabelIntersectAction.shift,
        ),
      )
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildGridView() {
    final items = [
      GFButton(
        text: '一键签到',
        size: GFSize.SMALL,
        color: GFColors.WARNING,
        onPressed: () {
          signInAll().then((res) {
            Get.back();
            if (res.code == 0) {
              Get.snackbar(
                '签到任务',
                '签到任务信息：${res.msg}',
                colorText: Colors.white70,
                backgroundColor: Colors.teal.withOpacity(0.7),
              );
            } else {
              Get.snackbar(
                '签到失败',
                '签到任务执行出错啦：${res.msg}',
                colorText: Colors.red,
                backgroundColor: Colors.teal.withOpacity(0.7),
              );
            }
          });
        },
      ),
      GFButton(
        color: GFColors.WARNING,
        text: '刷新数据',
        size: GFSize.SMALL,
        onPressed: () {
          getNewestStatusAll().then((res) {
            Get.back();
            if (res.code == 0) {
              Get.snackbar(
                '刷新数据',
                '刷新数据任务信息：${res.msg}',
                colorText: Colors.white70,
                backgroundColor: Colors.teal.withOpacity(0.7),
              );
            } else {
              Get.snackbar(
                '刷新数据',
                '刷新数据执行出错啦：${res.msg}',
                colorText: Colors.red,
                backgroundColor: Colors.teal.withOpacity(0.7),
              );
            }
          });
        },
      ),
      // GFButton(
      //   color: GFColors.WARNING,
      //   onPressed: () {
      //     Get.snackbar("提示", '开发中');
      //   },
      //   text: '一键辅种',
      // ),
    ];
    return Container(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 1),
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            Widget item = items[index];
            return item;
          }),
    );
  }
}
