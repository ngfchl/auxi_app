import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../models/authinfo.dart';
import '../../models/search_result.dart';
import '../../utils/logger_helper.dart';
import '../../utils/storage.dart';
import '../routes/app_pages.dart';

class SearchPageController extends GetxController {
  String query = '';
  late WebSocketChannel channel;
  final streamController = StreamController<String>();
  List<SearchResult> searchList = [];
  List<String> errList = [];

  @override
  void onInit() {
    query = Get.arguments;
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
        _sendMessage(query);
      }
    } else {
      Get.snackbar('未登录账号', '请先登录再操作！');
      Get.offNamed(Routes.LOGIN);
    }

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    channel.sink.close();
    super.onClose();
  }

  void _sendMessage(String q) {
    if (q.isNotEmpty) {
      print(q);
      channel.sink.add(json.encode({
        "key": q,
        "site_list": [
          7,
          14,
          21,
        ],
      }));
    }
  }
}
