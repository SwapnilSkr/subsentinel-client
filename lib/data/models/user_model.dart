class AppUser {
  final String id;
  final String? phone;
  final String? googleId;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  AppUser({
    required this.id,
    this.phone,
    this.googleId,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] ?? '',
      phone: json['phone'],
      googleId: json['googleId'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'phone': phone,
      'googleId': googleId,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }
}
