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
            Expanded(
              child: EasyRefresh(
                onRefresh: initPieChartData,
                child: ListView(
                  children: [
                    _buildSiteInfoBar(),
                    _buildBackColumnChart(),
                    _buildSmartLabelPieChart(),
                    _buildStackedBar(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _actionButtonList(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
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
                Icons.language,
                color: Colors.blue,
                size: 12,
              ),
              const SizedBox(width: 1),
              Text(
                '站点数：${statusList.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.upload,
                color: Colors.red,
                size: 12,
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
                size: 12,
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
                Icons.share,
                color: Colors.white70,
                size: 12,
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
                size: 12,
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
    return Container(
      height: 280,
      padding: const EdgeInsets.only(left: 10),
      child: SfCircularChart(
        title: ChartTitle(
            text: '站点上传数据汇总',
            textStyle: const TextStyle(
              fontSize: 11,
              color: Colors.white60,
            )),
        centerX: '47%',
        centerY: '45%',
        margin: const EdgeInsets.all(10),
        legend: const Legend(
            position: LegendPosition.left,
            // height: "20",
            isVisible: true,
            iconWidth: 8,
            padding: 5,
            itemPadding: 5,
            // width: '64',
            isResponsive: true,
            // offset: Offset(20, 0),
            // legendItemBuilder:
            //     (String name, dynamic series, dynamic point, int index) {
            //   Logger.instance.w(name);
            //   Logger.instance.w(series.series.dataSource);
            //   Logger.instance.w(point.y);
            //   // Logger.instance.w(index);
            //   SiteStatus status = series.series.dataSource[index];
            //   return Container(
            //     height: 15,
            //     width: 50,
            //     padding: EdgeInsets.zero,
            //     child: Row(
            //       children: [
            //         // const Icon(
            //         //   Icons.ac_unit_outlined,
            //         //   size: 12,
            //         //   color: Colors.white70,
            //         // ),
            //         GFImageOverlay(
            //           height: 10,
            //           width: 10,
            //           image:
            //               NetworkImage('${status.siteUrl}${status.siteLogo}'),
            //         ),
            //         EllipsisText(
            //           text: name,
            //           maxWidth: 38,
            //           style: const TextStyle(
            //             fontSize: 8,
            //             color: Colors.white70,
            //           ),
            //           isShowMore: false,
            //           ellipsis: '..',
            //           maxLines: 1,
            //         ),
            //       ],
            //     ),
            //   );
            // },
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
        radius: '65%',
        pointRenderMode: PointRenderMode.gradient,
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

  Widget _actionButtonList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 72,
          child: GFButton(
            icon: const Icon(
              Icons.edit_calendar,
              color: Colors.white,
              size: 13,
            ),
            text: '签到',
            textColor: Colors.white70,
            size: GFSize.SMALL,
            color: Colors.teal.withOpacity(0.7),
            // type: GFButtonType.transparent,
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
        ),
        SizedBox(
          width: 72,
          child: GFButton(
            color: Colors.teal.withOpacity(0.7),
            text: '刷新',
            textColor: Colors.white70,
            size: GFSize.SMALL,
            // type: GFButtonType.transparent,
            icon: const Icon(
              Icons.refresh,
              size: 12,
              color: Colors.white70,
            ),
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
        ),
        // GFButton(
        //   color: GFColors.WARNING,
        //   onPressed: () {
        //     Get.snackbar("提示", '开发中');
        //   },
        //   text: '一键辅种',
        // ),
      ],
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
          margin: const EdgeInsets.all(15),
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
              borderRadius: BorderRadius.circular(5),
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

  Widget _buildBackColumnChart() {
    late ZoomPanBehavior zoomPan = ZoomPanBehavior(
      enableDoubleTapZooming: true,
      enablePanning: true,
      enablePinching: true,
      enableSelectionZooming: true,
      enableMouseWheelZooming: true,
      zoomMode: ZoomMode.y,
      // maximumZoomLevel: 100,
      selectionRectBorderWidth: 3,
    );
    return SizedBox(
      height: 350,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        isTransposed: true,
        enableSideBySideSeriesPlacement: false,
        title: ChartTitle(
            text: '数据汇总',
            textStyle: const TextStyle(
              fontSize: 11,
              color: Colors.white60,
            )),
        margin: const EdgeInsets.only(right: 40, left: 15, top: 5),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          header: '',
          canShowMarker: false,
          activationMode: ActivationMode.singleTap,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
              int seriesIndex) {
            return Container(
              padding: const EdgeInsets.all(5),
              width: 120,
              height: 78,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                border: Border.all(width: 2, color: Colors.teal.shade400),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.language,
                          color: Colors.white70,
                          size: 12,
                        ),
                        Text(
                          '${data.mySiteNickname}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.upload,
                          color: Colors.green,
                          size: 12,
                        ),
                        Text(
                          filesize(data.statusUploaded),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.download,
                          color: Colors.deepOrange,
                          size: 12,
                        ),
                        Text(
                          filesize(data.statusDownloaded),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        zoomPanBehavior: zoomPan,
        primaryXAxis: CategoryAxis(
          rangePadding: ChartRangePadding.round,
          majorGridLines: const MajorGridLines(width: 0),
          isInversed: true,
          autoScrollingMode: AutoScrollingMode.end,
          labelStyle: const TextStyle(fontSize: 10, color: Colors.white70),
          labelPosition: ChartDataLabelPosition.inside,
          tickPosition: TickPosition.inside,
          placeLabelsNearAxisLine: true,
        ),
        primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 1),
          zoomFactor: 0.9,
          zoomPosition: 1,
          visibleMinimum: 2.0,
          majorTickLines: const MajorTickLines(size: 0),
          majorGridLines: const MajorGridLines(width: 0.5),
          rangePadding: ChartRangePadding.additional,
          axisLabelFormatter: (AxisLabelRenderDetails details) {
            return ChartAxisLabel(
              ProperFilesize.generateHumanReadableFilesize(details.value),
              const TextStyle(fontSize: 10, color: Colors.white70),
            );
          },
        ),
        series: _getBackToBackColumn(),
      ),
    );
  }

  List<ColumnSeries<SiteStatus, String>> _getBackToBackColumn() {
    // List<SiteStatus> dataSource = statusList.sublist(0);
    // dataSource.sort((SiteStatus b, SiteStatus a) =>
    //     b.statusUploaded!.compareTo(a.statusUploaded!));
    return <ColumnSeries<SiteStatus, String>>[
      ColumnSeries<SiteStatus, String>(
        dataSource: statusList,
        width: 0.7,
        xValueMapper: (SiteStatus status, _) => status.mySiteNickname,
        yValueMapper: (SiteStatus status, _) => status.statusUploaded,
        dataLabelMapper: (SiteStatus status, _) =>
            '${status.mySiteNickname!}: ⬆ ${filesize(status.statusUploaded)} ⬇ ${filesize(status.statusDownloaded)}',
        name: '上传',
        borderRadius: BorderRadius.circular(5),
        dataLabelSettings: const DataLabelSettings(
          margin: EdgeInsets.zero,
          isVisible: false,
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
      ),
      ColumnSeries<SiteStatus, String>(
        dataSource: statusList,
        width: 0.5,
        xValueMapper: (SiteStatus status, _) => status.mySiteNickname,
        yValueMapper: (SiteStatus status, _) => status.statusDownloaded,
        // dataLabelMapper: (SiteStatus status, _) =>
        //     '${status.mySiteNickname!}:下载 ${filesize(status.statusDownloaded)}',
        name: '下载',
        borderRadius: BorderRadius.circular(5),
        dataLabelSettings: const DataLabelSettings(
          margin: EdgeInsets.zero,
          isVisible: false,
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
      ),
    ];
  }
}
