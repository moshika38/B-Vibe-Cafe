class AuthModel {
  
  final String? id;
  final String userName;
  final String passCode;

  AuthModel({  this.id, required this.userName, required this.passCode});

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
    id: json['id'],
    userName: json['userName'],
    passCode: json['passCode'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'passCode': passCode,
  };
}