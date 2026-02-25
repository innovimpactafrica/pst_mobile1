class GroupMember {
  final String id;
  final String name;
  final String role;
  final String availability;
  final String? email;
  final String? phone;

  GroupMember({
    required this.id,
    required this.name,
    required this.role,
    required this.availability,
    this.email,
    this.phone,
  });

  String get displayInitials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'NA';

    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return parts[0].substring(0, 1).toUpperCase() +
        parts[1].substring(0, 1).toUpperCase();
  }

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'Membre',
      availability: json['availability'] ?? 'Non défini',
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'availability': availability,
      'email': email,
      'phone': phone,
    };
  }

  GroupMember copyWith({
    String? id,
    String? name,
    String? role,
    String? availability,
    String? email,
    String? phone,
  }) {
    return GroupMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      availability: availability ?? this.availability,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
