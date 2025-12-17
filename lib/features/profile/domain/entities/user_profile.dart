import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final int totalReservations;
  final int activeReservations;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.totalReservations = 0,
    this.activeReservations = 0,
    this.createdAt,
  });

  double get completionPercentage {
    // Calculate profile completion based on filled fields
    int filled = 2; // id and email are always filled
    int total = 4; // id, email, fullName, avatarUrl

    if (fullName != null && fullName!.isNotEmpty) filled++;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) filled++;

    return filled / total;
  }

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    avatarUrl,
    totalReservations,
    activeReservations,
    createdAt,
  ];
}
