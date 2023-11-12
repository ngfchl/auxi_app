import 'dart:async';
import 'dart:convert';

import 'package:auxi_app/app/home/models/mysite.dart';
import 'package:auxi_app/models/common_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../api/mysite.dart';
import '../../models/authinfo.dart';
import '../../models/search_result.dart';
import '../../utils/logger_helper.dart';
import '../../utils/storage.dart';
import '../home/models/website.dart';
import '../routes/app_pages.dart';

class SearchPageController extends GetxController {
  late WebSocketChannel channel;
  final streamController = StreamController<String>.broadcast();
  TextEditingController searchController = TextEditingController();

  final RxList<SearchResult?> searchList = RxList<SearchResult?>([]);
  final RxList<Map> errList = RxList<Map>([]);
  final RxList<int> siteList = RxList<int>([]);

  Map<int, WebSite> webSiteList = {};
  List<MySite> mySiteList = [];

  @override
  void onInit() {
    getWebSiteListFromServer();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    streamController.close();
    channel.sink.close();
    super.onClose();
  }

  Future<CommonResponse> getCanSearchWebSite() async {
    final result = await getMySiteList();
    Logger.instance.w(result.code);
    Logger.instance.w(result.data[0].searchTorrents);
    return result.code == 0
        ? CommonResponse(
            code: 0,
            data: result.data
                .where((MySite element) =>
                    element.searchTorrents == true &&
                    webSiteList[element.site]!.searchTorrents == true)
                .toList())
        : CommonResponse(code: -1, data: []);
  }

  getWebSiteListFromServer() {
    getWebSiteList().then((value) {
      if (value.code == 0) {
        webSiteList = value.data;
        update();
      } else {
        Get.snackbar(
          'error',
          value.msg!,
          backgroundColor: GFColors.SECONDARY,
        );
      }
    }).catchError((e) {
      Get.snackbar(
        'error',
        e.toString(),
        backgroundColor: GFColors.SECONDARY,
      );
    });
  }

  void sendMessage(String q) {
    searchList.clear();
    errList.clear();
    if (q.isNotEmpty) {
      print(q);
      Map userinfo = SPUtil.getMap('userinfo');
      Logger.instance.w(userinfo);

      if (userinfo.isNotEmpty) {
        AuthInfo authInfo = AuthInfo.fromJson(userinfo as Map<String, dynamic>);
        if (authInfo.authToken != '') {
          var server = SPUtil.getString('server');
          channel = IOWebSocketChannel.connect(
            Uri.parse("${server!.replaceFirst('http', 'ws')}/api/ws/search"),
            headers: {
              'Authorization': authInfo.authToken!,
            },
          );

          // stream = channel.stream.asBroadcastStream();
          channel.stream.listen((res) {
            //event为websocket服务器返回的数据，这是异步数据，需要注意
            print(res);
            streamController.add(res);
          }, onError: (error) {
            print(error);
          }, onDone: () {
            print('已完成！');
          });
          channel.sink.add(json.encode({
            "key": q,
            "site_list": siteList.toSet().toList(),
          }));
        }
      } else {
        Get.snackbar('未登录账号', '请先登录再操作！');
        Get.offNamed(Routes.LOGIN);
      }
    }
  }
}
