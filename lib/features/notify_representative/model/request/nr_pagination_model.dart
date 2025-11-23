enum NotifyReprFilter { recent, past }

class NotifyReprPaginationModel {
  NotifyReprFilter filter;
  int page;
  String? search;
  List<String>? constituencies;
  List<String>? mlaIds;
  List<String>? districts;
  List<String>? mandals;
  List<String>? villages;
  String? sortBy; // "-1" for descending, "1" for ascending

  NotifyReprPaginationModel({
    required this.filter,
    required this.page,
    this.search,
    this.constituencies,
    this.mlaIds,
    this.districts,
    this.mandals,
    this.villages,
    this.sortBy,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'key': _notifyFilterToString(filter),
      'page': page,
      'pageSize': 20,
      'search': search ?? "",
    };
    
    // Add arrays for filters - API expects arrays
    if (constituencies != null && constituencies!.isNotEmpty) {
      data['constituencies'] = constituencies;
    }
    if (mlaIds != null && mlaIds!.isNotEmpty) {
      data['mlaId'] = mlaIds;
    }
    if (districts != null && districts!.isNotEmpty) {
      data['district'] = districts;
    }
    if (mandals != null && mandals!.isNotEmpty) {
      data['mandal'] = mandals;
    }
    if (villages != null && villages!.isNotEmpty) {
      data['village'] = villages;
    }
    
    // Add sortBy if provided
    if (sortBy != null && sortBy!.isNotEmpty) {
      data['sortBy'] = sortBy;
    }
    
    return data;
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
