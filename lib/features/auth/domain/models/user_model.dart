class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final double walletBalance;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.walletBalance,
    required this.createdAt,
    this.lastLoginAt,
  });

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    double? walletBalance,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      walletBalance: walletBalance ?? this.walletBalance,
      createdAt: this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}