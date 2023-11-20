import 'dart:async';

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
    // getDownloaderConnectTest(downloader.id).then((res) {
    //   connectState = res.code == 0;
    // });
    return GFCard(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 5),
      padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10),
      boxFit: BoxFit.cover,
      color: Colors.teal.withOpacity(0.9),
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
      // extendBody: true,
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
                      setState(() {
                        dataList = value.data;
                        isLoaded = true;
                      });
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
                type: GFLoaderType.custom,
                loaderIconOne: Icon(Icons.insert_emoticon),
                loaderIconTwo: Icon(Icons.insert_emoticon),
                loaderIconThree: Icon(Icons.insert_emoticon),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }

  handlerSpeedInfo(downloader) {
    Widget infoCard = const GFLoader();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      //倒计时结束
      LoggerHelper.Logger.instance.w('afterTimer = ${DateTime.now()}');
      infoCard = getSpeedInfo(downloader);
      controller.speedInfo[downloader.id] = infoCard;
      controller.update();
    });
  }

  Widget getSpeedInfo(Downloader downloader) {
    return FutureBuilder(
        future: controller.getIntervalSpeed(downloader),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const GFLoader();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            // LoggerHelper.Logger.instance.w(snapshot.data);
            if (snapshot.data == null) {
              return const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.amber,
                    size: 14,
                  ),
                  SizedBox(width: 3),
                  Text(
                    '出错啦！',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              );
            }
            var res = snapshot.data.data;
            if (downloader.category == 'Qb') {
              return Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Column(
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
                                  '${filesize(res.upInfoSpeed!.toString(), 0)}/S',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.download_outlined,
                                  color: Colors.red,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${filesize(res.dlInfoSpeed!.toString(), 0)}/S',
                                  style: const TextStyle(
                                    fontSize: 13,
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
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
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
                                    fontSize: 13,
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
                            Text(
                              '上传限速：${filesize(res.upRateLimit)}/S',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '下载限速：${filesize(res.dlInfoSpeed)}/S',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              LoggerHelper.Logger.instance.w(res.runtimeType);
              return Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Column(
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
                              '${filesize(res.uploadSpeed!.toString(), 0)}/S',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.download_outlined,
                              color: Colors.red,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${filesize(res.downloadSpeed!.toString(), 0)}/S',
                              style: const TextStyle(
                                fontSize: 13,
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
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                                fontSize: 13,
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
                        Text(
                          '活动种子：${res.activeTorrentCount!}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          '暂停种子：${res.pausedTorrentCount!}',
                          style: const TextStyle(
                            fontSize: 13,
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
          return const GFLoader();
        });
  }
}
