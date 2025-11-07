class PaginationModel {
  final int? page;

  const PaginationModel({this.page});

  Map<String, dynamic> toJson() {
    return {'page': page ?? 1, 'pageSize': 5};
  }
}
