import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/complaints/model/request/complaint_case_request_model.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_by_thread.dart';
import 'package:inldsevak/features/complaints/view_model/thread_view_model.dart';
import 'package:inldsevak/features/surveys/widgets/choice_widget.dart';
import 'package:inldsevak/features/surveys/widgets/rating_widget.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class FollowUpQuestionsBottomSheet extends StatefulWidget {
  final List<FollowUpQuestion> questions;
  final String complaintId;
  final ThreadViewModel viewModel;

  const FollowUpQuestionsBottomSheet({
    super.key,
    required this.questions,
    required this.complaintId,
    required this.viewModel,
  });

  @override
  State<FollowUpQuestionsBottomSheet> createState() =>
      _FollowUpQuestionsBottomSheetState();
}

class _FollowUpQuestionsBottomSheetState
    extends State<FollowUpQuestionsBottomSheet> with DateAndTimePicker {
  final Map<int, String> _answers = {};
  final Map<int, DateTime?> _selectedDates = {};
  final Map<int, TextEditingController> _dateControllers = {};
  final Map<int, TextEditingController> _feedbackControllers = {};
  final Map<int, int> _ratings = {};
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    // Initialize answers from existing answers if any
    if (widget.questions.isNotEmpty) {
      for (int i = 0; i < widget.questions.length; i++) {
        if (widget.questions[i].answer != null &&
            widget.questions[i].answer!.isNotEmpty) {
          _answers[i] = widget.questions[i].answer!;
        }
        // Initialize date controller for each question
        _dateControllers[i] = TextEditingController();
        // Initialize feedback controller for each question
        _feedbackControllers[i] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    // Dispose all date controllers
    for (var controller in _dateControllers.values) {
      controller.dispose();
    }
    // Dispose all feedback controllers
    for (var controller in _feedbackControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selectAnswer(int questionIndex, String? answer) {
    if (answer != null && answer.isNotEmpty && !_isSubmitted) {
      setState(() {
        _answers[questionIndex] = answer;
        
        // If "in progress" is selected, set default date to 7 days from now
        if (answer.toLowerCase().contains('in progress') || 
            answer.toLowerCase() == 'in progress') {
          if (!_selectedDates.containsKey(questionIndex) || 
              _selectedDates[questionIndex] == null) {
            final defaultDate = DateTime.now().add(const Duration(days: 7));
            _selectedDates[questionIndex] = defaultDate;
            _dateControllers[questionIndex]?.text = userDateFormat(defaultDate);
          }
        } else {
          // Clear date if not "in progress"
          _selectedDates.remove(questionIndex);
          _dateControllers[questionIndex]?.clear();
        }
      });
    }
  }

  Future<void> _selectDate(int questionIndex) async {
    final selectedDate = await customDatePicker(
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (selectedDate != null && mounted) {
      setState(() {
        _selectedDates[questionIndex] = selectedDate;
        _dateControllers[questionIndex]?.text = userDateFormat(selectedDate);
      });
    }
  }

  bool _isInProgressSelected(int questionIndex) {
    final answer = _answers[questionIndex]?.toLowerCase() ?? '';
    return answer.contains('in progress') || answer == 'in progress';
  }

  bool _isFeedbackQuestion(int questionIndex, List<FollowUpQuestion> questions) {
    if (questionIndex >= questions.length) return false;
    final question = questions[questionIndex].question?.toLowerCase() ?? '';
    return question.contains('feedback') || question.contains('rating');
  }

  void _onRatingChanged(int questionIndex, double? value) {
    if (value != null) {
      setState(() {
        _ratings[questionIndex] = value.toInt();
      });
    }
  }

  bool _isQuestionAnswered(int index) {
    return _answers.containsKey(index) && _answers[index]!.isNotEmpty;
  }

  bool _allQuestionsAnswered(List<FollowUpQuestion> questions) {
    for (int i = 0; i < questions.length; i++) {
      if (!_isQuestionAnswered(i)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _submitAnswers(List<FollowUpQuestion> questions) async {
    if (!_allQuestionsAnswered(questions)) {
      // Don't submit if not all questions are answered
      return;
    }

    // Get the last question's answer as the response
    // The API expects the response to be the answer to the current/last question
    final lastQuestionIndex = questions.length - 1;
    final response = _answers[lastQuestionIndex];
    
    if (response == null || response.isEmpty) {
      return;
    }

    // Check if the last question is a feedback question
    final lastQuestion = questions[lastQuestionIndex];
    final isFeedbackQuestion = lastQuestion.question
            ?.toLowerCase()
            .contains('feedback') == true ||
        lastQuestion.question?.toLowerCase().contains('rating') == true;

    FeedbackModel? feedbackToSend;
    if (isFeedbackQuestion) {
      // Get rating and feedback message from user input
      String feedbackType = response.toLowerCase();
      int rating = _ratings[lastQuestionIndex] ?? 0;
      String feedbackMessage = _feedbackControllers[lastQuestionIndex]?.text.trim() ?? '';
      
      // If no rating selected, map feedback options to default ratings
      if (rating == 0) {
        if (feedbackType == 'good') {
          rating = 5;
        } else if (feedbackType == 'bad') {
          rating = 1;
        } else if (feedbackType == 'neutral') {
          rating = 3;
        }
      }
      
      feedbackToSend = FeedbackModel(
        message: feedbackMessage.isNotEmpty ? feedbackMessage : (lastQuestion.question ?? ''),
        rating: rating,
        feedbackType: feedbackType,
      );
    }

    // Get the date if "in progress" is selected for any question
    String? dateToSend;
    for (int i = 0; i < questions.length; i++) {
      if (_isInProgressSelected(i) && _selectedDates.containsKey(i) && _selectedDates[i] != null) {
        dateToSend = companyDateFormat(_selectedDates[i]!);
        break; // Use the first "in progress" question's date
      }
    }

    // Show loading in button during submission
    final success = await widget.viewModel.submitComplaintCase(
      complaintId: widget.complaintId,
      response: response,
      feedback: feedbackToSend,
      date: dateToSend,
    );

    if (!success) {
      // If submission failed, don't proceed
      return;
    }
    
    // After successful submission, refresh thread data to get updated questions
    // This will update the questions list with answers from the API
    // Use getThreads without showing page-level loading
    await widget.viewModel.getThreads();

    // Check if flow is closed and show flow closed message
    if (mounted) {
      final isflowClosed = widget.viewModel.complaintData?.isflowClosed == true;
      final flowCloasedMessage = widget.viewModel.complaintData?.flowCloasedMessage;
      
      if (isflowClosed && flowCloasedMessage != null && flowCloasedMessage.isNotEmpty) {
        // Mark as submitted to prevent further changes
        setState(() {
          _isSubmitted = true;
        });

        // Close the bottom sheet first
        Navigator.of(context).pop();

        // Show flow closed success popup
        await CommonSnackbar(
          text: flowCloasedMessage,
        ).showAnimatedDialog(
          type: QuickAlertType.success,
          onTap: () async {
            // Wait a bit for the dialog to close completely
            await Future.delayed(const Duration(milliseconds: 100));
            
            // Pop the current screen (thread complaint view) first
            RouteManager.pop();
            
            // Wait a bit for the pop to complete
            await Future.delayed(const Duration(milliseconds: 100));
            
            // Then navigate to complaints view
            try {
              await RouteManager.pushNamed(Routes.complaintsPage);
            } catch (e) {
              debugPrint("Error navigating to complaints view: $e");
            }
          },
        );
        return;
      }
    }

    // Check if the first question is "Did you receive a reply from higher authority?" and answer is "No"
    final firstQuestion = questions.isNotEmpty ? questions[0] : null;
    final firstAnswer = _answers[0];
    final questionText = firstQuestion?.question?.toLowerCase() ?? '';
    final isNoReplyQuestion = questionText.contains('did you receive a reply') && 
                               questionText.contains('higher authority');
    final isNoSelected = firstAnswer?.toLowerCase().trim() == 'no';

    // If user selected "No" for the first question, show success popup and navigate
    if (isNoReplyQuestion && isNoSelected && mounted) {
      // Mark as submitted to prevent further changes
      setState(() {
        _isSubmitted = true;
      });

      // Close the bottom sheet first
      Navigator.of(context).pop();

      // Show success popup
      await CommonSnackbar(
        text: 'Issue will be forwarded to higher authority',
      ).showAnimatedDialog(
        type: QuickAlertType.success,
        onTap: () async {
          // Get context from RouteManager to ensure it's valid
          final BuildContext? navContext =
              RouteManager.navigatorKey.currentState?.context;
          
          // Wait a bit for the dialog to close completely
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Pop the current screen (thread complaint view) first
          RouteManager.pop();
          
          // Wait a bit for the pop to complete
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Then navigate to complaints view
          try {
            await RouteManager.pushNamed(Routes.complaintsPage);
          } catch (e) {
            debugPrint("Error navigating to complaints view: $e");
          }
        },
      );
      return;
    }

    // Note: getThreads() was already called above, so we don't need to call it again here

    if (mounted) {
      final nextAction = widget.viewModel.complaintData?.nextAction;
      final isFollowUpDue = widget.viewModel.complaintData?.isFollowUpDue ?? false;
      final updatedQuestions = widget.viewModel.complaintData?.followUpQuestions;

      // If nextAction is "none" and isFollowUpDue is true, close and navigate to complaints view
      if (nextAction == "none" && isFollowUpDue) {
        // Clear all state before closing
        setState(() {
          _answers.clear();
          _selectedDates.clear();
          _ratings.clear();
          for (var controller in _dateControllers.values) {
            controller.clear();
          }
          for (var controller in _feedbackControllers.values) {
            controller.clear();
          }
          _isSubmitted = false;
        });
        Navigator.of(context).pop();
        // Navigate to complaints view
        RouteManager.pushNamed(Routes.complaintsPage);
        return;
      }

      // If follow-up is no longer due, clear state and close the sheet
      if (!isFollowUpDue) {
        // Clear all state when flow ends
        setState(() {
          _answers.clear();
          _selectedDates.clear();
          _ratings.clear();
          for (var controller in _dateControllers.values) {
            controller.clear();
          }
          for (var controller in _feedbackControllers.values) {
            controller.clear();
          }
          _isSubmitted = false;
        });
        Navigator.of(context).pop();
      } else if (updatedQuestions != null && updatedQuestions.isNotEmpty) {
        // If there are more questions, update the list and preserve existing answers
        setState(() {
          // Preserve answers that already exist in the updated questions from API
          final Map<int, String> preservedAnswers = {};
          for (int i = 0; i < updatedQuestions.length; i++) {
            if (updatedQuestions[i].answer != null && 
                updatedQuestions[i].answer!.isNotEmpty) {
              preservedAnswers[i] = updatedQuestions[i].answer!;
            }
          }
          
          // Clear and restore answers
          _answers.clear();
          _answers.addAll(preservedAnswers);
          
          // Re-initialize controllers for new questions
          for (int i = 0; i < updatedQuestions.length; i++) {
            if (!_dateControllers.containsKey(i)) {
              _dateControllers[i] = TextEditingController();
            }
            if (!_feedbackControllers.containsKey(i)) {
              _feedbackControllers[i] = TextEditingController();
            }
          }
          
          // Remove controllers for questions that no longer exist
          final keysToRemove = _dateControllers.keys.where((key) => key >= updatedQuestions.length).toList();
          for (var key in keysToRemove) {
            _dateControllers[key]?.dispose();
            _dateControllers.remove(key);
            _feedbackControllers[key]?.dispose();
            _feedbackControllers.remove(key);
          }
          
          // Reset submitted flag to allow next question submission
          _isSubmitted = false;
        });
      } else {
        // Clear state when no more questions
        setState(() {
          _answers.clear();
          _selectedDates.clear();
          _ratings.clear();
          for (var controller in _dateControllers.values) {
            controller.clear();
          }
          for (var controller in _feedbackControllers.values) {
            controller.clear();
          }
          _isSubmitted = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Consumer<ThreadViewModel>(
      builder: (context, viewModel, _) {
        // Get the latest questions from viewModel if available, otherwise use widget.questions
        final latestQuestions = viewModel.complaintData?.followUpQuestions ?? widget.questions;

        if (latestQuestions.isEmpty) {
          return DraggableSheetWidget(
            size: 0.3,
            child: Padding(
              padding: EdgeInsets.all(Dimens.paddingX3),
              child: TranslatedText(
                text: 'No follow-up questions available',
                style: textTheme.bodyMedium,
              ),
            ),
          );
        }

        final allAnswered = _allQuestionsAnswered(latestQuestions);

        return DraggableSheetWidget(
          size: 0.9,
          bottomChild: Padding(
            padding: EdgeInsets.all(Dimens.paddingX3),
            child: CommonButton(
              text: 'Submit',
              isLoading: viewModel.isLoading,
              onTap: allAnswered && !_isSubmitted
                  ? () => _submitAnswers(latestQuestions)
                  : null,
              fullWidth: true,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(Dimens.paddingX3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TranslatedText(
                  text: 'Follow-up Questions',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppPalettes.primaryColor,
                  ),
                ).verticalPadding(Dimens.paddingX2),

                // All questions in a column
                ...List.generate(latestQuestions.length, (index) {
                  final question = latestQuestions[index];
                  final selectedAnswer = _answers[index];
                  final isAnswered = _isQuestionAnswered(index);
                  final isLastQuestion = index == latestQuestions.length - 1;
                  final isEditable = isLastQuestion && !_isSubmitted;
                  final isRead = question.isRead == true;

                  return Container(
                    margin: EdgeInsets.only(bottom: Dimens.paddingX4),
                    padding: EdgeInsets.all(Dimens.paddingX3),
                    decoration: BoxDecoration(
                      color: AppPalettes.backGroundColor,
                      borderRadius: BorderRadius.circular(Dimens.radiusX2),
                      border: Border.all(
                        color: !isEditable
                            ? AppPalettes.greyColor.withOpacity(0.5)
                           
                                : AppPalettes.primaryColor
                             
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question number and text
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimens.paddingX2,
                                vertical: Dimens.paddingX1,
                              ),
                              decoration: BoxDecoration(
                                color: !isEditable
                                    ? AppPalettes.greyColor
                                    : AppPalettes.primaryColor,
                                borderRadius: BorderRadius.circular(Dimens.radiusX2),
                              ),
                              child: TranslatedText(
                                text: '${index + 1}',
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: Dimens.paddingX2),
                            Expanded(
                              child: TranslatedText(
                                text: question.question ?? '',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: isRead
                                      ? AppPalettes.greyColor
                                      : isEditable 
                                          ? null 
                                          : AppPalettes.lightTextColor,
                                ),
                              ),
                            ),
                          ],
                        ).verticalPadding(Dimens.paddingX2),

                        // Options - only last question is editable
                        if (!isEditable && isAnswered)
                          // Show read-only for previous questions or after submission
                          Wrap(
                            runSpacing: Dimens.gapX1B,
                            spacing: Dimens.gapX4,
                            children: (question.options ?? []).map((option) {
                              final isSelected = option == selectedAnswer;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: !isEditable
                                            ? AppPalettes.greyColor
                                            : !isEditable && isSelected
                                                ? AppPalettes.primaryColor
                                                : AppPalettes.greyColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: isRead
                                        ? null
                                        : isSelected 
                                            ? Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: !isEditable ? AppPalettes.greyColor : AppPalettes.primaryColor,
                                                ),
                                              )
                                            : null,
                                  ),
                                  SizedBox(width: Dimens.paddingX1),
                                  TranslatedText(
                                    text: option,
                                    style: textTheme.labelMedium?.copyWith(
                                      color: !isEditable
                                          ? AppPalettes.greyColor
                                          : isSelected
                                              ? AppPalettes.primaryColor
                                              : AppPalettes.lightTextColor,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ).verticalPadding(Dimens.paddingX2)
                        else if (isEditable)
                          // Editable only for last question
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ChoiceWidget(
                                options: question.options ?? [],
                                initiallySelected: selectedAnswer,
                                onOptionSelected: (answer) => _selectAnswer(index, answer),
                              ).verticalPadding(Dimens.paddingX2),
                              
                              // Show rating and feedback fields if feedback question and option is selected
                              if (_isFeedbackQuestion(index, latestQuestions) && 
                                  isAnswered && 
                                  isEditable)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TranslatedText(
                                      text: 'Rating',
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ).verticalPadding(Dimens.paddingX2),
                                    RatingWidget(
                                      value: _ratings[index] ?? 0,
                                      onChanged: (value) => _onRatingChanged(index, value),
                                    ).verticalPadding(Dimens.paddingX2),
                                    
                                    FormTextFormField(
                                      headingText: 'Feedback',
                                      hintText: 'Enter your feedback',
                                      controller: _feedbackControllers[index] ?? TextEditingController(),
                                      maxLines: 4,
                                      enableSpeechInput: true,
                                      textCapitalization: TextCapitalization.sentences,
                                      fillColor: AppPalettes.whiteColor,
                                    ).verticalPadding(Dimens.paddingX2),
                                  ],
                                ),
                            ],
                          )
                        else
                          // Show empty state for unanswered previous questions
                          TranslatedText(
                            text: 'Not answered',
                            style: textTheme.labelMedium?.copyWith(
                              color: AppPalettes.lightTextColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ).verticalPadding(Dimens.paddingX2),

                        // Show date picker if "in progress" is selected (only for editable/last question)
                        if (_isInProgressSelected(index) && isEditable)
                          FormTextFormField(
                            headingText: 'Select next follow-up date',
                            hintText: 'DD-MM-YYYY',
                            keyboardType: TextInputType.none,
                            controller: _dateControllers[index] ?? TextEditingController(),
                            suffixIcon: AppImages.calenderIcon,
                            showCursor: false,
                            onTap: () => _selectDate(index),
                          ).verticalPadding(Dimens.paddingX2),
                        // Show date as read-only for previous questions if "in progress" was selected
                        if (_isInProgressSelected(index) && !isEditable && _dateControllers[index]?.text.isNotEmpty == true)
                          FormTextFormField(
                            headingText: 'Selected Date',
                            hintText: 'DD-MM-YYYY',
                            keyboardType: TextInputType.none,
                            controller: _dateControllers[index] ?? TextEditingController(),
                            suffixIcon: AppImages.calenderIcon,
                            showCursor: false,
                            enabled: false,
                          ).verticalPadding(Dimens.paddingX2),
                      ],
                    ),
                  );
                }),
                // Add SizedBox at bottom when keyboard is opened
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        );
      },
    );
  }
}
