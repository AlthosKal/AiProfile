class UserDetailDTO {
  final String username;
  final String email;
  final String? imageUrl; // <- Nueva propiedad

  UserDetailDTO({required this.username, required this.email, this.imageUrl});

  factory UserDetailDTO.fromJson(Map<String, dynamic> json) {
    return UserDetailDTO(
      username: json['username'],
      email: json['email'],
      imageUrl: json['image']?['imageUrl'], // <- anidado
    );
  }
}
