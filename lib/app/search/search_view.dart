import 'dart:convert';

import 'package:auxi_app/api/downloader.dart';
import 'package:auxi_app/app/home/models/mysite.dart';
import 'package:auxi_app/app/home/models/website.dart';
import 'package:auxi_app/app/search/search_controller.dart';
import 'package:auxi_app/common/glass_widget.dart';
import 'package:auxi_app/models/common_response.dart';
import 'package:auxi_app/models/search_result.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/download.dart';
import '../../utils/logger_helper.dart' as LoggerHelper;

class SearchView extends GetView<SearchPageController> {
  const SearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade300.withOpacity(0.5),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 5),
          child: SearchBar(
            shadowColor:
                const MaterialStatePropertyAll<Color>(Colors.transparent),
            controller: controller.searchController,
            leading: const Icon(
              Icons.search,
              color: Colors.white,
              size: 15,
            ),
            shape: MaterialStatePropertyAll<OutlinedBorder>(
              BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(2),
                side: const BorderSide(
                  style: BorderStyle.none,
                ),
              ),
            ),
            // padding: const MaterialStatePropertyAll<EdgeInsets>(
            //     EdgeInsets.symmetric(horizontal: 16.0)),
            backgroundColor: const MaterialStatePropertyAll<Color>(Colors.teal),
            textStyle: const MaterialStatePropertyAll<TextStyle>(TextStyle(
              fontSize: 14,
              color: Colors.white70,
            )),
            hintText: '点击开始搜索...',
            hintStyle: const MaterialStatePropertyAll<TextStyle>(TextStyle(
              fontSize: 14,
              color: Colors.grey,
            )),
            onChanged: (_) {
              // controller.openView();
            },
            onSubmitted: (query) {
              controller.sendMessage(query);
            },
          ),
        ),
        actions: <Widget>[
          controller.errList.isNotEmpty
              ? GFIconBadge(
                  position: GFBadgePosition.topEnd(top: 8, end: -5),
                  counterChild: GFBadge(
                    child: Text(controller.errList.length.toString()),
                  ),
                  child: GFIconButton(
                    icon: const Icon(
                      Icons.message,
                      color: Colors.white,
                      size: 18,
                    ),
                    type: GFButtonType.transparent,
                    size: GFSize.SMALL,
                    onPressed: () {
                      Get.bottomSheet(
                        Container(
                          color: Colors.teal,
                          child: Column(
                            children: [
                              AppBar(
                                backgroundColor: Colors.teal,
                                shadowColor: Colors.teal,
                                title: const Text(
                                  '搜索结果',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white70,
                                  ),
                                ),
                                leading: GFIconButton(
                                  size: GFSize.MEDIUM,
                                  type: GFButtonType.transparent,
                                  onPressed: () {
                                    Get.back();
                                  },
                                  icon: const Icon(
                                    Icons.cleaning_services_rounded,
                                    color: GFColors.WARNING,
                                  ),
                                ),
                                actions: [
                                  GFIconButton(
                                    size: GFSize.MEDIUM,
                                    type: GFButtonType.transparent,
                                    onPressed: () {
                                      Get.back();
                                    },
                                    icon: const Icon(
                                      Icons.done,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: ListView.builder(
                                    itemCount: controller.errList.length,
                                    itemBuilder: (context, index) {
                                      var item = controller.errList[index];
                                      return GFListTile(
                                          title: Text(
                                            item['msg'],
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          icon: item['code'] == 0
                                              ? const Icon(
                                                  Icons.done,
                                                  size: 14,
                                                  color: GFColors.SUCCESS,
                                                )
                                              : const Icon(
                                                  Icons.dangerous_outlined,
                                                  size: 14,
                                                  color: GFColors.DANGER,
                                                ));
                                    }),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
          Tooltip(
            message: '点击选择站点',
            child: GFIconButton(
              icon: const Icon(
                Icons.settings_input_composite_sharp,
                color: Colors.white,
                size: 15,
              ),
              type: GFButtonType.transparent,
              onPressed: () {
                Get.bottomSheet(
                  Column(
                    children: [
                      AppBar(
                        backgroundColor: Colors.teal,
                        shadowColor: Colors.teal,
                        title: const Text(
                          '选择站点',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                        leading: GFIconButton(
                          size: GFSize.MEDIUM,
                          type: GFButtonType.transparent,
                          onPressed: () {
                            controller.siteList.clear();
                            controller.update();
                            Get.back();
                          },
                          icon: const Icon(
                            Icons.cleaning_services_rounded,
                            color: GFColors.WARNING,
                          ),
                        ),
                        actions: [
                          GFIconButton(
                            size: GFSize.MEDIUM,
                            type: GFButtonType.transparent,
                            onPressed: () {
                              controller.update();
                              Get.back();
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: FutureBuilder(
                            future: controller.getCanSearchWebSite(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                  return Text('none');
                                case ConnectionState.waiting:
                                  return Text('waiting');
                                case ConnectionState.active:
                                  return Text('active');
                                case ConnectionState.done:
                                  LoggerHelper.Logger.instance.w(snapshot.data);
                                  if (snapshot.data.code != 0) {
                                    return Text('Error');
                                  }
                                  List<MySite> mySiteList = snapshot.data.data;
                                  return ListView.builder(
                                      itemCount: mySiteList.length,
                                      itemBuilder: (context, index) {
                                        MySite mySite = mySiteList[index];
                                        WebSite? webSite =
                                            controller.webSiteList[mySite.site];
                                        bool isChecked = controller.siteList
                                            .contains(mySite.id);
                                        return StatefulBuilder(
                                          builder: (context, setInnerState) {
                                            return GFCheckboxListTile(
                                              margin: const EdgeInsets.all(0),
                                              type: GFCheckboxType.square,
                                              title: Text(
                                                mySite.nickname,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              subTitle: Text(
                                                '${webSite!.name} - ${webSite.nickname}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              avatar: GFAvatar(
                                                shape: GFAvatarShape.square,
                                                backgroundImage:
                                                    NetworkImage(webSite.logo),
                                                size: 18,
                                              ),
                                              size: 18,
                                              activeBgColor: Colors.green,
                                              activeIcon: const Icon(
                                                Icons.check,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                              onChanged: (value) {
                                                print(value);
                                                if (value) {
                                                  controller.siteList
                                                      .add(mySite.id);
                                                } else {
                                                  controller.siteList
                                                      .remove(mySite.id);
                                                }
                                                setInnerState(() => isChecked =
                                                    controller.siteList
                                                        .contains(mySite.id));
                                                controller.update();
                                                print(
                                                    controller.siteList.length);
                                              },
                                              value: isChecked,
                                              inactiveIcon: const Icon(
                                                Icons.check_box_outline_blank,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                        );
                                      });
                              }
                            }),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.teal,
                );
              },
            ),
          ),
        ],
      ),
      body: GlassWidget(
        child: Column(
          children: [
            // GFSearchBar(
            //   searchList: controller.searchList,
            //   textColor: Colors.white70,
            //   hideSearchBoxWhenItemSelected: true,
            //   // searchBoxInputDecoration: InputDecoration(
            //   //   icon: Icon(Icons.search),
            //   //   iconColor: Colors.white70,
            //   // ),
            //   circularProgressIndicatorColor: Colors.white70,
            //   searchQueryBuilder: (query, list) {
            //     return list
            //         .where((item) => item!.title!
            //             .toLowerCase()
            //             .contains(query.toLowerCase()))
            //         .toList();
            //   },
            //   overlaySearchListItemBuilder: (SearchResult? item) {
            //     return Container(
            //       color: Colors.teal,
            //       padding: const EdgeInsets.all(8),
            //       child: Text(
            //         item!.title!,
            //         style: const TextStyle(fontSize: 13, color: Colors.white70),
            //       ),
            //     );
            //   },
            //   onItemSelected: (item) {},
            // ),

            controller.searchList.isNotEmpty
                ? Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: GFColors.WARNING,
                          size: 15,
                        ),
                        controller.searchList.isNotEmpty
                            ? Text(
                                '共搜索到种子：${controller.searchList.length}个...',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              )
                            : GFLoader()
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            StreamBuilder(
                stream: controller.streamController.stream,
                initialData: false,
                builder: (context, snapshot) {
                  LoggerHelper.Logger.instance.w(snapshot.connectionState);
                  LoggerHelper.Logger.instance.w(snapshot.data);
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return const SizedBox.shrink();
                    case ConnectionState.waiting:
                      return const SizedBox.shrink();
                    case ConnectionState.active:
                      Map response = json.decode(snapshot.data.toString());
                      if (response['code'] != 0) {
                        controller.errList.add({
                          "code": response['code'],
                          "msg": response['msg'],
                        });
                      } else {
                        controller.searchList.addAll(
                            (response['data']['torrents'] as List)
                                .map((item) => SearchResult.fromJson(item))
                                .toList());
                        controller.errList.add({
                          "code": response['code'],
                          "msg": response['msg'],
                        });
                      }
                      return snapshot.hasData
                          ? Expanded(
                              child: ListView.builder(
                                  itemCount: controller.searchList.length,
                                  itemBuilder: (context, index) {
                                    var item = controller.searchList[index];
                                    return _buildSearchItem(context, item!);
                                  }),
                            )
                          : const GFLoader();
                    case ConnectionState.done:
                      controller.streamController.close();
                      return const SizedBox.shrink();
                  }
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchItem(BuildContext context, SearchResult result) {
    WebSite? webSite = controller.webSiteList[result.siteId];
    return GFCard(
      image: Image(
        image: const NetworkImage(
          'https://i2.hdslb.com/bfs/archive/84ffd8ddd3071bac3849cc4be36660ff95a16632.jpg',
        ),
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width,
      ),
      // imageOverlay: const NetworkImage(
      //   'https://cdn.wallpapersafari.com/90/56/0Yqmps.jpg',
      // ),
      showImage: result.poster!.isNotEmpty,
      // showOverlayImage: false,
      margin: const EdgeInsets.only(left: 8, right: 8, top: 10),
      padding: const EdgeInsets.all(0),
      boxFit: BoxFit.cover,
      color: Colors.transparent,
      title: GFListTile(
          padding: const EdgeInsets.all(0),
          onTap: () async {
            Uri uri = Uri.parse('${webSite.url}details.php?id=${result.tid!}');
            if (!await launchUrl(uri)) {
              Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？');
            }
          },
          icon: GFIconButton(
            icon: const Icon(
              Icons.copy,
              color: Colors.white70,
              size: GFSize.SMALL,
            ),
            tooltip: '点击复制种子链接',
            type: GFButtonType.transparent,
            color: GFColors.SUCCESS,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: result.magnetUrl!));
              Get.snackbar('复制下载链接', '下载链接复制成功！');
            },
          ),
          avatar: GFAvatar(
            backgroundColor: Colors.teal.shade800,
            shape: GFAvatarShape.standard,
            backgroundImage: NetworkImage(webSite!.logo),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: SizedBox(),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: Colors.teal,
                      margin: null,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
                          child: Text(webSite.name.toString(),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  overflow: TextOverflow.ellipsis)),
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
          title: EllipsisText(
            text: result.title!,
            ellipsis: "...",
            maxLines: 1,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white70,
            ),
          ),
          subTitle: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: EllipsisText(
              text: result.subtitle!,
              ellipsis: "...",
              maxLines: 1,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
          ),
          description: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Colors.white70,
                      size: 12,
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      result.published!.toString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.arrow_upward,
                          color: Colors.green,
                          size: 11,
                        ),
                        Text(
                          result.seeders!.toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.arrow_downward,
                          color: Colors.red,
                          size: 11,
                        ),
                        Text(
                          result.leechers!.toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.done,
                          color: Colors.orange,
                          size: 11,
                        ),
                        Text(
                          result.completers!.toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )),
      content: Row(
        children: [
          if (result.category!.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.category,
                      color: Colors.white70,
                      size: 11,
                    ),
                    Text(
                      result.category!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    )
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(
                  Icons.format_size,
                  color: Colors.white70,
                  size: 11,
                ),
                Text(
                  filesize(result.size!),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                )
              ],
            ),
          ),
          if (result.saleStatus!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.sell_outlined,
                    color: Colors.white70,
                    size: 11,
                  ),
                  Text(
                    result.saleStatus!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
            ),
          if (result.saleExpire != null)
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.sell_outlined,
                    color: Colors.white70,
                    size: 11,
                  ),
                  Text(
                    result.saleExpire!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
            ),
          if (!result.hr!)
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.directions_run,
                    color: Colors.white70,
                    size: 11,
                  ),
                  Text(
                    'HR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
      buttonBar: GFButtonBar(runAlignment: WrapAlignment.end, children: [
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
            color: GFColors.PRIMARY,
            size: GFSize.SMALL,
            onPressed: () {
              Get.bottomSheet(
                Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '下载种子到...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: FutureBuilder(
                        future: getDownloaderList(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            List downloaderList = snapshot.data.data;
                            return ListView.builder(
                              itemCount: downloaderList.length,
                              itemBuilder: (context, index) {
                                Downloader downloader = downloaderList[index];
                                return GFListTile(
                                  title: Text(
                                    downloader.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  subTitle: Text(
                                    '${downloader.http}://${downloader.host}:${downloader.port}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  avatar: GFAvatar(
                                    shape: GFAvatarShape.circle,
                                    backgroundImage: AssetImage(
                                        'assets/images/${downloader.category.toLowerCase()}.png'),
                                    size: 16,
                                  ),
                                  icon: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.white70,
                                  ),
                                  onTap: () async {
                                    getDownloaderConnectTest(downloader.id)
                                        .then((res) {
                                      if (res.code != 0) {
                                        Get.snackbar(
                                          '下载器连接测试',
                                          '',
                                          messageText: EllipsisText(
                                            text: res.msg!,
                                            ellipsis: '...',
                                            maxLines: 1,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.red,
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                    });
                                    Get.defaultDialog(
                                      title: '推送到下载器',
                                      titleStyle: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white70,
                                      ),
                                      backgroundColor: Colors.teal,
                                      content: FutureBuilder(
                                        future: getDownloaderCategories(
                                            downloader.id),
                                        builder: (BuildContext context,
                                            AsyncSnapshot snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            List<DownloaderCategory>
                                                categories = snapshot.data.data;
                                            LoggerHelper.Logger.instance
                                                .w(categories);
                                            // if (downloader.category
                                            //         .toLowerCase() ==
                                            //     'qb') {
                                            //   categories.insert(
                                            //       0,
                                            //       DownloaderCategory(
                                            //           name: '',
                                            //           savePath: '未分类'));
                                            // }
                                            return SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.25,
                                              child: ListView.builder(
                                                  itemCount: categories.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    DownloaderCategory
                                                        category =
                                                        categories[index];
                                                    return GFListTile(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      title: Text(
                                                        category.name!,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                      subTitle: Text(
                                                        category.savePath!,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Get.defaultDialog(
                                                          title: '推送种子',
                                                          backgroundColor:
                                                              Colors.teal,
                                                          content: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              EllipsisText(
                                                                text:
                                                                    '${result.title!} ',
                                                                maxLines: 2,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white70,
                                                                ),
                                                                ellipsis: '...',
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              Text(
                                                                '下载器：${downloader.name}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white70,
                                                                ),
                                                              ),
                                                              Text(
                                                                '到分类：${category.name}？',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white70,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          textConfirm: '推送',
                                                          textCancel: '取消',
                                                          onConfirm: () async {
                                                            CommonResponse res =
                                                                await pushTorrentToDownloader(
                                                              site: result
                                                                  .siteId!,
                                                              downloaderId:
                                                                  downloader.id,
                                                              url: result
                                                                  .magnetUrl!,
                                                              category: category
                                                                  .name!,
                                                            );
                                                            LoggerHelper
                                                                .Logger.instance
                                                                .w(res);
                                                            Get.back();
                                                          },
                                                          onCancel: () {
                                                            Get.back();
                                                          },
                                                        );
                                                      },
                                                    );
                                                  }),
                                            );
                                          }
                                          return const GFLoader();
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }
                          return const GFLoader();
                        },
                      ),
                    )
                  ],
                ),
                backgroundColor: Colors.teal,
              );
            },
          ),
        ),
      ]),
    );
  }
}
