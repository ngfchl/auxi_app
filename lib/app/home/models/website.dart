class WebSite {
  int id;
  String name;
  String nickname;
  String logo;
  String tracker;
  String tags;
  double spFull;
  String pageMessage;
  String url;
  bool signIn;
  bool getInfo;
  bool brushFree;
  bool hrDiscern;
  bool brushRss;
  bool searchTorrents;
  bool repeatTorrents;

  WebSite({
    required this.id,
    required this.name,
    required this.nickname,
    required this.logo,
    required this.tracker,
    required this.tags,
    required this.spFull,
    required this.pageMessage,
    required this.url,
    required this.signIn,
    required this.getInfo,
    required this.brushFree,
    required this.hrDiscern,
    required this.brushRss,
    required this.searchTorrents,
    required this.repeatTorrents,
  });

  factory WebSite.fromJson(Map<String, dynamic> json) {
    return WebSite(
      id: json['id'] as int,
      name: json['name'] as String,
      nickname: json['nickname'] as String,
      logo: json['logo'] as String,
      tracker: json['tracker'] as String,
      tags: json['tags'] as String,
      spFull: json['sp_full'] as double,
      pageMessage: json['page_message'] as String,
      url: json['url'] as String,
      signIn: json['sign_in'] as bool,
      getInfo: json['get_info'] as bool,
      brushFree: json['brush_free'] as bool,
      hrDiscern: json['hr_discern'] as bool,
      brushRss: json['brush_rss'] as bool,
      searchTorrents: json['search_torrents'] as bool,
      repeatTorrents: json['repeat_torrents'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'logo': logo,
      'tracker': tracker,
      'tags': tags,
      'sp_full': spFull,
      'page_message': pageMessage,
      'url': url,
      'sign_in': signIn,
      'get_info': getInfo,
      'brush_free': brushFree,
      'hr_discern': hrDiscern,
      'brush_rss': brushRss,
      'search_torrents': searchTorrents,
      'repeat_torrents': repeatTorrents,
    };
  }
}
