class RequestParlimentIdModel {
  final String? id;
  const RequestParlimentIdModel({required this.id});
  Map<String, dynamic> toJson() {
    return {'parliamentaryConstituencyId': id};
  }
}
