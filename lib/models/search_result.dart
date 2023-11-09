class SearchResult {
  int? site;
  int? tid;
  String? category;
  String? magnetUrl;
  String? detailUrl;
  String? posterUrl;
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
  String? siteName;
  String? siteLogo;

  SearchResult(
      {this.site,
      this.tid,
      this.category,
      this.magnetUrl,
      this.detailUrl,
      this.posterUrl,
      this.title,
      this.subtitle,
      this.saleStatus,
      this.saleExpire,
      this.hr,
      this.published,
      this.size,
      this.seeders,
      this.leechers,
      this.completers,
      this.siteName,
      this.siteLogo});

  SearchResult.fromJson(Map<String, dynamic> json) {
    site = json['site'];
    tid = json['tid'];
    category = json['category'];
    magnetUrl = json['magnet_url'];
    detailUrl = json['detail_url'];
    posterUrl = json['poster_url'];
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
    siteName = json['siteName'];
    siteLogo = json['siteLogo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['site'] = site;
    data['tid'] = tid;
    data['category'] = category;
    data['magnet_url'] = magnetUrl;
    data['detail_url'] = detailUrl;
    data['poster_url'] = posterUrl;
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
    data['siteName'] = siteName;
    data['siteLogo'] = siteLogo;
    return data;
  }
}
