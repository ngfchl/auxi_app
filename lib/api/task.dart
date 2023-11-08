import '../app/home/models/task.dart';
import '../models/common_response.dart';
import '../utils/http.dart';
import '../utils/logger_helper.dart';
import 'api.dart';

Future<CommonResponse> getScheduleList() async {
  final response = await DioClient().get(Api.TASK_LIST);
  if (response.statusCode == 200) {
    try {
      final dataList = (response.data['data'] as List)
          .map<Schedule>((item) => Schedule.fromJson(item))
          .toList();
      String msg = '共有${dataList.length}个任务';
      Logger.instance.w(msg);
      return CommonResponse(data: dataList, code: 0, msg: msg);
    } catch (e, trace) {
      Logger.instance.w(trace);
      String msg = 'Model解析出错啦！';
      return CommonResponse(data: null, code: -1, msg: msg);
    }
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

Future<CommonResponse> getTaskList() async {
  final response = await DioClient().get(Api.TASK_DESC);
  if (response.statusCode == 200) {
    try {
      Logger.instance.t(response.data);
      Map<String, Task> dataList = (response.data['data'] as List)
          .map<Task>((item) => Task.fromJson(item))
          .toList()
          .asMap()
          .entries
          .fold({}, (result, entry) {
        result[entry.value.task.toString()] = entry.value;
        Logger.instance.w(result);
        return result;
      });
      ;
      String msg = '共有${dataList.length}个任务';
      Logger.instance.w(msg);
      return CommonResponse(data: dataList, code: 0, msg: msg);
    } catch (e, trace) {
      Logger.instance.w(trace);
      String msg = 'Model解析出错啦！';
      return CommonResponse(data: null, code: -1, msg: msg);
    }
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

Future<CommonResponse> getCrontabList() async {
  final response = await DioClient().get(Api.CRONTAB_LIST);
  if (response.statusCode == 200) {
    try {
      Map<int, Crontab> dataList = (response.data['data'] as List)
          .map<Crontab>((item) => Crontab.fromJson(item))
          .toList()
          .asMap()
          .entries
          .fold({}, (result, entry) {
        result[entry.value.id!.toInt()] = entry.value;
        return result;
      });
      String msg = '共有${dataList.length}个Crontab';
      Logger.instance.w(msg);
      return CommonResponse(data: dataList, code: 0, msg: msg);
    } catch (e, trace) {
      Logger.instance.w(trace);
      String msg = 'Model解析出错啦！';
      return CommonResponse(data: null, code: -1, msg: msg);
    }
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}
