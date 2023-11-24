import 'dart:async';

import 'package:get/get.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:transmission_api/transmission_api.dart';

import '../../../../utils/logger_helper.dart' as LoggerHelper;
import '../../models/download.dart';
import '../home/models/downloader/transmission_base_torrent.dart';
import '../home/pages/controller/download_controller.dart';

class TorrentController extends GetxController {
  DownloadController downloadController = Get.find();

  late Downloader downloader;
  final torrents = [].obs;
  late Timer periodicTimer;
  RxBool isTimerActive = true.obs; // 使用 RxBool 控制定时器是否激活

  @override
  void onInit() {
    downloader = Get.arguments;
    getAllTorrents();
    startPeriodicTimer();
    Timer(const Duration(minutes: 5), () {
      // 定时器触发后执行的操作，这里可以取消periodicTimer、关闭资源等
      periodicTimer.cancel();
      // 你可以在这里添加其他需要在定时器触发后执行的逻辑
    });

    super.onInit();
  }

  void startPeriodicTimer() {
    // 设置定时器，每隔一定时间刷新下载器数据
    periodicTimer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      // 在定时器触发时获取最新的下载器数据
      getAllTorrents();
    });
    isTimerActive.value = true;
  }

  void cancelPeriodicTimer() {
    if (periodicTimer.isActive) {
      periodicTimer.cancel();
    }
    isTimerActive.value = false;
    // update();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    periodicTimer.cancel();
    super.onClose();
  }

  Future<void> getAllTorrents() async {
    if (downloader.category.toLowerCase() == 'qb') {
      QBittorrentApiV2 qbittorrent =
          await downloadController.getQbInstance(downloader);
      torrents.value = await qbittorrent.torrents
          .getTorrentsList(options: const TorrentListOptions());
      LoggerHelper.Logger.instance.w(torrents.length);
    } else {
      Transmission transmission = downloadController.getTrInstance(downloader);
      Map res = await transmission.v1.torrent
          .torrentGet(fields: TorrentFields.basic());

      LoggerHelper.Logger.instance.w(res['arguments']["torrents"].length);
      if (res['result'] == "success") {
        torrents.value = res['arguments']["torrents"]
            .map<TransmissionBaseTorrent>(
                (item) => TransmissionBaseTorrent.fromJson(item))
            .toList();
      }
    }
    update();
  }
}
