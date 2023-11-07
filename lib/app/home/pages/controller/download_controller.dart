import 'package:get/get.dart';
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
    super.onInit();
  }

  getQbSpeed(Downloader downloader) async {
    final qbittorrent = QBittorrentApiV2(
      baseUrl: '${downloader.http}://${downloader.host}:${downloader.port}',
      cookiePath: '.',
      logger: true,
    );
    await qbittorrent.auth.login(
      username: downloader.username!,
      password: downloader.password!,
    );
    TransferInfo res = await qbittorrent.transfer.getGlobalTransferInfo();
    LoggerHelper.Logger.instance.w(res.connectionStatus);

    return res;
  }

  getTrSpeed(Downloader downloader) async {
    final transmission = Transmission(
      '${downloader.http}://${downloader.host}:${downloader.port}',
      AuthKeys(downloader.username!, downloader.password!),
    );
    var res = await transmission.v1.session.sessionStats();
    LoggerHelper.Logger.instance.w(res);
    if (res['result'] == "success") {
      return TransmissionStats.fromJson(res["arguments"]);
    }
    return res;
  }
}
