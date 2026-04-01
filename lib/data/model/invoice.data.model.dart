class BusinessInfoModel {
  final int? id;
  final String businessName;
  final String businessAddress;
  final String businessNumber;
  final String businessLogo;
  final String thankYouText;

  BusinessInfoModel({
    this.id,
    required this.businessName,
    required this.businessAddress,
    required this.businessNumber,
    required this.businessLogo,
    required this.thankYouText,
  });

  factory BusinessInfoModel.fromJson(Map<String, dynamic> json) {
    return BusinessInfoModel(
      id: json['id'] as int?,
      businessName: json['businessName'] as String,
      businessAddress: json['businessAddress'] as String,
      businessNumber: json['businessNumber'] as String,
      businessLogo: json['businessLogo'] as String,
      thankYouText: json['thankYouText'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'businessName': businessName,
    'businessAddress': businessAddress,
    'businessNumber': businessNumber,
    'businessLogo': businessLogo,
    'thankYouText': thankYouText,
  };
}
