import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    super.fullName,
    super.avatarUrl,
    super.totalReservations,
    super.activeReservations,
    super.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['created_at'];
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl:
          json['avatar_url'] as String? ?? json['profile_image'] as String?,
      totalReservations: json['total_reservations'] as int? ?? 0,
      activeReservations: json['active_reservations'] as int? ?? 0,
      createdAt: createdAtValue != null
          ? DateTime.parse(createdAtValue.toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'profile_image': avatarUrl,
      'total_reservations': totalReservations,
      'active_reservations': activeReservations,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
