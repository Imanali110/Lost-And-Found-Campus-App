// lib/models/user_model.dart
// Stores info about a registered student

class UserModel {
  final String uid;
  final String name;
  final String rollNumber;
  final String email;

  UserModel({
    required this.uid,
    required this.name,
    required this.rollNumber,
    required this.email,
  });

  // Save to Firestore
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'rollNumber': rollNumber,
        'email': email,
      };

  // Load from Firestore
  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
        uid: m['uid'] ?? '',
        name: m['name'] ?? '',
        rollNumber: m['rollNumber'] ?? '',
        email: m['email'] ?? '',
      );
}
