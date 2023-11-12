import 'dart:convert';

import 'package:auxi_app/app/home/models/mysite.dart';
import 'package:auxi_app/app/home/models/website.dart';
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
          Tooltip(
            message: '点击选择站点',
            child: GFIconButton(
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
                              controller.siteList.clear();
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
                                  Logger.instance.w(snapshot.data);
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
                                        return GFCheckboxListTile(
                                          margin: const EdgeInsets.all(0),
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
                                            shape: GFAvatarShape.standard,
                                            backgroundImage:
                                                NetworkImage(webSite.logo),
                                            size: 18,
                                          ),
                                          size: 18,
                                          activeBgColor: Colors.green,
                                          type: GFCheckboxType.circle,
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
                                            controller.update();
                                            print(controller.siteList.length);
                                          },
                                          value: controller.siteList
                                              .contains(mySite.id),
                                          // inactiveIcon: null,
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
              icon: const Icon(
                Icons.settings_input_composite_sharp,
                color: Colors.white,
                size: 15,
              ),
              type: GFButtonType.transparent,
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
            StreamBuilder(
                stream: controller.streamController.stream,
                initialData: false,
                builder: (context, snapshot) {
                  Logger.instance.w(snapshot.connectionState);
                  Logger.instance.w(snapshot.data);
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return const Center(
                        child: Text(
                          '嗖嗖嗖...',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      );

                    case ConnectionState.waiting:
                      return const Center(
                        child: Text(
                          '正在搜索...',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      );
                    case ConnectionState.active:
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
                      return snapshot.hasData
                          ? Expanded(
                              child: ListView.builder(
                                  itemCount: controller.searchList.length,
                                  itemBuilder: (context, index) {
                                    var item = controller.searchList[index];
                                    return _buildSearchItem(context, item!);
                                  }),
                            )
                          : const Center(
                              child: Text(
                                '正在搜索...',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            );
                    case ConnectionState.done:
                      controller.streamController.close();
                      return Container();
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
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(0),
      boxFit: BoxFit.cover,
      color: Colors.transparent,
      title: GFListTile(
          padding: const EdgeInsets.all(0),
          onTap: () async {
            Uri uri = Uri.parse(result.magnetUrl!);
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
            backgroundColor: Colors.teal.shade900,
            shape: GFAvatarShape.standard,
            backgroundImage: AssetImage(webSite!.logo),
            child: Text(webSite.name.toString(),
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    overflow: TextOverflow.ellipsis)),
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
          if (result.hr!)
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
                      child: ListView(
                        children: [
                          GFListTile(
                            title: const Text(
                              'Dell8999',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            subTitle: const Text(
                              'http://192.168.123.5:8999',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                            avatar: const GFAvatar(
                              shape: GFAvatarShape.circle,
                              backgroundImage:
                                  AssetImage('assets/images/qb.png'),
                              size: 16,
                            ),
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.white70,
                            ),
                            onTap: () {
                              Get.snackbar('', '展开下载器分类');
                            },
                          ),
                        ],
                      ),
                    ),
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
