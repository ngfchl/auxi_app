class CumulativeStats {
  int downloadedBytes;
  int filesAdded;
  int secondsActive;
  int sessionCount;
  int uploadedBytes;

  CumulativeStats({
    required this.downloadedBytes,
    required this.filesAdded,
    required this.secondsActive,
    required this.sessionCount,
    required this.uploadedBytes,
  });

  factory CumulativeStats.fromJson(Map<String, dynamic> json) {
    return CumulativeStats(
      downloadedBytes: json['downloadedBytes'],
      filesAdded: json['filesAdded'],
      secondsActive: json['secondsActive'],
      sessionCount: json['sessionCount'],
      uploadedBytes: json['uploadedBytes'],
    );
  }
}

class CurrentStats {
  int downloadedBytes;
  int filesAdded;
  int secondsActive;
  int sessionCount;
  int uploadedBytes;

  CurrentStats({
    required this.downloadedBytes,
    required this.filesAdded,
    required this.secondsActive,
    required this.sessionCount,
    required this.uploadedBytes,
  });

  factory CurrentStats.fromJson(Map<String, dynamic> json) {
    return CurrentStats(
      downloadedBytes: json['downloadedBytes'],
      filesAdded: json['filesAdded'],
      secondsActive: json['secondsActive'],
      sessionCount: json['sessionCount'],
      uploadedBytes: json['uploadedBytes'],
    );
  }
}

class TransmissionStats {
  int activeTorrentCount;
  CumulativeStats cumulativeStats;
  CurrentStats currentStats;
  int downloadSpeed;
  int pausedTorrentCount;
  int torrentCount;
  int uploadSpeed;

  TransmissionStats({
    required this.activeTorrentCount,
    required this.cumulativeStats,
    required this.currentStats,
    required this.downloadSpeed,
    required this.pausedTorrentCount,
    required this.torrentCount,
    required this.uploadSpeed,
  });

  factory TransmissionStats.fromJson(Map<String, dynamic> json) {
    return TransmissionStats(
      activeTorrentCount: json['activeTorrentCount'],
      cumulativeStats: CumulativeStats.fromJson(json['cumulative-stats']),
      currentStats: CurrentStats.fromJson(json['current-stats']),
      downloadSpeed: json['downloadSpeed'],
      pausedTorrentCount: json['pausedTorrentCount'],
      torrentCount: json['torrentCount'],
      uploadSpeed: json['uploadSpeed'],
    );
  }
}
