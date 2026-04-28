class CustomerModel {
  final String id;
  final String name;
  final String? phoneNumber; // Optional

  CustomerModel({
    required this.id,
    required this.name,
    this.phoneNumber,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone_number': phoneNumber,
    };
  }
}