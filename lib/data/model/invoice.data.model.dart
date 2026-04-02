class BusinessInfoModel {
  final int? id;
  final String businessName;
  final String businessEmail;
  final String businessAddress;
  final String businessNumber;
  final String businessLogo;
  final String tagLine;

  BusinessInfoModel({
    this.id,
    required this.businessName,
    required this.businessEmail,
    required this.businessAddress,
    required this.businessNumber,
    required this.businessLogo,
    required this.tagLine,
  });

  factory BusinessInfoModel.fromJson(Map<String, dynamic> json) {
    return BusinessInfoModel(
      id: json['id'] as int?,
      businessName: json['businessName'] as String,
      businessEmail: json['businessEmail'] as String,
      businessAddress: json['businessAddress'] as String,
      businessNumber: json['businessNumber'] as String,
      businessLogo: json['businessLogo'] as String,
      tagLine: json['thankYouText'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'businessName': businessName,
    'businessEmail': businessEmail,
    'businessAddress': businessAddress,
    'businessNumber': businessNumber,
    'businessLogo': businessLogo,
    'thankYouText': tagLine,
  };
}
