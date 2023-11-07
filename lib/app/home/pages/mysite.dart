import 'package:auxi_app/common/glass_widget.dart';
import 'package:bruno/bruno.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:proper_filesize/proper_filesize.dart';

import '../../../../../utils/calc_weeks.dart';
import '../../../../../utils/format_number.dart';
import '../../../api/mysite.dart';
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassWidget(
        child: isLoaded
            ? ListView.builder(
                itemCount: statusList.length,
                itemBuilder: (BuildContext context, int index) {
                  SiteStatus siteStatus = statusList[index];
                  return showSiteDataInfo(siteStatus);
                })
            : const GFLoader(
                type: GFLoaderType.circle,
              ),
      ),
      floatingActionButton: GFIconButton(
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
    );
  }

  Widget showSiteDataInfo(SiteStatus siteStatus) {
    List<BrnNumberInfoItemModel> dataList = [
      if (siteStatus.statusUploaded != null)
        BrnNumberInfoItemModel(
          title: '上传',
          number: filesize(siteStatus.statusUploaded),
        ),
      if (siteStatus.statusDownloaded != null)
        BrnNumberInfoItemModel(
          title: '下载',
          number: filesize(siteStatus.statusDownloaded),
        ),
      if (siteStatus.statusMyScore != null)
        BrnNumberInfoItemModel(
          title: '积分',
          number: formatNumber(siteStatus.statusMyScore!),
        ),
      if (siteStatus.statusSeed != null)
        BrnNumberInfoItemModel(
          title: '做种',
          number: '${siteStatus.statusSeed}',
        ),
      if (siteStatus.statusLeech != null)
        BrnNumberInfoItemModel(
          title: '吸血',
          number: '${siteStatus.statusLeech}',
        ),
      if (siteStatus.statusMyBonus != null)
        BrnNumberInfoItemModel(
          title: '魔力',
          number: formatNumber(siteStatus.statusMyBonus!),
        ),
      if (siteStatus.statusBonusHour != null)
        BrnNumberInfoItemModel(
          title: '时魔',
          numberInfoIcon: BrnNumberInfoIcon.arrow,
          number: formatNumber(siteStatus.statusBonusHour!),
        ),
      if (siteStatus.statusBonusHour != null &&
          siteStatus.siteSpFull != null &&
          siteStatus.siteSpFull! > 0)
        BrnNumberInfoItemModel(
          title: '满魔',
          number: ((siteStatus.statusBonusHour! / siteStatus.siteSpFull!) * 100)
              .toStringAsFixed(2),
          lastDesc: '%',
        ),
      if (siteStatus.statusMyHr != null &&
          siteStatus.statusMyHr != '' &&
          siteStatus.statusMyHr != "0")
        BrnNumberInfoItemModel(
          topWidget: Text(
            '${siteStatus.statusMyHr}',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 10,
            ),
          ),
          bottomWidget: const Text(
            'H&R',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 11,
            ),
          ),
        ),
    ];
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
    return GFCard(
      boxFit: BoxFit.cover,
      color: Colors.teal[300],
      // image: Image.asset('your asset image'),
      title: GFListTile(
        padding: const EdgeInsets.all(0.0),
        avatar: GFAvatar(
          backgroundImage:
              NetworkImage(siteStatus.siteLogo as String, headers: {
            //todo
          }),
          shape: GFAvatarShape.standard,
          size: GFSize.LARGE,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${siteStatus.mySiteNickname ?? siteStatus.siteName}',
              style: const TextStyle(
                color: Colors.tealAccent,
                fontSize: 18,
              ),
            ),
            if (siteStatus.statusMail != null && siteStatus.statusMail! > 0)
              GFIconBadge(
                counterChild: GFBadge(
                  shape: GFBadgeShape.circle,
                  size: 22,
                  child: Text("${siteStatus.statusMail}"),
                ),
                position: GFBadgePosition.topStart(top: 8, start: 24),
                child: GFIconButton(
                  onPressed: () {
                    GFToast.showToast('打开邮件链接！', context);
                  },
                  icon: const Icon(
                    Icons.mail_outline,
                    color: Colors.tealAccent,
                    size: 16,
                  ),
                  type: GFButtonType.transparent,
                  color: Colors.transparent,
                ),
              ),
            if (siteStatus.statusMyLevel != null)
              GFButton(
                color: siteStatus.levelLevel == null
                    ? Colors.teal.shade400
                    : Colors.teal.shade500,
                // color: Colors.transparent,
                text: '${siteStatus.statusMyLevel}',
                // shape: GFButtonShape.pills,
                onPressed: siteStatus.levelLevel == null
                    ? null
                    : () {
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
                size: GFSize.SMALL,
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
          BrnEnhanceNumberCard(
            rowCount: 3,
            itemChildren: dataList,
            runningSpace: 0,
            itemRunningSpace: 0,
            padding: const EdgeInsets.all(0),
            backgroundColor: Colors.transparent,
            themeData: BrnEnhanceNumberCardConfig(
              runningSpace: 0,
              itemRunningSpace: 0,
              titleTextStyle: BrnTextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              descTextStyle: BrnTextStyle(
                color: Colors.teal.shade800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (siteStatus.statusUpdatedAt != null)
                Text(
                  '最近更新时间：${siteStatus.statusUpdatedAt?.replaceAll('T', ' ')}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
      buttonBar: GFButtonBar(
        children: <Widget>[
          SizedBox(
            width: 70,
            child: GFButton(
              onPressed: () {},
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
            width: 70,
            child: GFButton(
              onPressed: () {},
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
            width: 70,
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
            width: 70,
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
