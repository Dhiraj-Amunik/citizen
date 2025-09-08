import 'package:flutter/material.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/features/profile_tabs/model/questions_model.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';

class HelpAndSupportViewModel extends ChangeNotifier {
  HelpAndSupportViewModel() {
    searchController.addListener(_onSearchChanged);
    buildList();
  }

  List<QuestionsModel> helpQuestionList = [];
  List<QuestionsModel> filteredQuestionList = [];
  final TextEditingController searchController = TextEditingController();

  void buildList() {
    final localization =
        RouteManager.navigatorKey.currentState!.context.localizations;
    helpQuestionList = [
      QuestionsModel(
        question: localization.how_do_i_submit_a_complaint,
        answer: "Enter data",
      ),
      QuestionsModel(
        question: localization.how_long_does_it_take_to_resolve_a_complaint,
        answer: localization.fill_the_complaint_form_with_details_and_submit,
      ),
      QuestionsModel(
        question: localization.can_i_upload_multiple_photos_with_my_complaint,
        answer: "Enter data",
      ),
      QuestionsModel(
        question: localization.how_do_i_track_my_complaint_status,
        answer: "Enter data",
      ),
      QuestionsModel(
        question: localization.is_my_personal_information_secure,
        answer: "Enter data",
      ),
    ];
    filteredQuestionList = List.from(helpQuestionList);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (query.isEmpty) {
      filteredQuestionList = List.from(helpQuestionList);
    } else {
      final lowerCaseQuery = query.toLowerCase();
      filteredQuestionList = helpQuestionList
          .where((item) => item.question.toLowerCase().contains(lowerCaseQuery))
          .toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    filteredQuestionList = List.from(helpQuestionList);
    notifyListeners();
  }

  void _onSearchChanged() {
    setSearchQuery(searchController.text);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}
