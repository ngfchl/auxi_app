import 'dart:async';

import 'package:auxi_app/models/common_response.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:transmission_api/transmission_api.dart';

import '../../../../api/downloader.dart';
import '../../../../models/download.dart';
import '../../../../models/transmission.dart';
import '../../../../utils/logger_helper.dart' as LoggerHelper;

class DownloadController extends GetxController {
  bool isLoaded = false;
  List<Downloader> dataList = [];

  @override
  void onInit() {
    getDownloaderListFromServer();
    super.onInit();
  }

  getDownloaderListFromServer() {
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
    update();
  }

  Future<CommonResponse> testConnect(Downloader downloader) async {
    try {
      LoggerHelper.Logger.instance.w(downloader.name);
      if (downloader.category.toLowerCase() == 'qb') {
        final qbittorrent = QBittorrentApiV2(
          baseUrl: '${downloader.http}://${downloader.host}:${downloader.port}',
          cookiePath: (await getApplicationDocumentsDirectory()).path,
          logger: true,
        );
        await qbittorrent.auth.login(
          username: downloader.username!,
          password: downloader.password!,
        );
        return CommonResponse(
            data: null, msg: '${downloader.name} 连接成功!', code: 0);
      } else {
        final transmission = Transmission(
          '${downloader.http}://${downloader.host}:${downloader.port}',
          AuthKeys(downloader.username!, downloader.password!),
        );
        var res = await transmission.v1.session.sessionStats();
        LoggerHelper.Logger.instance.w(res);
        return CommonResponse(
            data: null, msg: '${downloader.name} 连接成功!', code: 0);
      }
    } catch (error) {
      return CommonResponse(
          data: null, msg: '${downloader.name} 连接失败!', code: -1);
    }
  }

  Future getQbSpeed(Downloader downloader) async {
    final qbittorrent = QBittorrentApiV2(
      baseUrl: '${downloader.http}://${downloader.host}:${downloader.port}',
      cookiePath: (await getApplicationDocumentsDirectory()).path,
      logger: true,
    );
    await qbittorrent.auth.login(
      username: downloader.username!,
      password: downloader.password!,
    );
    TransferInfo res = await qbittorrent.transfer.getGlobalTransferInfo();
    LoggerHelper.Logger.instance.w(res.connectionStatus);

    return CommonResponse(data: res);
  }

  Future getTrSpeed(Downloader downloader) async {
    final transmission = Transmission(
      '${downloader.http}://${downloader.host}:${downloader.port}',
      AuthKeys(downloader.username!, downloader.password!),
    );
    var res = await transmission.v1.session.sessionStats();
    LoggerHelper.Logger.instance.w(res);
    if (res['result'] == "success") {
      return CommonResponse(data: TransmissionStats.fromJson(res["arguments"]));
    }
    return CommonResponse(
      code: -1,
      data: res,
      msg: '${downloader.name} 获取实时信息失败！',
    );
  }

  dynamic getIntervalSpeed(Downloader downloader, {int duration = 5}) {
    dynamic speedInfo;
    Timer.periodic(Duration(seconds: duration), (timer) {
      //到时回调
      downloader.category == 'Qb'
          ? getQbSpeed(downloader).then((value) {
              if (value.code == 0) {
                speedInfo = value.data;
              } else {
                speedInfo = null;
              }
            })
          : getTrSpeed(downloader).then((value) {
              if (value.code == 0) {
                speedInfo = value.data;
              } else {
                speedInfo = null;
              }
            });
    });
    LoggerHelper.Logger.instance.w(speedInfo);
    return speedInfo;
  }
}
