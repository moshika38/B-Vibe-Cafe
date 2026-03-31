class InvoiceDataModel {
  final String businessName;
  final String businessAddress;
  final String businessNumber;
  final String businessLogo;
  final String thankYouText;

  InvoiceDataModel({
    required this.businessName,
    required this.businessAddress,
    required this.businessNumber,
    required this.businessLogo,
    required this.thankYouText,
  });

  factory InvoiceDataModel.fromJson(Map<String, dynamic> json) {
    return InvoiceDataModel(
      businessName: json['businessName'] as String,
      businessAddress: json['businessAddress'] as String,
      businessNumber: json['businessNumber'] as String,
      businessLogo: json['businessLogo'] as String,
      thankYouText: json['thankYouText'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'businessName': businessName,
    'businessAddress': businessAddress,
    'businessNumber': businessNumber,
    'businessLogo': businessLogo,
    'thankYouText': thankYouText,
  };
}
