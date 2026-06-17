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

  PagedResponse<T> copyWith({
    List<T>? items,
    int? totalCount,
    int? page,
    int? pageSize,
  }) {
    return PagedResponse(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  /// Applies [page] / [pageSize] when the API returns a full list instead of a
  /// server-paged slice (plain JSON array or oversized `items`).
  PagedResponse<T> applyPage({required int page, required int pageSize}) {
    final safePage = page < 1 ? 1 : page;
    final safePageSize = pageSize < 1 ? 1 : pageSize;
    final total = totalCount ?? items.length;

    final serverAlreadyPaged = this.page == safePage &&
        this.pageSize == safePageSize &&
        items.length <= safePageSize;

    if (serverAlreadyPaged) {
      return copyWith(
        totalCount: total,
        page: safePage,
        pageSize: safePageSize,
      );
    }

    final start = (safePage - 1) * safePageSize;
    if (start >= total || start >= items.length) {
      return PagedResponse(
        items: const [],
        totalCount: total,
        page: safePage,
        pageSize: safePageSize,
      );
    }

    final end = start + safePageSize;
    final sliceEnd = end > items.length ? items.length : end;

    return PagedResponse(
      items: items.sublist(start, sliceEnd),
      totalCount: total,
      page: safePage,
      pageSize: safePageSize,
    );
  }

  /// Handles both `{ items, totalCount }` payloads and plain JSON arrays.
  factory PagedResponse.parse(
    dynamic json,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    if (json is List) {
      final items = <T>[];
      for (final item in json) {
        if (item is Map) {
          items.add(itemParser(Map<String, dynamic>.from(item)));
        }
      }
      return PagedResponse(
        items: items,
        totalCount: items.length,
      );
    }

    if (json is Map) {
      return PagedResponse.fromJson(
        Map<String, dynamic>.from(json),
        itemParser,
      );
    }

    return const PagedResponse(items: []);
  }

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    final rawItems = json['items'] ??
        json['Items'] ??
        json['data'] ??
        json['results'];
    final items = <T>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          items.add(itemParser(Map<String, dynamic>.from(item)));
        }
      }
    }

    return PagedResponse(
      items: items,
      totalCount: _readInt(json, 'totalCount', 'TotalCount'),
      page: _readInt(json, 'page', 'Page'),
      pageSize: _readInt(json, 'pageSize', 'PageSize'),
    );
  }

  static int? _readInt(Map<String, dynamic> json, String camel, String pascal) {
    final value = json[camel] ?? json[pascal];
    if (value is num) return value.toInt();
    return null;
  }
}
