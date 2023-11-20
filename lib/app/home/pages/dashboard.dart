import 'package:auxi_app/api/mysite.dart';
import 'package:auxi_app/common/glass_widget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:proper_filesize/proper_filesize.dart';
import 'package:random_color/random_color.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../utils/logger_helper.dart';
import '../models/mysite.dart';
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
  List<Map<String, dynamic>> pieDataList = [
    {
      'genre': '站点',
      'sold': 10240000,
    }
  ];
  List<Map> stackChartDataList = [];
  int uploaded = 0;
  int downloaded = 0;
  int seedVol = 0;

  @override
  void initState() {
    initPieChartData();

    super.initState();
  }

  void initPieChartData() {
    getMySiteChartV2().then((value) {
      if (value.code == 0) {
        // Logger.instance.w(value.data);
        setState(() {
          stackChartDataList.clear();
          value.data.forEach((element) {
            Logger.instance.w(element);
            MySite mySite = MySite.fromJson(element['site']);
            List<SiteBaseStatus> statusList = element['data']
                .map<SiteBaseStatus>((item) => SiteBaseStatus.fromJson(item))
                .toList();
            statusList.sort((SiteBaseStatus a, SiteBaseStatus b) =>
                a.updatedDate!.compareTo(b.updatedDate!));
            stackChartDataList
                .add({'site': mySite.nickname, "data": statusList});
          });
        });
        stackChartDataList
            .sort((Map a, Map b) => a['site'].compareTo(b['site']));
        // Logger.instance.w(stackChartDataList[0]);
      }
    });
    getSiteStatusList().then((value) {
      if (value.code == 0) {
        setState(() {
          uploaded = 0;
          downloaded = 0;
          seedVol = 0;
          statusList = value.data;
          statusList.sort((SiteStatus a, SiteStatus b) =>
              b.statusUploaded!.compareTo(a.statusUploaded!));
          // statusList.shuffle();
          pieDataList = statusList
              .map((SiteStatus e) => {
                    'genre': e.mySiteNickname,
                    'sold': e.statusUploaded,
                  })
              .toList();
          // Logger.instance.w(pieDataList);
          for (var element in statusList) {
            uploaded += element.statusUploaded!;
            downloaded += element.statusDownloaded!;
            seedVol += element.statusSeedVolume!;
          }
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
        child: Column(
          children: [
            _buildGridView(),
            Expanded(
              child: EasyRefresh(
                onRefresh: initPieChartData,
                child: ListView(
                  children: [
                    _buildSiteInfoBar(),
                    // const SizedBox(height: 15),
                    _buildSmartLabelPieChart(),
                    // const SizedBox(height: 10),
                    _buildStackedBar(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _buildSiteInfoBar() {
    return Container(
      padding: const EdgeInsets.all(5),
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
                size: 10,
              ),
              const SizedBox(width: 1),
              Text(
                filesize(uploaded),
                style: const TextStyle(color: Colors.white70, fontSize: 11),
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
              const SizedBox(width: 1),
              Text(
                filesize(downloaded),
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.ios_share,
                color: Colors.white70,
                size: 14,
              ),
              const SizedBox(width: 1),
              Text(
                downloaded > 0
                    ? '${(uploaded / downloaded).roundToDouble()}'
                    : '♾️',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
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
              const SizedBox(width: 1),
              Text(
                filesize(seedVol),
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
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
              fontSize: 11,
              color: Colors.white60,
            )),
        centerX: '47%',
        centerY: '45%',
        legend: const Legend(
            height: "200",
            isVisible: true,
            iconWidth: 8,
            padding: 5,
            itemPadding: 5,
            width: '64',
            isResponsive: true,
            // offset: Offset(20, 0),
            textStyle: TextStyle(
              fontSize: 8,
              color: Colors.white70,
            )),
        series: _gettSmartLabelPieSeries(),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          header: '',
          canShowMarker: false,
          activationMode: ActivationMode.singleTap,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
              int seriesIndex) {
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
        ),
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
        radius: '60%',
        dataLabelSettings: const DataLabelSettings(
          margin: EdgeInsets.zero,
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
          textStyle: TextStyle(
            fontSize: 8,
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
    statusList.clear();
    uploaded = 0;
    downloaded = 0;
    seedVol = 0;
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

  Widget _buildStackedBar() {
    return SizedBox(
      height: 280,
      child: SfCartesianChart(
          title: ChartTitle(
              text: '每日数据',
              textStyle: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              )),
          isTransposed: true,
          legend: const Legend(
              isVisible: false,
              iconWidth: 8,
              iconHeight: 8,
              padding: 5,
              itemPadding: 5,
              textStyle: TextStyle(
                fontSize: 8,
                color: Colors.white70,
              )),
          enableSideBySideSeriesPlacement: false,
          plotAreaBorderWidth: 0,
          enableAxisAnimation: true,
          selectionType: SelectionType.series,
          tooltipBehavior: TooltipBehavior(
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
            majorGridLines: const MajorGridLines(width: 0),
            axisLabelFormatter: (AxisLabelRenderDetails details) {
              return ChartAxisLabel(
                details.text,
                const TextStyle(fontSize: 10, color: Colors.white70),
              );
            },
          ),
          primaryYAxis: NumericAxis(
            axisLine: const AxisLine(width: 0),
            axisLabelFormatter: (AxisLabelRenderDetails details) {
              return ChartAxisLabel(
                ProperFilesize.generateHumanReadableFilesize(details.value),
                const TextStyle(fontSize: 10, color: Colors.white70),
              );
            },
            majorTickLines: const MajorTickLines(size: 0),
          ),
          series: List.generate(stackChartDataList.length, (index) {
            var siteData = stackChartDataList[index];
            List<SiteBaseStatus> dataSource = siteData['data'].sublist(0);
            return StackedBarSeries<SiteBaseStatus, String>(
              name: siteData['site'],
              // selectionBehavior: SelectionBehavior(
              //   enable: true,
              //     selectionController: RangeController
              // ),
              onPointTap: (ChartPointDetails details) {
                for (CartesianChartPoint e in details.dataPoints!) {
                  Logger.instance.w(e.x);
                  Logger.instance.w(e.regionData);
                }
              },
              legendIconType: LegendIconType.circle,
              dataSource: dataSource,
              isVisibleInLegend: true,
              xValueMapper: (SiteBaseStatus status, loop) => loop > 0
                  ? status.updatedDate!
                  // .substring(status.updatedDate!.length - 5)
                  : null,
              yValueMapper: (SiteBaseStatus status, loop) {
                // Logger.instance.w(status.uploaded!);
                // Logger.instance.w(siteData['data'][loop].uploaded);
                if (loop > 0 && loop < dataSource.length) {
                  num increase =
                      status.uploaded! - dataSource[loop - 1].uploaded!;
                  return increase > 0 ? increase : 0;
                }
                return null;
              },
              pointColorMapper: (SiteBaseStatus status, _) =>
                  RandomColor().randomColor(),
              emptyPointSettings: EmptyPointSettings(
                mode: EmptyPointMode.drop,
              ),
              dataLabelMapper: (SiteBaseStatus status, _) => siteData['site'],
              // color: RandomColor().randomColor(),
              enableTooltip: true,
            );
          }).toList()),
    );
  }
}
