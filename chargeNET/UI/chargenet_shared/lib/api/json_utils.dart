List<T> parseJsonList<T>(
  dynamic json,
  T Function(Map<String, dynamic> map) fromJson,
) {
  dynamic listSource = json;
  if (json is Map) {
    listSource = json['items'] ?? json['data'] ?? json['results'] ?? const [];
  }

  if (listSource is! List) return [];

  return listSource
      .whereType<Map>()
      .map((e) => fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

Map<String, dynamic> parseJsonMap(dynamic json) {
  if (json is Map<String, dynamic>) return json;
  if (json is Map) return Map<String, dynamic>.from(json);
  return {};
}
