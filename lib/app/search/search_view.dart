import 'dart:convert';

import 'package:auxi_app/app/search/search_controller.dart';
import 'package:auxi_app/common/glass_widget.dart';
import 'package:auxi_app/models/search_result.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/logger_helper.dart';

class SearchView extends GetView<SearchPageController> {
  const SearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.withOpacity(0.5),
      appBar: AppBar(
        title: Text('搜索中...${controller.query}'),
        centerTitle: true,
      ),
      body: GlassWidget(
        child: Column(
          children: [
            StreamBuilder(
              stream: controller.streamController.stream,
              builder: (context, snapshot) {
                Logger.instance.w(snapshot.connectionState);
                Logger.instance.w(snapshot.data);
                if (snapshot.connectionState == ConnectionState.active) {
                  Map response = json.decode(snapshot.data.toString());
                  if (response['code'] != 0) {
                    print(response['msg']);
                    controller.errList.add(response['msg']);
                  } else {
                    print(response['msg']);
                    // {
                    //   "site": site.id,
                    //   "torrents": torrents
                    // }
                    controller.searchList.addAll(
                        (response['data']['torrents'] as List)
                            .map((item) => SearchResult.fromJson(item))
                            .toList());
                    controller.errList.add(response['msg']);
                  }
                }
                return snapshot.hasData
                    ? Expanded(
                        child: ListView.builder(
                            itemCount: controller.searchList.length,
                            itemBuilder: (context, index) {
                              var item = controller.searchList[index];
                              return _buildSearchItem(item);
                            }),
                      )
                    : const Text('正在搜索...');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchItem(SearchResult result) {
    return GFCard(
      margin: const EdgeInsets.all(5),
      boxFit: BoxFit.cover,
      color: Colors.transparent,
      title: GFListTile(
        onTap: () {
          Get.snackbar('打开页面', '正在打开种子页面');
        },
        icon: GFIconButton(
          icon: const Icon(
            Icons.open_in_browser,
            color: Colors.white70,
          ),
          type: GFButtonType.outline,
          color: GFColors.SUCCESS,
          onPressed: () {},
        ),
        avatar: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            GFAvatar(
              shape: GFAvatarShape.standard,
              backgroundImage: AssetImage(result.poster!.isNotEmpty
                  ? 'assets/images/ptools.jpg'
                  : 'assets/images/ptools.jpg'),
            ),
            GFImageOverlay(
              height: 55,
              width: 55,
              image: AssetImage(result.poster!.isNotEmpty
                  ? 'assets/images/ptools.jpg'
                  : 'assets/images/ptools.jpg'),
            ),
            // SizedBox(
            //   height: 35,
            //   child: PhotoView(
            //     customSize: Size.zero,
            //     imageProvider: AssetImage(result.poster!.isNotEmpty
            //         ? 'assets/images/ptools.jpg'
            //         : 'assets/images/ptools.jpg'),
            //   ),
            // ),
            Text(result.siteId!.toString(),
                style: const TextStyle(
                  // fontSize: 20,
                  color: Colors.purple,
                )),
          ],
        ),
        title: EllipsisText(
          text: result.title!,
          ellipsis: "...",
          maxLines: 1,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.deepOrangeAccent,
          ),
        ),
        subTitle: EllipsisText(
          text: result.subtitle!,
          ellipsis: "...",
          maxLines: 1,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      content: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RawChip(
                labelPadding: const EdgeInsets.only(left: 0, right: 5),
                backgroundColor: Colors.lightGreen,
                label: Text(result.category!),
                labelStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
                avatar: const Icon(
                  Icons.category,
                  color: Colors.white70,
                  size: 11,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              RawChip(
                labelPadding: const EdgeInsets.only(left: 0, right: 5),
                backgroundColor: Colors.lightGreen,
                label: Text(filesize(result.size!)),
                avatar: const Icon(
                  Icons.format_size,
                  color: Colors.white70,
                  size: 11,
                ),
                labelStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              RawChip(
                labelPadding: const EdgeInsets.only(left: 0, right: 5),
                backgroundColor: Colors.lightGreen,
                label: Text(result.saleStatus!),
                labelStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
                avatar: const Icon(
                  Icons.sell_outlined,
                  color: Colors.white70,
                  size: 11,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              if (result.hr!)
                RawChip(
                  labelPadding: const EdgeInsets.only(left: 0, right: 5),
                  label: const Text('HR'),
                  backgroundColor: Colors.lightGreen,
                  labelStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                  avatar: const Icon(
                    Icons.directions_run,
                    color: Colors.white70,
                    size: 11,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RawChip(
                labelPadding: const EdgeInsets.only(left: 0, right: 5),
                backgroundColor: Colors.purple,
                label: Text(result.seeders!.toString()),
                labelStyle: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
                avatar: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white70,
                  size: 12,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              RawChip(
                labelPadding: const EdgeInsets.only(left: 0, right: 5),
                backgroundColor: Colors.pinkAccent,
                label: Text(result.leechers!.toString()),
                labelStyle: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
                avatar: const Icon(
                  Icons.arrow_downward,
                  color: Colors.white70,
                  size: 12,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              RawChip(
                labelPadding: const EdgeInsets.only(left: 0, right: 5),
                backgroundColor: Colors.deepOrangeAccent,
                label: Text(result.completers!.toString()),
                labelStyle: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
                avatar: const Icon(
                  Icons.done,
                  color: Colors.white70,
                  size: 12,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              RawChip(
                labelPadding: const EdgeInsets.only(left: 0, right: 5),
                backgroundColor: Colors.amber,
                label: Text(result.published!.toString()),
                labelStyle: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
                avatar: const Icon(
                  Icons.timer_outlined,
                  color: Colors.white70,
                  size: 12,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
            ],
          ),
        ],
      ),
      buttonBar: GFButtonBar(runAlignment: WrapAlignment.end, children: [
        SizedBox(
          width: 68,
          child: GFButton(
            text: '复制链接',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: result.magnetUrl!));
              Get.snackbar('复制下载链接', '下载链接复制成功！');
            },
            color: GFColors.FOCUS,
            size: GFSize.SMALL,
          ),
        ),
        SizedBox(
          width: 68,
          child: GFButton(
            text: '打开网页',
            onPressed: () async {
              Uri uri = Uri.parse(result.magnetUrl!);
              if (!await launchUrl(uri)) {
                throw Exception('Could not launch $uri');
              }
            },
            color: GFColors.ALT,
            size: GFSize.SMALL,
          ),
        ),
        SizedBox(
          width: 68,
          child: GFButton(
            text: '下载种子',
            onPressed: () async {
              Uri uri = Uri.parse(result.magnetUrl!);
              if (!await launchUrl(uri)) {
                Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？');
              }
            },
            color: GFColors.SECONDARY,
            size: GFSize.SMALL,
          ),
        ),
        SizedBox(
          width: 68,
          child: GFButton(
            text: '推送种子',
            onPressed: () {},
            color: GFColors.WARNING,
            size: GFSize.SMALL,
          ),
        ),
      ]),
    );
  }
}
