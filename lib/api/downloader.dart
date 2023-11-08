import '../models/common_response.dart';
import '../models/download.dart';
import '../utils/http.dart';
import 'api.dart';

///获取下载器列表
///
Future<CommonResponse> getDownloaderList() async {
  final response = await DioClient().get(Api.DOWNLOADER_LIST);
  if (response.statusCode == 200) {
    final dataList = (response.data['data'] as List)
        .map<Downloader>((item) => Downloader.fromJson(item))
        .toList();
    String msg = '共有${dataList.length}个下载器';
    print(msg);
    return CommonResponse(data: dataList, code: 0, msg: msg);
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}
