import 'package:inldsevak/core/dio/exception_handlers.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/dio/repo_reponse.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/features/quick_access/appointments/model/appointment_model.dart';
import 'package:inldsevak/features/quick_access/appointments/model/mla_dropdown_model.dart';
import 'package:inldsevak/features/quick_access/appointments/model/request_appointment_model.dart';

class AppointmentsRepository {
  final _network = NetworkRequester();

  Future<RepoResponse<MLADropdownModel>> getMLAsData(String? token) async {
    final response = await _network.get(path: URLs.userMLAs, token: token);

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: MLADropdownModel.fromJson(response));
  }

  Future<RepoResponse<AppointmentModel>> newAppointment(
    String? token, {
    required RequestAppointmentModel model,
  }) async {
    final response = await _network.post(
      path: URLs.createAppointment,
      token: token,
      data: model.toJson(),
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: AppointmentModel.fromJson(response));
  }

  Future<RepoResponse<AppointmentModel>> appointments(
    String? token, {
    String? status,
    int? date,
  }) async {
    final response = await _network.post(
      path: URLs.userAppointment,
      data: {"status": status, "date": date},
      token: token,
    );

    return response is APIException
        ? RepoResponse(error: response)
        : RepoResponse(data: AppointmentModel.fromJson(response));
  }
}
