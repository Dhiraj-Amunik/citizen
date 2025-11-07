enum NotifyReprFilter { recent, past }

class NotifyReprPaginationModel {
  NotifyReprFilter filter;
  int page;
  String? search;

  NotifyReprPaginationModel({required this.filter, required this.page, this.search});

  Map<String, dynamic> toJson() {
    return {
      'key': _notifyFilterToString(filter),
      'page': page,
      'pageSize': 5,
      'search': search,
    };
  }

  String _notifyFilterToString(NotifyReprFilter filter) {
    switch (filter) {
      case NotifyReprFilter.recent:
        return 'recent';
      case NotifyReprFilter.past:
        return 'past';
    }
  }
}
