class Api {
  // 登录接口
  static const String LOGIN_URL = "config/login";

  // 站点列表
  static const String WEBSITE_LIST = "website/website";

  // 我的站点列表
  static const String MYSITE_LIST = "mysite/mysite";

  // 最新状态
  static const String MYSITE_STATUS_LIST = "mysite/status/new";

  // 下载器列表
  static const String DOWNLOADER_LIST = "download/downloaders";

  // 下载器速度列表
  static const String DOWNLOADER_SPEED_URL = "download/downloaders/speed";

  // 下载器分类列表
  static const String DOWNLOADER_CATEGORIES = "download/downloaders/categories";

  //下载器链接测试
  static const String DOWNLOADER_CONNECT_TEST = "download/downloader/test";

  // 推送种子到下载器
  static const String PUSH_TORRENT_URL = "/mysite/push_torrent";

// export const $taskExecute: (task_id: number) => Promise<any> = async (task_id: number) => {
// return await getList<object, Task>('schedule/exec', { task_id })
// }
// export const $scheduleList: () => Promise<any> = async () => {
// return await getList<null, Schedule[]>()
// }
//
// export const $schedule: (params: object) => Promise<any> = async (params: object) => {
// return await getList<object, Schedule>('schedule/schedule', params)
// }
// export const $crontabList: () => Promise<any> = async () => {
// return await getList<null, Crontab[]>('schedule/crontabs')
// }
//
// export const $addSchedule = async (schedule: ScheduleForm) => {
// const { msg, code } = await usePost('schedule/schedule', schedule)
// switch (code) {
// case 0:
// message?.success(msg)
// return true
// default:
// message?.error(msg)
// return false
// }
// }
//
// export const $editSchedule = async (schedule: ScheduleForm) => {
// const { msg, code } = await usePut('schedule/schedule', schedule)
// switch (code) {
// case 0:
// message?.success(msg)
// return true
// default:
// message?.error(msg)
// return false
// }
// }
//
// export const $removeSchedule = async (params: object) => {
// const { msg, code } = await useDelete('schedule/schedule', params)
// switch (code) {
// case 0:
// message?.success(msg)
// return true
// default:
// message?.error(msg)
// return false
// }
// }

  // 任务列表
  static const String TASK_DESC = "schedule/tasks";
  static const String TASK_LIST = "schedule/schedules";
  static const String CRONTAB_LIST = "schedule/crontabs";
  static const String SYSTEM_CONFIG = "config/config";
}
