import '../../utils/http.dart';
import '../app/home/models/site_status.dart';
import '../models/CommonResponse.dart';
import 'api.dart';

Future<CommonResponse> getSiteStatusList() async {
  final response = await DioClient().get(Api.MYSITE_STATUS_LIST);
  if (response.statusCode == 200) {
    final siteStatusList = (response.data['data'] as List)
        .map<SiteStatus>((item) => SiteStatus.fromJson(item))
        .toList();
    String msg = '共有${siteStatusList.length}个站点';
    print(msg);
    return CommonResponse(data: siteStatusList, code: 0, msg: msg);
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

/// 获取站点信息列表
///
getWebSiteList() async {}

/// 签到当前站点
signIn(int mySiteId) async {}

/// 更新当前站点数据
getNewestStatus(int mySiteId) async {}

/// 获取站点历史数据
getChartData(int mySiteId) async {}

///  修改站点信息
editMySite(int mySiteId) async {}

/// 保存站点信息
saveMySite(int mySiteId) async {}
