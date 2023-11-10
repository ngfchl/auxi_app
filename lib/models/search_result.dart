class SearchResult {
  int? siteId;
  String? tid;
  String? poster;
  String? category;
  String? magnetUrl;
  String? title;
  String? subtitle;
  String? saleStatus;
  String? saleExpire;
  bool? hr;
  String? published;
  int? size;
  int? seeders;
  int? leechers;
  int? completers;

  SearchResult(
      {this.siteId,
      this.tid,
      this.poster,
      this.category,
      this.magnetUrl,
      this.title,
      this.subtitle,
      this.saleStatus,
      this.saleExpire,
      this.hr,
      this.published,
      this.size,
      this.seeders,
      this.leechers,
      this.completers});

  SearchResult.fromJson(Map<String, dynamic> json) {
    siteId = json['site_id'];
    tid = json['tid'];
    poster = json['poster'];
    category = json['category'];
    magnetUrl = json['magnet_url'];
    title = json['title'];
    subtitle = json['subtitle'];
    saleStatus = json['sale_status'];
    saleExpire = json['sale_expire'];
    hr = json['hr'];
    published = json['published'];
    size = json['size'];
    seeders = json['seeders'];
    leechers = json['leechers'];
    completers = json['completers'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['site_id'] = siteId;
    data['tid'] = tid;
    data['poster'] = poster;
    data['category'] = category;
    data['magnet_url'] = magnetUrl;
    data['title'] = title;
    data['subtitle'] = subtitle;
    data['sale_status'] = saleStatus;
    data['sale_expire'] = saleExpire;
    data['hr'] = hr;
    data['published'] = published;
    data['size'] = size;
    data['seeders'] = seeders;
    data['leechers'] = leechers;
    data['completers'] = completers;
    return data;
  }
}
