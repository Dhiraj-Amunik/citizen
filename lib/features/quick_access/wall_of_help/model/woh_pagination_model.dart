class WOHPaginationModel {
  final int? page;
  final String? search;
  final String? status;
  final int? date;

  const WOHPaginationModel({this.status, this.date, this.page, this.search});

  Map<String, dynamic> toJson() {
    return {
      'page': page ?? 1,
      'pageSize': 5,
      'search': search,
      'status': status,
      'date': date,
    };
  }
}
