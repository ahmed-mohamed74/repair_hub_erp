class DeviceModel {
  final String id;
  final String customerId;
  final String brandName;
  final String modelName;
  final String imei;

  DeviceModel({
    required this.id,
    required this.customerId,
    required this.brandName,
    required this.modelName,
    required this.imei,
  });

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      id: map['id'] as String,
      customerId: map['customer_id'] as String,
      brandName: map['brand_name'] as String,
      modelName: map['model_name'] as String,
      imei: map['imei'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'brand_name': brandName,
      'model_name': modelName,
      'imei': imei,
    };
  }
}