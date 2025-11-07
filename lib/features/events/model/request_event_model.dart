enum EventFilter { ongoing, upcoming, past }

class RequestEventModel {
  EventFilter filter;
  int page;
  int? pageSize;
  String? search;

  RequestEventModel({
    required this.filter,
    required this.page,
    this.pageSize,
    this.search,
  });

  Map<String, dynamic> toJson() {
    return {
      'filter': _eventFilterToString(filter),
      'page': page,
      'pageSize': pageSize,
      'search': search,
    };
  }

  String _eventFilterToString(EventFilter filter) {
    switch (filter) {
      case EventFilter.ongoing:
        return 'ongoing';
      case EventFilter.upcoming:
        return 'upcoming';
      case EventFilter.past:
        return 'past';
    }
  }
}
