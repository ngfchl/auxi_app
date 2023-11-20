import 'package:auxi_app/app/home/models/website.dart';

import '../../utils/http.dart';
import '../app/home/models/mysite.dart';
import '../app/home/models/site_status.dart';
import '../models/common_response.dart';
import '../utils/logger_helper.dart';
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

/// 获取
Future<CommonResponse> getMySiteList() async {
  final response = await DioClient().get(Api.MYSITE_OPERATE_URL);
  if (response.statusCode == 200) {
    final dataList = (response.data['data'] as List)
        .map<MySite>((item) => MySite.fromJson(item))
        .toList();
    String msg = '拥有${dataList.length}个站点';
    print(msg);
    return CommonResponse(data: dataList, code: 0, msg: msg);
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

/// 获取站点信息列表
///
Future<CommonResponse> getWebSiteList() async {
  final response = await DioClient().get(Api.WEBSITE_LIST);
  if (response.statusCode == 200) {
    Map<int, WebSite> dataList = (response.data['data'] as List)
        .map<WebSite>((item) => WebSite.fromJson(item))
        .toList()
        .asMap()
        .entries
        .fold({}, (result, entry) {
      result[entry.value.id] = entry.value;
      return result;
    });
    String msg = '工具共支持${dataList.length}个站点';
    print(msg);
    return CommonResponse(data: dataList, code: 0, msg: msg);
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

/// 签到当前站点
signIn(int mySiteId) async {
  final response = await DioClient().post(
    Api.MYSITE_SIGNIN_OPERATE,
    formData: {
      "site_id": mySiteId,
    },
  );
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '签到失败！: ${response.statusCode}';
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

signInAll() async {
  final response = await DioClient().post(
    Api.MYSITE_SIGNIN_DO_AUTO,
  );
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '签到失败！: ${response.statusCode}';
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

/// 更新当前站点数据
getNewestStatusAll() async {
  final response = await DioClient().post(
    Api.MYSITE_STATUS_ALL,
  );
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '站点刷新数据失败！: ${response.statusCode}';
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

/// 更新当前站点数据
getNewestStatus(int mySiteId) async {
  final response = await DioClient().post(
    Api.MYSITE_STATUS_OPERATE,
    formData: {
      "site_id": mySiteId,
    },
  );
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '站点刷新数据失败！: ${response.statusCode}';
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

/// 获取站点历史数据
getChartData(int mySiteId) async {}

///  修改站点信息
editMySite(int mySiteId) async {}

/// 保存站点信息
saveMySite(int mySiteId) async {}

/// 获取图表接口
Future<CommonResponse> getMySiteChart({
  int siteId = 0,
  int days = 7,
}) async {
  final response = await DioClient().get(
    Api.MYSITE_STATUS_CHART_V2,
    queryParameters: {
      "site_id": siteId,
      "days": days,
    },
  );

  if (response.statusCode == 200) {
    return CommonResponse(data: response.data['data'], code: 0, msg: '');
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

/// 获取图表接口
Future<CommonResponse> getMySiteChartV2({
  int siteId = 0,
  int days = 7,
}) async {
  final response = await DioClient().get(
    Api.MYSITE_STATUS_CHART_V2,
    queryParameters: {
      "site_id": siteId,
      "days": days,
    },
  );

  if (response.statusCode == 200) {
    return CommonResponse(data: response.data['data'], code: 0, msg: '');
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}
