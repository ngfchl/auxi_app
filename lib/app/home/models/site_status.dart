class SiteStatus {
  String? siteName;
  String? siteUrl;
  String? siteLogo;
  bool? supportSignIn;
  bool? siteGetInf;
  double? siteSpFull;
  String? sitePageMessage;
  int? mySiteId;
  int? mySiteSortId;
  String? mySiteNickname;
  bool? mySiteGetInfo;
  bool? mySiteSignIn;
  String? mySiteJoined;
  int? statusSeed;
  int? statusUploaded;
  int? statusMail;
  String? statusMyHr;
  int? statusSeedVolume;
  double? statusMyBonus;
  int? statusDownloaded;
  double? statusBonusHour;
  int? statusInvitation;
  double? statusMyScore;
  int? statusLeech;
  String? statusMyLevel;
  double? statusRatio;
  String? statusUpdatedAt;
  bool? signSignInToday;
  String? levelLevel;
  String? levelRights;
  String? nextLevelLevel;
  String? nextLevelDownloaded;
  int? nextLevelTorrents;
  String? nextLevelUploaded;
  String? nextLevelRights;
  double? nextLevelScore;
  double? nextLevelBonus;
  double? nextLevelRatio;

  SiteStatus(
      {this.siteName,
      this.siteUrl,
      this.siteLogo,
      this.supportSignIn,
      this.siteGetInf,
      this.siteSpFull,
      this.sitePageMessage,
      this.mySiteId,
      this.mySiteSortId,
      this.mySiteNickname,
      this.mySiteGetInfo,
      this.mySiteSignIn,
      this.mySiteJoined,
      this.statusSeed,
      this.statusUploaded,
      this.statusMail,
      this.statusMyHr,
      this.statusSeedVolume,
      this.statusMyBonus,
      this.statusDownloaded,
      this.statusBonusHour,
      this.statusInvitation,
      this.statusMyScore,
      this.statusLeech,
      this.statusMyLevel,
      this.statusRatio,
      this.signSignInToday,
      this.levelLevel,
      this.levelRights,
      this.nextLevelLevel,
      this.nextLevelDownloaded,
      this.nextLevelTorrents,
      this.nextLevelUploaded,
      this.nextLevelRights,
      this.nextLevelScore,
      this.nextLevelBonus,
      this.nextLevelRatio});

  SiteStatus.fromJson(Map<String, dynamic> json) {
    siteName = json['site_name'];
    siteUrl = json['site_url'];
    siteLogo = json['site_logo'];
    supportSignIn = json['support_sign_in'];
    siteGetInf = json['site_get_inf'];
    siteSpFull = json['site_sp_full'];
    sitePageMessage = json['site_page_message'];
    mySiteId = json['my_site_id'];
    mySiteSortId = json['my_site_sort_id'];
    mySiteNickname = json['my_site_nickname'];
    mySiteGetInfo = json['my_site_get_info'];
    mySiteSignIn = json['my_site_sign_in'];
    mySiteJoined = json['my_site_joined'];
    statusSeed = json['status_seed'];
    statusUploaded = json['status_uploaded'];
    statusMail = json['status_mail'];
    statusMyHr = json['status_my_hr'];
    statusSeedVolume = json['status_seed_volume'];
    statusMyBonus = json['status_my_bonus'];
    statusDownloaded = json['status_downloaded'];
    statusBonusHour = json['status_bonus_hour'];
    statusInvitation = json['status_invitation'];
    statusMyScore = json['status_my_score'];
    statusLeech = json['status_leech'];
    statusMyLevel = json['status_my_level'];
    statusRatio = json['status_ratio'];
    statusUpdatedAt = json['status_updated_at'];
    signSignInToday = json['sign_sign_in_today'];
    levelLevel = json['level_level'];
    levelRights = json['level_rights'];
    nextLevelLevel = json['next_level_level'];
    nextLevelDownloaded = json['next_level_downloaded'];
    nextLevelTorrents = json['next_level_torrents'];
    nextLevelUploaded = json['next_level_uploaded'];
    nextLevelRights = json['next_level_rights'];
    nextLevelScore = json['next_level_score'];
    nextLevelBonus = json['next_level_bonus'];
    nextLevelRatio = json['next_level_ratio'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['site_name'] = siteName;
    data['site_url'] = siteUrl;
    data['site_logo'] = siteLogo;
    data['support_sign_in'] = supportSignIn;
    data['site_get_inf'] = siteGetInf;
    data['site_sp_full'] = siteSpFull;
    data['site_page_message'] = sitePageMessage;
    data['my_site_id'] = mySiteId;
    data['my_site_sort_id'] = mySiteSortId;
    data['my_site_nickname'] = mySiteNickname;
    data['my_site_get_info'] = mySiteGetInfo;
    data['my_site_sign_in'] = mySiteSignIn;
    data['my_site_joined'] = mySiteJoined;
    data['status_seed'] = statusSeed;
    data['status_uploaded'] = statusUploaded;
    data['status_mail'] = statusMail;
    data['status_my_hr'] = statusMyHr;
    data['status_seed_volume'] = statusSeedVolume;
    data['status_my_bonus'] = statusMyBonus;
    data['status_downloaded'] = statusDownloaded;
    data['status_bonus_hour'] = statusBonusHour;
    data['status_invitation'] = statusInvitation;
    data['status_my_score'] = statusMyScore;
    data['status_leech'] = statusLeech;
    data['status_my_level'] = statusMyLevel;
    data['status_ratio'] = statusRatio;
    data['status_updated_at'] = statusUpdatedAt;
    data['sign_sign_in_today'] = signSignInToday;
    data['level_level'] = levelLevel;
    data['level_rights'] = levelRights;
    data['next_level_level'] = nextLevelLevel;
    data['next_level_downloaded'] = nextLevelDownloaded;
    data['next_level_torrents'] = nextLevelTorrents;
    data['next_level_uploaded'] = nextLevelUploaded;
    data['next_level_rights'] = nextLevelRights;
    data['next_level_score'] = nextLevelScore;
    data['next_level_bonus'] = nextLevelBonus;
    data['next_level_ratio'] = nextLevelRatio;
    return data;
  }
}
