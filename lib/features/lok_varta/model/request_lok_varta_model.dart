enum LokVartaFilter { PressRelease, Interview, PhotoGallery, Videos }

enum SortOrder { Newest, Oldest }

class RequestLokVartaModel {
  String? search;
  SortOrder? sort;
  LokVartaFilter filter;
  int? page;
  int? pageSize;

  RequestLokVartaModel({
    this.search,
    this.sort,
    required this.filter,
    this.page,
    this.pageSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'search': search,
      'sort': _sortOrderToString(sort ?? SortOrder.Newest),
      'filter': _filterToString(filter),
      'page': page,
      'pageSize': pageSize,
    };
  }

  String _sortOrderToString(SortOrder order) {
    switch (order) {
      case SortOrder.Newest:
        return '-1';
      case SortOrder.Oldest:
        return '1';
    }
  }

  String _filterToString(LokVartaFilter filter) {
    switch (filter) {
      case LokVartaFilter.PressRelease:
        return 'PressRelease';
      case LokVartaFilter.Interview:
        return 'Interview';
      case LokVartaFilter.PhotoGallery:
        return 'PhotoGallery';
      case LokVartaFilter.Videos:
        return 'Videos';
    }
  }
}
