class UserDTO {
  final String username;
  final String email;
  final String name;
  final String groupName;

  UserDTO({
    required this.username,
    required this.email,
    required this.name,
    required this.groupName,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      username: json['userName'],
      email: json['email'],
      name: json['name'],
      groupName: json['groupName'],
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDTO &&
          runtimeType == other.runtimeType &&
          username == other.username;

  @override
  int get hashCode => username.hashCode;
}
