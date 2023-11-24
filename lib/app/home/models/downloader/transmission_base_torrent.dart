class TransmissionBaseTorrent {
  int? error;
  String? errorString;
  int? id;
  String? name;
  num? percentDone;
  num? rateDownload;
  num? rateUpload;
  int? status;

  TransmissionBaseTorrent(
      {this.error,
      this.errorString,
      this.id,
      this.name,
      this.percentDone,
      this.rateDownload,
      this.rateUpload,
      this.status});

  TransmissionBaseTorrent.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    errorString = json['errorString'];
    id = json['id'];
    name = json['name'];
    percentDone = json['percentDone'];
    rateDownload = json['rateDownload'];
    rateUpload = json['rateUpload'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    data['errorString'] = errorString;
    data['id'] = id;
    data['name'] = name;
    data['percentDone'] = percentDone;
    data['rateDownload'] = rateDownload;
    data['rateUpload'] = rateUpload;
    data['status'] = status;
    return data;
  }
}
