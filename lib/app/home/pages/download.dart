import 'package:bruno/bruno.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import '../../../api/downloader.dart';
import '../../../common/glass_widget.dart';
import '../../../models/download.dart';
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
  List<Downloader> dataList = [];
  DownloadController controller = Get.put(DownloadController());

  // @override
  // bool get wantKeepAlive => true;

  @override
  void initState() {
    getDownloaderList().then((value) {
      if (value.code == 0) {
        setState(() {
          dataList = value.data;
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

  Widget buildDownloaderCard(Downloader downloader) {
    bool connectState = true;
    getDownloaderConnectTest(downloader.id).then((res) {
      connectState = res.code == 0;
    });
    return GFCard(
      padding: const EdgeInsets.only(left: 0, right: 0, bottom: 15),
      boxFit: BoxFit.cover,
      color: Colors.transparent,
      title: GFListTile(
        padding: const EdgeInsets.all(0),
        avatar: GFAvatar(
          // shape: GFAvatarShape.square,
          backgroundImage: AssetImage(
              'assets/images/${downloader.category.toLowerCase()}.png'),
        ),
        title: Text(
          downloader.name,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 22,
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
            getDownloaderConnectTest(downloader.id).then((res) {
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
        subTitle: Text(
          '${downloader.http}://${downloader.host}:${downloader.port}',
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ),
      content: getSpeedInfo(downloader),
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

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassWidget(
        // child: FutureBuilder(
        //     future: getDownloaderList(),
        //     builder: (BuildContext context, AsyncSnapshot snapshot) {
        //       if (snapshot.connectionState == ConnectionState.done) {
        //         return ListView.builder(
        //             itemCount: dataList.length,
        //             itemBuilder: (BuildContext context, int index) {
        //               Downloader downloader = dataList[index];
        //               return buildDownloaderCard(downloader);
        //             });
        //       }
        //     }),
        child: isLoaded
            ? EasyRefresh(
                controller: EasyRefreshController(),
                onRefresh: () async {
                  // controller.getDownloaderListFromServer();
                  getDownloaderList().then((value) {
                    if (value.code == 0) {
                      dataList = value.data;
                      isLoaded = true;
                    } else {
                      Get.snackbar('', value.msg.toString());
                    }
                  }).catchError((e) {
                    Get.snackbar('', e.toString());
                  });
                  controller.update();
                },
                child: ListView.builder(
                    itemCount: dataList.length,
                    itemBuilder: (BuildContext context, int index) {
                      Downloader downloader = dataList[index];
                      return buildDownloaderCard(downloader);
                    }),
              )
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
            '添加下载器',
            context,
            backgroundColor: GFColors.SECONDARY,
            toastBorderRadius: 5.0,
          );
        },
      ),
    );
  }

  getSpeedInfo(downloader) {
    return FutureBuilder(
        future: downloader.category == 'Qb'
            ? controller.getQbSpeed(downloader)
            : controller.getTrSpeed(downloader),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            LoggerHelper.Logger.instance.w(snapshot.data);
            if (snapshot.data == null) {
              return const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.electrical_services,
                    color: Colors.white70,
                  ),
                  Text(
                    '正在连接...',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      color: Colors.white70,
                    ),
                  ),
                ],
              );
            }
            var res = snapshot.data.data;
            List<BrnNumberInfoItemModel> items = [];
            if (downloader.category == 'Qb') {
              items = [
                BrnNumberInfoItemModel(
                  title: '上传',
                  // topWidget: Row(
                  //   children: [
                  //     Text(
                  //       '${filesize(res.upInfoSpeed!, 0)}/S',
                  //       style: const TextStyle(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.w300,
                  //         color: Colors.white70,
                  //       ),
                  //     ),
                  //     Text(
                  //       filesize(res.upInfoData),
                  //       style: const TextStyle(
                  //         fontWeight: FontWeight.w300,
                  //         color: Colors.white70,
                  //       ),
                  //     )
                  //   ],
                  // ),
                  number: '${filesize(res.upInfoSpeed!.toString(), 0)}/S ',
                  lastDesc: filesize(res.upInfoData),
                ),
                BrnNumberInfoItemModel(
                  title: '下载',
                  number: '${filesize(res.dlInfoSpeed!.toString(), 0)}/S ',
                  lastDesc: filesize(res.dlInfoData),
                ),
                BrnNumberInfoItemModel(
                  title: '上传限速',
                  number: "${filesize(res.upRateLimit!.toString())}/S ",
                ),
                BrnNumberInfoItemModel(
                  title: '下载限速',
                  number: "${filesize(res.dlInfoSpeed!.toString())}/S ",
                ),
              ];
            } else {
              LoggerHelper.Logger.instance.w(res.runtimeType);
              items = [
                BrnNumberInfoItemModel(
                  title: '上传',
                  number: filesize(res.uploadSpeed!.toString()),
                  lastDesc: filesize(res.currentStats.downloadedBytes),
                  // preDesc: '${filesize(res.upRateLimit)}/S',
                ),
                BrnNumberInfoItemModel(
                  title: '下载',
                  number: filesize(res.downloadSpeed!.toString()),
                  lastDesc: filesize(res.currentStats.uploadedBytes),
                  // preDesc: '${filesize(res.dlRateLimit)}/S',
                ),
                BrnNumberInfoItemModel(
                  title: '活动种子',
                  number: res.activeTorrentCount!.toString(),
                  lastDesc: res.torrentCount!.toString(),
                ),
                BrnNumberInfoItemModel(
                  title: '暂停种子',
                  number: res.pausedTorrentCount!.toString(),
                ),
              ];
            }
            return BrnEnhanceNumberCard(
                backgroundColor: Colors.transparent,
                rowCount: 2,
                itemChildren: items,
                themeData: BrnEnhanceNumberCardConfig(
                  descTextStyle: BrnTextStyle(
                    color: Colors.white70,
                  ),
                  titleTextStyle: BrnTextStyle(
                    color: Colors.white70,
                    fontSize: 22,
                  ),
                ));
          }
          return const Text('下载器链接失败！');
        });
  }
}
