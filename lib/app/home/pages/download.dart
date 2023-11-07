import 'dart:async';

import 'package:bruno/bruno.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
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
    return GFCard(
      padding: const EdgeInsets.only(left: 0, right: 0, bottom: 15),
      boxFit: BoxFit.cover,
      title: GFListTile(
        padding: const EdgeInsets.all(0),
        avatar: GFAvatar(
          // shape: GFAvatarShape.square,
          backgroundImage: AssetImage(
              'assets/images/${downloader.category.toLowerCase()}.png'),
        ),
        title: Text(downloader.name),
        subTitle:
        Text('${downloader.http}://${downloader.host}:${downloader.port}'),
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
            ? ListView.builder(
            itemCount: dataList.length,
            itemBuilder: (BuildContext context, int index) {
              Downloader downloader = dataList[index];
              return buildDownloaderCard(downloader);
            })
            : const GFLoader(
          type: GFLoaderType.circle,
        ),
      ),
      floatingActionButton: GFIconButton(
        icon: const Icon(Icons.add),
        shape: GFIconButtonShape.circle,
        color: GFColors.SECONDARY,
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

  getIntervalSpeed(Downloader downloader, int duration) async {
    Duration period = Duration(seconds: duration);
    int count = 0;

    Timer.periodic(period, (timer) async {
      //到时回调
      LoggerHelper.Logger.instance.w('afterTimer =  ${DateTime.now()}');
      count++;
      if (count >= 5) {
        timer.cancel();
      }
    });
  }

  getSpeedInfo(downloader) {
    return FutureBuilder(
        future: downloader.category == 'Qb'
            ? controller.getQbSpeed(downloader)
            : controller.getTrSpeed(downloader),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            LoggerHelper.Logger.instance.w(snapshot.data);
            var res = snapshot.data;
            if (res == null) {
              return const Text('当前下载器链接失败！');
            }
            List<BrnNumberInfoItemModel> items = [];
            if (downloader.category == 'Qb') {
              items = [
                BrnNumberInfoItemModel(
                  title: '上传',
                  number: filesize(res.upInfoSpeed!.toString(), 0),
                  lastDesc: filesize(res.upInfoData),
                ),
                BrnNumberInfoItemModel(
                  title: '下载',
                  number: filesize(res.dlInfoSpeed!.toString(), 0),
                  lastDesc: filesize(res.dlInfoData),
                ),
                BrnNumberInfoItemModel(
                  title: '上传限速',
                  number: "${filesize(res.upRateLimit!.toString())}/S",
                ),
                BrnNumberInfoItemModel(
                  title: '下载限速',
                  number: "${filesize(res.dlInfoSpeed!.toString())}/S",
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
              ];
            }
            return BrnEnhanceNumberCard(
              rowCount: 2,
              itemChildren: items,
            );
          }
          return const Text('下载器链接失败！');
        });
  }

}
