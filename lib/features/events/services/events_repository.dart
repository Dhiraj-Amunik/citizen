import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/events/model/event_details_model.dart';
import 'package:inldsevak/features/events/model/events_model.dart';
import 'package:inldsevak/features/events/model/request_details_event_model.dart';
import 'package:inldsevak/features/events/model/request_event_model.dart';

class EventsRepository {
  final _network = NetworkRequester();

  Future<RepoResponse<EventsModel>> getEvents(
    String? token, {
    required RequestEventModel model,
  }) async {
    final response = await _network.post(
      path: URLs.userEvents,
      token: token,
      data: model.toJson(),
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: EventsModel.fromJson(response));
  }

  Future<RepoResponse<EventDetailsModel>> getEventDetails(
    String? token, {
    required RequestEventDetailsModel model,
  }) async {
    final response = await _network.post(
      path: URLs.userEventsDetails,
      token: token,
      data: model.toJson(),
    );
    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: EventDetailsModel.fromJson(response));
  }
}
