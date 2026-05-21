class ContactModel {
  final String? id;
  final int? userId;
  final int priority;
  final String contactName;
  final String? relationship;
  final String? phone;
  final String? whatsapp;

  ContactModel({
    this.id,
    this.userId,
    required this.priority,
    required this.contactName,
    this.relationship,
    this.phone,
    this.whatsapp,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id']?.toString(),
      userId: json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null,
      priority: json['priority'] ?? 1,
      contactName: json['contact_name'] ?? '',
      relationship: json['relationship'],
      phone: json['phone'],
      whatsapp: json['whatsapp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'priority': priority,
      'contact_name': contactName,
      'relationship': relationship,
      'phone': phone,
      'whatsapp': whatsapp,
    };
  }

  ContactModel copyWith({
    String? id,
    int? userId,
    int? priority,
    String? contactName,
    String? relationship,
    String? phone,
    String? whatsapp,
  }) {
    return ContactModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      priority: priority ?? this.priority,
      contactName: contactName ?? this.contactName,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
    );
  }
}
