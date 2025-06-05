class ChangePasswordDTO {
  final String email;
  final String code;
  final String newPassword;
  final String confirmNewPassword;

  ChangePasswordDTO({
    required this.email,
    required this.code,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  factory ChangePasswordDTO.fromJson(Map<String, dynamic> json){
    return ChangePasswordDTO(email: json['email'],
        code: json['code'],
        newPassword: json['newPassword'],
        confirmNewPassword: json['confirmNewPassword']
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'code': code,
      'newPassword': newPassword,
      'confirmNewPassword': confirmNewPassword,
    };
  }
}