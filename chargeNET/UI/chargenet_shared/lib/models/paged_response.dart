/// Generic list wrapper if the API returns paginated results.
class PagedResponse<T> {
  const PagedResponse({
    required this.items,
    this.totalCount,
    this.page,
    this.pageSize,
  });

  final List<T> items;
  final int? totalCount;
  final int? page;
  final int? pageSize;

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    final rawItems = json['items'] ?? json['data'] ?? json['results'];
    final items = <T>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          items.add(itemParser(item));
        }
      }
    }

    return PagedResponse(
      items: items,
      totalCount: (json['totalCount'] as num?)?.toInt(),
      page: (json['page'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
    );
  }
}
