class Schedule {
  int? id;
  String? name;
  String? task;
  int? crontab;
  bool? oneOff;
  bool? enabled;
  String? lastRunAt;
  int? totalRunCount;
  String? description;
  String? dateChanged;
  String? args;
  String? kwargs;

  Schedule(
      {this.id,
      this.name,
      this.task,
      this.crontab,
      this.oneOff,
      this.enabled,
      this.lastRunAt,
      this.totalRunCount,
      this.description,
      this.dateChanged,
      this.args,
      this.kwargs});

  Schedule.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    task = json['task'];
    crontab = json['crontab'];
    oneOff = json['one_off'];
    enabled = json['enabled'];
    lastRunAt = json['last_run_at'];
    totalRunCount = json['total_run_count'];
    description = json['description'];
    dateChanged = json['date_changed'];
    args = json['args'];
    kwargs = json['kwargs'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['task'] = task;
    data['crontab'] = crontab;
    data['one_off'] = oneOff;
    data['enabled'] = enabled;
    data['last_run_at'] = lastRunAt;
    data['total_run_count'] = totalRunCount;
    data['description'] = description;
    data['date_changed'] = dateChanged;
    data['args'] = args;
    data['kwargs'] = kwargs;
    return data;
  }
}

class Task {
  String? task;
  String? desc;

  Task({this.task, this.desc});

  Task.fromJson(Map<String, dynamic> json) {
    task = json['task'];
    desc = json['desc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['task'] = task;
    data['desc'] = desc;
    return data;
  }
}

class Crontab {
  int? id;
  String? minute;
  String? hour;
  String? dayOfWeek;
  String? dayOfMonth;
  String? monthOfYear;
  String? express;

  Crontab(
      {this.id,
      this.minute,
      this.hour,
      this.dayOfWeek,
      this.dayOfMonth,
      this.monthOfYear,
      this.express});

  Crontab.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    minute = json['minute'];
    hour = json['hour'];
    dayOfWeek = json['day_of_week'];
    dayOfMonth = json['day_of_month'];
    monthOfYear = json['month_of_year'];
    express = json['express'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['minute'] = minute;
    data['hour'] = hour;
    data['day_of_week'] = dayOfWeek;
    data['day_of_month'] = dayOfMonth;
    data['month_of_year'] = monthOfYear;
    data['express'] = express;
    return data;
  }
}
