class Search {
  final int id;
  final String name;
  final int? partnerId;
  final int? userId;
  final String? image;
final String? email;
final String? phone;
  Search({
    required this.id,
    required this.name,
    this.partnerId,
    this.userId, this.image, this.email, this.phone,
  });




  factory Search.fromMap(Map<String, dynamic> map) {
    return Search(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      partnerId: map['partner_id'] as int?,
      userId: map['user_id'] as int?,
      image: map['image_url'] as String?,
      email : map['email'] as String?,
      phone: map['phone'] == false ? null : map['phone'] as String?,


    );
  }



}
