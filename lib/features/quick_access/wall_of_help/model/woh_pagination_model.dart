class WOHPaginationModel {
  final int? page;
  final String? search;
  final String? status;
  final int? date;

  const WOHPaginationModel({this.status, this.date, this.page, this.search});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'page': page ?? 1,
      'pageSize': 5,
    };
    if (search != null && search!.isNotEmpty) {
      data['search'] = search;
    }
    if (status != null && status!.isNotEmpty) {
      data['status'] = status;
    }
    if (date != null) {
      data['date'] = date;
    }
    return data;
  }
}
