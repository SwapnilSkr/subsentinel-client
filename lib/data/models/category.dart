/// Category model matching the backend schema
class Category {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String? logoUrl;
  final bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.logoUrl,
    this.isDefault = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '#808080',
      logoUrl: json['logoUrl'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
      if (logoUrl != null) 'logoUrl': logoUrl,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    String? logoUrl,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      logoUrl: logoUrl ?? this.logoUrl,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
