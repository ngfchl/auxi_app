import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

import '../../../../../utils/http.dart';
import '../../../../../utils/logger_helper.dart';
import '../../api.dart';
import '../models/mysite.dart';
import '../models/website.dart';

class SitePage extends StatefulWidget {
  const SitePage({super.key, param});

  @override
  State<SitePage> createState() => _SitePageState();
}

class _SitePageState extends State<SitePage> {
  List<Widget> webSiteList = [];

  @override
  void initState() {
    getMySiteList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Column(
                children: webSiteList,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getWebsiteList() async {
    await getWebsiteListReq()
        .then((res) => {
              if (res['code'] == 0)
                {
                  setState(() => res['data'].forEach((element) {
                        var w = WebSite.fromJson(element);
                        webSiteList.add(
                          GFCard(
                            boxFit: BoxFit.cover,
                            color: Colors.transparent,
                            image: Image.asset('your asset image'),
                            title: GFListTile(
                              avatar: GFAvatar(
                                backgroundImage: NetworkImage(w.logo),
                                shape: GFAvatarShape.standard,
                              ),
                              title: Text(w.name),
                              subTitle: Text(w.nickname),
                            ),
                            content: Text(w.tags),
                            buttonBar: GFButtonBar(
                              children: <Widget>[
                                GFButton(
                                  onPressed: () {},
                                  text: 'Buy',
                                ),
                                GFButton(
                                  onPressed: () {},
                                  text: 'Cancel',
                                ),
                              ],
                            ),
                          ),
                        );
                      }))
                }
              else
                {
                  GFToast.showToast(
                    '获取网站列表失败',
                    context,
                    toastPosition: GFToastPosition.BOTTOM,
                    toastBorderRadius: 5.0,
                    trailing: const Icon(
                      Icons.error,
                      color: GFColors.DANGER,
                    ),
                  ),
                }
            })
        .catchError((error) => {
              print(error),
            });
  }

  void getMySiteList() async {
    getMySiteListReq().then((res) {
      // CommonResponse<List<MySite>> result = CommonResponse.fromJson(
      //     res.data, (p0) => p0.map((item) => MySite.fromJson(item)).toList());
      // result.data;
      if (res.data['code'] == 0) {
        res.data['data'].forEach((element) {
          print(element);
          var w = MySite.fromJson(element);
          setState(() {
            webSiteList.add(
              GFCard(
                boxFit: BoxFit.cover,
                color: Colors.transparent,
                image: Image.asset('your asset image'),
                title: GFListTile(
                  // avatar: GFAvatar(
                  //   backgroundImage: NetworkImage(w.),
                  //   shape: GFAvatarShape.standard,
                  // ),
                  title: Text(w.nickname),
                  subTitle: Text(w.timeJoin.toString()),
                ),
                content: Wrap(
                  children: <Widget>[
                    GFToggle(
                      key: const Key("Free刷流"),
                      enabledText: "Free",
                      disabledText: "Free",
                      onChanged: (val) {},
                      value: w.brushFree,
                      type: GFToggleType.square,
                    ),
                    GFToggle(
                      key: const Key("RSS刷流"),
                      enabledText: "RSS",
                      disabledText: "RSS",
                      onChanged: (val) {},
                      value: w.brushRss,
                      type: GFToggleType.square,
                    ),
                    GFToggle(
                      key: const Key("站点信息"),
                      enabledText: "信息",
                      disabledText: "信息",
                      onChanged: (val) {},
                      value: w.getInfo,
                      type: GFToggleType.square,
                    ),
                    GFToggle(
                      key: const Key("HR识别"),
                      enabledText: "HR",
                      disabledText: "HR",
                      onChanged: (val) {},
                      value: w.hrDiscern,
                      type: GFToggleType.square,
                    ),
                    GFToggle(
                      key: const Key("辅种"),
                      enabledText: "辅种",
                      disabledText: "辅种",
                      onChanged: (val) {},
                      value: w.repeatTorrents,
                      type: GFToggleType.square,
                    ),
                    GFToggle(
                      key: const Key("签到"),
                      enabledText: "签到",
                      disabledText: "签到",
                      onChanged: (val) {},
                      value: w.signIn,
                      type: GFToggleType.square,
                    ),
                    GFToggle(
                      key: const Key("聚合搜索"),
                      enabledText: "搜索",
                      disabledText: "搜索",
                      onChanged: (val) {},
                      value: w.searchTorrents,
                      type: GFToggleType.square,
                    ),
                    // GFToggle(
                    //   key: const Key("拆包"),
                    //   enabledText: "拆包",
                    //   disabledText: "拆包",
                    //   onChanged: (val) {},
                    //   value: w.packageFile,
                    //   type: GFToggleType.square,
                    // ),
                    GFToggle(
                      key: const Key("镜像访问"),
                      enabledText: "镜像",
                      disabledText: "镜像",
                      onChanged: (val) {},
                      value: w.mirrorSwitch,
                      type: GFToggleType.square,
                    ),
                  ],
                ),
                // buttonBar: GFButtonBar(
                //   children: <Widget>[
                // GFButton(
                //   onPressed: () {},
                //   text: 'Buy',
                // ),
                // GFButton(
                //   onPressed: () {},
                //   text: 'Cancel',
                // ),
                // ],
                // ),
              ),
            );
          });
        });
      } else {
        GFToast.showToast(
          '获取网站列表失败',
          context,
          toastPosition: GFToastPosition.BOTTOM,
          toastBorderRadius: 5.0,
          trailing: const Icon(
            Icons.error,
            color: GFColors.DANGER,
          ),
        );
      }
    }).catchError((error, trace) {
      Logger.instance.w(trace);
      return print(error);
    });
  }

  Future getWebsiteListReq() async {
    try {
      return await DioClient().get(Api.WEBSITE_LIST);
    } catch (e, trace) {
      Logger.instance.w(trace);
      return print(e);
    }
  }

  Future getMySiteListReq() async {
    try {
      return await DioClient().get(Api.MYSITE_LIST);
    } catch (e, trace) {
      print(trace);
      return print(e);
    }
  }
}
