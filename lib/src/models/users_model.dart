class Users {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String plan;
  final DateTime createdDate;

  Users({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.plan,
    required this.createdDate,
  });

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      userId: map['user_id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      plan: map['plan'],
      createdDate: DateTime.parse(map['createdDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'plan': plan,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}
