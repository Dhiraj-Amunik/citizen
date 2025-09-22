import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/features/lok_varta/model/lok_varta_model.dart'
    as model;
import 'package:inldsevak/features/lok_varta/model/request_lok_varta_model.dart';
import 'package:inldsevak/features/lok_varta/services/lok_varta_repository.dart';
import 'package:inldsevak/features/lok_varta/model/mla_details_model.dart'
    as mladetails;

class LokVartaViewModel extends BaseViewModel {
  @override
  Future<void> onInit() async {
    await getMlaDetails();
    await getAllLokVarta();
    return super.onInit();
  }

  List<model.Media> pressReleasesList = [];
  List<model.Media> interviewsList = [];
  List<model.Media> articlesList = [];
  List<model.Media> videosList = [];
  List<model.Media> photoLists = [];

  mladetails.Mla? mlaModel;

  Future<void> getAllLokVarta() async {
    isLoading = true;

    try {
      await Future.wait([
        getLokVarta(LokVartaFilter.PressRelease),
        getLokVarta(LokVartaFilter.Interview),
        getLokVarta(LokVartaFilter.PhotoGallery),
      ]);
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  Future<void> getLokVarta(LokVartaFilter filters) async {
    try {
      final request = RequestLokVartaModel(filter: filters);
      final response = await LokVartaRepository().getLokVarta(
        token,
        model: request,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data?.media;

        if (data?.isNotEmpty == true) {
          switch (filters) {
            case LokVartaFilter.PressRelease:
              pressReleasesList = List<model.Media>.from(data as List);
              break;
            case LokVartaFilter.PhotoGallery:
              photoLists = List<model.Media>.from(data as List);
              break;
            case LokVartaFilter.Interview:
              interviewsList = List<model.Media>.from(data as List);
              break;
            default:
              break;
          }
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }

  Future<void> getMlaDetails() async {
    try {
      final response = await LokVartaRepository().getUserMlaDetails(token);

      if (response.data?.responseCode == 200) {
        mlaModel = response.data?.data?.mla;
        notifyListeners();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }
}
