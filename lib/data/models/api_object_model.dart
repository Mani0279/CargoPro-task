class ApiObject {
  final String? id;
  final String name;
  final Map<String, dynamic>? data;

  ApiObject({
    this.id,
    required this.name,
    this.data,
  });

  factory ApiObject.fromJson(Map<String, dynamic> json) {
    return ApiObject(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
    };

    if (data != null && data!.isNotEmpty) {
      json['data'] = data;
    }

    return json;
  }

  ApiObject copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? data,
  }) {
    return ApiObject(
      id: id ?? this.id,
      name: name ?? this.name,
      data: data ?? this.data,
    );
  }
}