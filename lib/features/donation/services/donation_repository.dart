import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/donation/models/request/donation_request_model.dart';
import 'package:inldsevak/features/donation/models/response/donation_history_model.dart';
import 'package:inldsevak/features/donation/models/response/donation_model.dart';

class DonationRepository {
  final _network = NetworkRequester();

  Future<RepoResponse<DonationModel>> postDonation({
    required DonationRequestModel data,
    required String token,
  }) async {
    final response = await _network.post(
      path: URLs.postDonation,
      data: data.toJson(),
      token: token,
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: DonationModel.fromJson(response));
  }

    Future<RepoResponse<DonationHistoryModel>> pastDonations({
    required String? token,
  }) async {
    final response = await _network.post(
      path: URLs.pastDonation,
      token: token,
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: DonationHistoryModel.fromJson(response));
  }
}
