class SignupModel {
  final String name;
  final String email;
  final String password;

  SignupModel({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'full_name': name,
    'email': email,
    'password': password,
  };
}
