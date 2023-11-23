import 'package:auxi_app/common/glass_widget.dart';
import 'package:bruno/bruno.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:proper_filesize/proper_filesize.dart';

import '../../../../../utils/calc_weeks.dart';
import '../../../../../utils/format_number.dart';
import '../../../api/mysite.dart';
import '../../../utils/logger_helper.dart';
import '../models/site_status.dart';

class MySitePage extends StatefulWidget {
  const MySitePage({super.key, param});

  @override
  State<StatefulWidget> createState() {
    return _MySitePageState();
  }
}

class _MySitePageState extends State<MySitePage>
    with AutomaticKeepAliveClientMixin {
  List<SiteStatus> statusList = [];
  bool isLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    getSiteStatusFromServer();
    super.initState();
  }

  void getSiteStatusFromServer() {
    getSiteStatusList().then((value) {
      if (value.code == 0) {
        setState(() {
          statusList = value.data;
          isLoaded = true;
        });
      } else {
        GFToast.showToast(
          value.msg,
          context,
          backgroundColor: GFColors.SECONDARY,
        );
      }
    }).catchError((e) => GFToast.showToast(e.toString(), context));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassWidget(
        child: isLoaded
            ? EasyRefresh(
                onRefresh: () async {
                  getSiteStatusFromServer();
                },
                child: ListView.builder(
                    itemCount: statusList.length,
                    itemBuilder: (BuildContext context, int index) {
                      SiteStatus siteStatus = statusList[index];
                      return showSiteDataInfo(siteStatus);
                    }),
              )
            : const GFLoader(
                type: GFLoaderType.circle,
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
                '添加站点',
                context,
                backgroundColor: GFColors.SECONDARY,
                toastBorderRadius: 5.0,
              );
            },
          ),
          const SizedBox(height: 72)
        ],
      ),
    );
  }

  Widget showSiteDataInfo(SiteStatus siteStatus) {
    List<BrnNumberInfoItemModel> levelInfoList = [
      if (siteStatus.nextLevelRatio != null
          // &&
          // siteStatus.statusRatio! < siteStatus.nextLevelRatio!
          )
        BrnNumberInfoItemModel(
          number: '${siteStatus.statusRatio}',
          lastDesc: '${siteStatus.nextLevelRatio}',
          title: '分享率',
          // topWidget: Row(
          //   children: [
          //     Text(
          //       '${siteStatus.statusRatio}',
          //       style: const TextStyle(
          //         color: Colors.red,
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //     Text(
          //       '${siteStatus.nextLevelRatio}',
          //       style: const TextStyle(
          //         fontSize: 13,
          //       ),
          //     ),
          //   ],
          // ),
        ),
      if (siteStatus.statusUploaded != null &&
              siteStatus.statusUploaded != null &&
              siteStatus.nextLevelDownloaded != null
          // &&
          // siteStatus.statusUploaded! <
          //     ProperFilesize.parseHumanReadableFilesize(
          //             siteStatus.nextLevelDownloaded!) *
          //         siteStatus.nextLevelRatio!
          )
        BrnNumberInfoItemModel(
          number: filesize(siteStatus.statusUploaded),
          // topWidget: Row(
          //   children: [
          //     Text(
          //       filesize(siteStatus.statusUploaded),
          //       style: const TextStyle(
          //         color: Colors.red,
          //         fontSize: 13,
          //       ),
          //     ),
          //     Text(
          //       siteStatus.nextLevelUploaded!,
          //       style: const TextStyle(
          //         color: Colors.red,
          //         fontSize: 13,
          //       ),
          //     ),
          //   ],
          // ),
          lastDesc: ProperFilesize.generateHumanReadableFilesize(
              ProperFilesize.parseHumanReadableFilesize(
                      siteStatus.nextLevelDownloaded!) *
                  siteStatus.nextLevelRatio!,
              decimals: 2),
          title: '上传量',
          // bottomWidget: const Text(
          //   '上传量',
          //   style: TextStyle(
          //     color: Colors.red,
          //     fontSize: 12,
          //   ),
          // ),
        ),
      if (siteStatus.nextLevelDownloaded != null
          // &&
          // siteStatus.nextLevelDownloaded!.compareTo(
          //         filesize(siteStatus.statusDownloaded)) > 0

          )
        BrnNumberInfoItemModel(
          number: filesize(siteStatus.statusDownloaded),
          lastDesc: siteStatus.nextLevelDownloaded!,
          title: '下载量',
          // topWidget: Row(
          //   children: [
          //     Text(
          //       filesize(siteStatus.statusDownloaded),
          //       style: const TextStyle(
          //         color: Colors.red,
          //         fontSize: 13,
          //       ),
          //     ),
          //     Text(
          //       siteStatus.nextLevelDownloaded!,
          //       style: const TextStyle(
          //         color: Colors.red,
          //         fontSize: 13,
          //       ),
          //     ),
          //   ],
          // ),
          // bottomWidget: const Text(
          //   '下载量',
          //   style: TextStyle(
          //     color: Colors.red,
          //     fontSize: 12,
          //   ),
          // ),
        ),
      if (siteStatus.nextLevelBonus != null && siteStatus.nextLevelBonus! > 0)
        BrnNumberInfoItemModel(
          number: formatNumber(siteStatus.statusMyBonus!),
          lastDesc: '${siteStatus.nextLevelBonus!}',
          title: '魔力值',
          // topWidget: Row(
          //   children: [
          //     Text(
          //       formatNumber(siteStatus.statusMyBonus!),
          //       style: const TextStyle(
          //         color: Colors.red,
          //         fontSize: 13,
          //       ),
          //     ),
          //     Text(
          //       formatNumber(siteStatus.nextLevelBonus!),
          //       style: const TextStyle(
          //         color: Colors.red,
          //         fontSize: 13,
          //       ),
          //     ),
          //   ],
          // ),
          // bottomWidget: const Text(
          //   '魔力值',
          //   style: TextStyle(
          //     color: Colors.red,
          //     fontSize: 12,
          //   ),
          // ),
        ),
      if (siteStatus.nextLevelScore != null && siteStatus.nextLevelScore! > 0)
        BrnNumberInfoItemModel(
          number: formatNumber(siteStatus.statusMyScore!),
          lastDesc: '${siteStatus.nextLevelScore}',
          title: '做种积分',
          // topWidget: Row(
          //   children: [
          //     Text(
          //       formatNumber(siteStatus.statusMyScore!),
          //       style: const TextStyle(
          //         color: Colors.red,
          //         fontSize: 13,
          //       ),
          //     ),
          //     Text(
          //       formatNumber(siteStatus.nextLevelScore!),
          //       style: const TextStyle(
          //         color: Colors.red,
          //         fontSize: 13,
          //       ),
          //     ),
          //   ],
          // ),
          // bottomWidget: const Text(
          //   '做种积分',
          //   style: TextStyle(
          //     color: Colors.red,
          //     fontSize: 12,
          //   ),
          // ),
        ),
    ];
    Logger.instance.w(siteStatus.statusMyLevel);
    Logger.instance.w(siteStatus.statusMyLevel?.length);
    Logger.instance.w(siteStatus.statusMyLevel!.trim().length);
    return GFCard(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8, top: 0),
      boxFit: BoxFit.cover,
      color: Colors.grey.withOpacity(0.5),
      // image: Image.asset('your asset image'),
      title: GFListTile(
        padding: EdgeInsets.zero,
        avatar: GFAvatar(
          backgroundImage:
              NetworkImage(siteStatus.siteLogo as String, headers: {}),
          shape: GFAvatarShape.square,
          backgroundColor: Colors.transparent,
          size: 20,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${siteStatus.mySiteNickname ?? siteStatus.siteName}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
        icon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (siteStatus.statusMail != null && siteStatus.statusMail! > 0)
              GFIconBadge(
                counterChild: GFBadge(
                  shape: GFBadgeShape.square,
                  size: 16,
                  child: Text("${siteStatus.statusMail}"),
                ),
                position: GFBadgePosition.topEnd(top: 5, end: 3),
                child: GFIconButton(
                  onPressed: () {
                    GFToast.showToast('打开邮件链接！', context);
                  },
                  size: GFSize.SMALL,
                  type: GFButtonType.transparent,
                  icon: const Icon(
                    Icons.mail_outline,
                    color: Colors.white70,
                  ),
                ),
              ),
            if (siteStatus.statusMyLevel != null &&
                siteStatus.statusMyLevel!.trim().isNotEmpty)
              GFButton(
                color: Colors.transparent,
                // color: Colors.transparent,
                text: '${siteStatus.statusMyLevel}',
                // shape: GFButtonShape.pills,
                size: 20,
                onPressed: () {
                  if (siteStatus.nextLevelLevel == null) {
                    GFToast.showToast('还没有配置本站点的用户等级信息！', context);
                    return;
                  }
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext dialogContext) {
                      return BrnDialog(
                        divider: const Divider(
                          height: 0,
                          color: Colors.transparent,
                        ),
                        themeData: BrnDialogConfig(
                          dividerPadding: const EdgeInsets.all(0),
                          mainActionBackgroundColor: Colors.teal.shade600,
                          backgroundColor: Colors.teal.shade600,
                          mainActionTextStyle: BrnTextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        contentWidget: GFCard(
                          boxFit: BoxFit.cover,
                          color: Colors.transparent,
                          title: GFListTile(
                            title: Text(
                              '当前等级：${siteStatus.statusMyLevel}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 13,
                              ),
                            ),
                            subTitle: Text(
                              '下一等级：${siteStatus.nextLevelLevel}',
                              style: const TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          content: BrnEnhanceNumberCard(
                            rowCount: 1,
                            padding: const EdgeInsets.all(0),
                            itemChildren: levelInfoList,
                            backgroundColor: Colors.transparent,
                            themeData: BrnEnhanceNumberCardConfig(
                                titleTextStyle: BrnTextStyle(
                                    color: Colors.white, fontSize: 20),
                                descTextStyle: BrnTextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ),
                        ),
                        actionsText: const [
                          '确定',
                        ],
                      );
                    },
                  );
                },
                textStyle: const TextStyle(
                  color: Colors.white60,
                ),
              ),
          ],
        ),
        subTitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (siteStatus.mySiteJoined != null)
              Text(
                calcWeeksDays(siteStatus.mySiteJoined!),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            if (siteStatus.statusInvitation != null &&
                siteStatus.statusInvitation! > 0)
              Row(
                children: [
                  const Icon(
                    Icons.insert_invitation,
                    size: 12,
                    color: Colors.white70,
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Text(
                    '${siteStatus.statusInvitation}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      content: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                        '${filesize(siteStatus.statusUploaded)} (${siteStatus.statusSeed})',
                        style: const TextStyle(
                          fontSize: 12,
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
                        '${filesize(siteStatus.statusDownloaded)} (${siteStatus.statusLeech})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (siteStatus.statusRatio != null)
                    Row(
                      children: [
                        Icon(
                          Icons.ios_share,
                          color: siteStatus.statusRatio! > 1
                              ? Colors.white70
                              : Colors.deepOrange,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          formatNumber(siteStatus.statusRatio!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 5),
                  if (siteStatus.statusSeedVolume != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          filesize(siteStatus.statusSeedVolume),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (siteStatus.statusBonusHour != null)
                    Row(
                      textBaseline: TextBaseline.ideographic,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${formatNumber(siteStatus.statusBonusHour!)}(${siteStatus.statusBonusHour != null && siteStatus.siteSpFull != null && siteStatus.siteSpFull! > 0 ? ((siteStatus.statusBonusHour! / siteStatus.siteSpFull!) * 100).toStringAsFixed(2) : '0'}%)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 5),
                  if (siteStatus.statusMyBonus != null)
                    Row(
                      textBaseline: TextBaseline.ideographic,
                      children: [
                        const Icon(
                          Icons.score,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${formatNumber(siteStatus.statusMyBonus!)}(${formatNumber(siteStatus.statusMyScore!)})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (siteStatus.statusUpdatedAt != null)
                Text(
                  '最近更新：${siteStatus.statusUpdatedAt?.replaceAll('T', ' ')}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10.5,
                  ),
                ),
              if (siteStatus.statusMyHr != null &&
                  siteStatus.statusMyHr != '' &&
                  siteStatus.statusMyHr != "0")
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'HR：${siteStatus.statusMyHr!.replaceAll('区', '')}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
      buttonBar: GFButtonBar(
        children: <Widget>[
          SizedBox(
            width: 68,
            height: 26,
            child: GFButton(
              onPressed: () {
                signIn(siteStatus.mySiteId!).then((res) {
                  Get.back();
                  if (res.code == 0) {
                    Get.snackbar(
                      '签到成功',
                      '${siteStatus.mySiteNickname} 签到信息：${res.msg}',
                      colorText: Colors.white70,
                      backgroundColor: Colors.teal.withOpacity(0.7),
                    );
                  } else {
                    Get.snackbar(
                      '签到失败',
                      '${siteStatus.mySiteNickname!} 签到任务执行出错啦：${res.msg}',
                      colorText: Colors.red,
                      backgroundColor: Colors.teal.withOpacity(0.7),
                    );
                  }
                });
              },
              icon: const Icon(
                Icons.pan_tool_alt,
                size: 12,
                color: Colors.white,
              ),
              text: '签到',
              size: GFSize.SMALL,
              color: Colors.blue,
            ),
          ),
          SizedBox(
            width: 68,
            height: 26,
            child: GFButton(
              onPressed: () {
                getNewestStatus(siteStatus.mySiteId!).then((res) {
                  Get.back();
                  if (res.code == 0) {
                    Get.snackbar(
                      '站点数据刷新成功',
                      '${siteStatus.mySiteNickname} 数据刷新：${res.msg}',
                      colorText: Colors.white70,
                      backgroundColor: Colors.teal.withOpacity(0.7),
                    );
                  } else {
                    Get.snackbar(
                      '站点数据刷新失败',
                      '${siteStatus.mySiteNickname!} 数据刷新出错啦：${res.msg}',
                      colorText: Colors.red,
                      backgroundColor: Colors.teal.withOpacity(0.7),
                    );
                  }
                });
              },
              icon: const Icon(
                Icons.update,
                size: 12,
                color: Colors.white,
              ),
              text: '更新',
              size: GFSize.SMALL,
              color: GFColors.PRIMARY,
            ),
          ),
          SizedBox(
            width: 68,
            height: 26,
            child: GFButton(
              onPressed: () {},
              icon: const Icon(
                Icons.bar_chart,
                size: 12,
                color: Colors.white,
              ),
              text: '历史',
              size: GFSize.SMALL,
              color: Colors.orange,
            ),
          ),
          SizedBox(
            width: 68,
            height: 26,
            child: GFButton(
              onPressed: () {},
              icon: const Icon(
                Icons.edit,
                size: 12,
                color: Colors.white,
              ),
              text: '修改',
              size: GFSize.SMALL,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
