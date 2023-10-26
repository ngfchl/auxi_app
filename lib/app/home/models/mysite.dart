class MySite {
  int id;
  int sortId;
  int? site;
  String nickname;
  String? passkey;
  String? rss;
  String? torrents;
  int? downloader;
  int? downloaderId;
  bool signIn;
  bool getInfo;
  bool brushFree;
  bool hrDiscern;
  bool brushRss;
  bool searchTorrents;
  bool repeatTorrents;
  bool packageFile;
  bool mirrorSwitch;
  String? userId;
  int joined;
  String? mirror;
  String? userAgent;
  String? cookie;
  String? customServer;
  String? removeTorrentRules;
  String? timeJoin;

  MySite({
    required this.id,
    required this.sortId,
    this.site,
    required this.nickname,
    this.passkey,
    this.rss,
    this.torrents,
    this.downloader,
    this.downloaderId,
    required this.signIn,
    required this.getInfo,
    required this.brushFree,
    required this.hrDiscern,
    required this.brushRss,
    required this.searchTorrents,
    required this.repeatTorrents,
    required this.packageFile,
    required this.mirrorSwitch,
    this.userId,
    required this.joined,
    this.mirror,
    this.userAgent,
    this.cookie,
    this.customServer,
    this.removeTorrentRules,
    this.timeJoin,
  });

  factory MySite.fromJson(Map<String, dynamic> json) {
    return MySite(
      id: json['id'] as int,
      sortId: json['sort_id'] as int,
      site: json['site'] as int?,
      nickname: json['nickname'] as String,
      passkey: json['passkey'] as String?,
      rss: json['rss'] as String?,
      torrents: json['torrents'] as String?,
      downloader: json['downloader'] as int?,
      downloaderId: json['downloader_id'] as int?,
      signIn: json['sign_in'] as bool,
      getInfo: json['get_info'] as bool,
      brushFree: json['brush_free'] as bool,
      hrDiscern: json['hr_discern'] as bool,
      brushRss: json['brush_rss'] as bool,
      searchTorrents: json['search_torrents'] as bool,
      repeatTorrents: json['repeat_torrents'] as bool,
      packageFile: json['package_file'] as bool,
      mirrorSwitch: json['mirror_switch'] as bool,
      userId: json['user_id'] as String?,
      joined: json['joined'] as int,
      mirror: json['mirror'] as String?,
      userAgent: json['user_agent'] as String?,
      cookie: json['cookie'] as String?,
      customServer: json['custom_server'] as String?,
      removeTorrentRules: json['remove_torrent_rules'] as String?,
      timeJoin: json['time_join'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sort_id': sortId,
      'site': site,
      'nickname': nickname,
      'passkey': passkey,
      'rss': rss,
      'torrents': torrents,
      'downloader': downloader,
      'downloader_id': downloaderId,
      'sign_in': signIn,
      'get_info': getInfo,
      'brush_free': brushFree,
      'hr_discern': hrDiscern,
      'brush_rss': brushRss,
      'search_torrents': searchTorrents,
      'repeat_torrents': repeatTorrents,
      'package_file': packageFile,
      'mirror_switch': mirrorSwitch,
      'user_id': userId,
      'joined': joined,
      'mirror': mirror,
      'user_agent': userAgent,
      'cookie': cookie,
      'custom_server': customServer,
      'remove_torrent_rules': removeTorrentRules,
      'time_join': timeJoin,
    };
  }
}
