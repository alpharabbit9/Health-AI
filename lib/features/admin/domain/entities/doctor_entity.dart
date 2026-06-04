class DoctorEntity {
  final String id;
  final String name;
  final String specialization;
  final String? hospital;
  final String? phone;
  final String? email;
  final String? address;
  final String? availability;
  final DateTime createdAt;

  const DoctorEntity({
    required this.id,
    required this.name,
    required this.specialization,
    this.hospital,
    this.phone,
    this.email,
    this.address,
    this.availability,
    required this.createdAt,
  });

  factory DoctorEntity.fromMap(Map<String, dynamic> m) => DoctorEntity(
        id: m['id'] as String,
        name: m['name'] as String,
        specialization: m['specialization'] as String,
        hospital: m['hospital'] as String?,
        phone: m['phone'] as String?,
        email: m['email'] as String?,
        address: m['address'] as String?,
        availability: m['availability'] as String?,
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'specialization': specialization,
        if (hospital != null) 'hospital': hospital,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
        if (availability != null) 'availability': availability,
      };
}
