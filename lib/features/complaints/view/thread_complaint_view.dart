import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/mixin/handle_multiple_files_sheet.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/hindi_keyboard.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/features/complaints/view_model/thread_view_model.dart';
import 'package:inldsevak/features/complaints/widgets/complaint_widget.dart';
import 'package:inldsevak/features/complaints/widgets/complaint_helpers.dart';
import 'package:inldsevak/features/complaints/widgets/follow_up_questions_bottom_sheet.dart';
import 'package:inldsevak/features/complaints/widgets/handle_threads_images.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_common_child.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_by_thread.dart'
    as threads;
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:inldsevak/l10n/general_stream.dart';

class ThreadComplaintView extends StatefulWidget {
  final Data data;
  const ThreadComplaintView({super.key, required this.data});

  @override
  State<ThreadComplaintView> createState() => _ThreadComplaintViewState();
}

class _ThreadComplaintViewState extends State<ThreadComplaintView>
    with HandleMultipleFilesSheet {
  final scrollController = ScrollController();
  ThreadViewModel? _threadViewModel;
  bool _hasShownFollowUpSheet = false;
  bool _hasShownFlowClosedPopup = false;
  final FocusNode _messageFocusNode = FocusNode();
  bool _isHindiKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    // Listen to focus changes to detect Hindi keyboard visibility
    _messageFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _messageFocusNode.removeListener(_onFocusChange);
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;

    final isHindiLanguage = GeneralStream.instance.locale.languageCode == 'hi';
    final hasFocus = _messageFocusNode.hasFocus;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    // Hindi keyboard is showing if: Hindi language + has focus + system keyboard not showing
    final shouldShowHindiKeyboard =
        isHindiLanguage && hasFocus && viewInsets == 0;

    if (_isHindiKeyboardVisible != shouldShowHindiKeyboard) {
      setState(() {
        _isHindiKeyboardVisible = shouldShowHindiKeyboard;
      });

      // Hide system keyboard when Hindi keyboard is shown
      if (shouldShowHindiKeyboard) {
        // Hide immediately
        SystemChannels.textInput.invokeMethod('TextInput.hide');

        // Hide again after a short delay to ensure it stays hidden
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _messageFocusNode.hasFocus) {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          }
        });

        // Hide again after another delay to catch any late-appearing keyboard
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _messageFocusNode.hasFocus) {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          }
        });
      }
    } else if (shouldShowHindiKeyboard) {
      // Continuously hide system keyboard if it keeps appearing
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _messageFocusNode.hasFocus && viewInsets == 0) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        }
      });
    }
  }

  void _showReplyForm([ThreadViewModel? provider]) {
    final threadProvider =
        provider ?? _threadViewModel ?? context.read<ThreadViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ChangeNotifierProvider.value(
        value: threadProvider,
        child: _FollowUpReplyForm(
          complaintId: widget.data.sId ?? '',
          currentStatus: widget.data.status ?? 'pending',
        ),
      ),
    );
  }

  void _checkAndShowFollowUpQuestions(ThreadViewModel viewModel) {
    // Check if follow-up is due and questions are available
    final isFollowUpDue = viewModel.complaintData?.isFollowUpDue == true;
    final nextAction = viewModel.complaintData?.nextAction;
    final questions = viewModel.complaintData?.followUpQuestions;

    // If follow-up is no longer due, reset the flag to allow showing again when it becomes due
    if (!isFollowUpDue) {
      _hasShownFollowUpSheet = false;
      return;
    }

    // Don't open bottom sheet if nextAction is "none" even if isFollowUpDue is true
    if (nextAction == "none") {
      return;
    }

    // Only show once per complaint load when follow-up becomes due
    if (!_hasShownFollowUpSheet &&
        isFollowUpDue &&
        questions != null &&
        questions.isNotEmpty) {
      _hasShownFollowUpSheet = true;
      // Wait a bit to ensure UI is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showFollowUpQuestionsBottomSheet(viewModel);
        }
      });
    }
  }

  void _showFlowClosedSuccessPopup(String message) async {
    if (!mounted) return;

    await CommonSnackbar(text: message).showAnimatedDialog(
      type: QuickAlertType.success,
      onTap: () {
        // Popup will close automatically
      },
    );
  }

  void _showFollowUpQuestionsBottomSheet(ThreadViewModel viewModel) {
    final questions = viewModel.complaintData?.followUpQuestions;
    final complaintId = viewModel.complaintData?.sId ?? widget.data.sId ?? '';

    if (questions == null || questions.isEmpty || complaintId.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => ChangeNotifierProvider.value(
        value: viewModel,
        child: FollowUpQuestionsBottomSheet(
          questions: questions,
          complaintId: complaintId,
          viewModel: viewModel,
        ),
      ),
    ).then((_) {
      // Reset flag when bottom sheet is closed
      // This allows it to show again if follow-up becomes due again
      _hasShownFollowUpSheet = false;
    });
  }

  Widget _buildThreadMessage(threads.Data threadData, TextTheme textTheme) {
    final isUserMessage =
        threadData.from == "ajay.amunik@gmail.com" ||
        threadData.from == "me" ||
        threadData.senderType == "user";

    return Column(
      crossAxisAlignment: isUserMessage
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimens.radiusX4),
            color: isUserMessage
                ? AppPalettes.liteGreenColor
                : AppPalettes.backGroundColor,
          ),
          margin:
              EdgeInsets.symmetric(
                horizontal: Dimens.marginX2,
                vertical: Dimens.marginX2,
              ).copyWith(
                left: isUserMessage ? Dimens.marginX8 : null,
                right: isUserMessage ? null : Dimens.marginX8,
              ),
          padding: isUserMessage
              ? const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ).copyWith(right: 24)
              : const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ).copyWith(right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isUserMessage
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            spacing: Dimens.gapX,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 50.width()),
                child: TranslatedText(
                  text: threadData.normalizedBody ?? threadData.body ?? "",
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppPalettes.lightTextColor,
                  ),
                ),
              ),
              if (threadData.attachments?.isNotEmpty == true)
                HandleThreadsImages(
                  attachment: threadData.attachments ?? [],
                ).verticalPadding(Dimens.paddingX1B),
              Text(
                (DateTime.tryParse(threadData.date ?? "") ?? DateTime.now())
                    .add(Duration(hours: 5, minutes: 30))
                    .toString()
                    .to12HourTime(),
                style: textTheme.labelMedium?.copyWith(
                  color: AppPalettes.lightTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;
    // final threadIndex = context.read<ThreadIndexBuilder>();
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Refresh complaints list when navigating back to update unread counts
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                final complaintsVm = context.read<ComplaintsViewModel>();
                complaintsVm.getComplaints(
                  showLoader: false,
                  preserveSearch: true,
                );
              } catch (e) {
                debugPrint("Error refreshing complaints on pop: $e");
              }
            }
          });
        }
      },
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: commonAppBar(
            child: TranslatedText(
              text:
                  ComplaintHelper.decodeUtf8(
                    widget.data.messages?.first.subject,
                  ) ??
                  '',
              style: textTheme.headlineMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // Disable translation for decoded text - it should display correctly as-is
              disableTranslation: true,
            ).horizontalPadding(Dimens.horizontalspacing),
            scrollElevation: 0,
          ),
          body: ChangeNotifierProvider(
            create: (context) {
              final viewModel = ThreadViewModel(arguments: widget.data);
              // Store reference for access from dialogs
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _threadViewModel = viewModel;
                  // Show follow-up questions bottom sheet if due
                  _checkAndShowFollowUpQuestions(viewModel);
                }
              });
              return viewModel;
            },
            builder: (contextP, child) {
              final provider = contextP.watch<ThreadViewModel>();
              _threadViewModel = provider; // Keep reference updated

              final isResolved =
                  widget.data.status?.toLowerCase() == 'resolved' ||
                  provider.complaintData?.status?.toLowerCase() == 'resolved';

              // Check for follow-up questions after data is loaded
              if (!provider.loadMessages) {
                // Reset flag if follow-up is no longer due (flow ended)
                if (provider.complaintData?.isFollowUpDue != true) {
                  _hasShownFollowUpSheet = false;
                }

                // Show bottom sheet if follow-up is due and hasn't been shown yet
                if (!_hasShownFollowUpSheet &&
                    provider.complaintData?.isFollowUpDue == true &&
                    provider.complaintData?.followUpQuestions != null &&
                    provider.complaintData!.followUpQuestions!.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _checkAndShowFollowUpQuestions(provider);
                  });
                }
              }

              if (provider.loadMessages) {
                return Center(child: CustomAnimatedLoading());
              }
              return Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            ComplaintThreadWidget(
                              showAuthority: true,
                              thread: widget.data.copyWith(
                                status:
                                    provider.complaintData?.status ??
                                    widget.data.status,
                              ),
                              onTap: () {},
                            ).symmetricPadding(horizontal: Dimens.paddingX3),
                            Expanded(
                              child: Container(
                                decoration: boxDecorationRoundedWithShadow(
                                  Dimens.radiusX2,
                                  border: BoxBorder.all(
                                    color: AppPalettes.primaryColor,
                                  ),
                                ),
                                margin: EdgeInsets.symmetric(
                                  horizontal: Dimens.paddingX3,
                                  vertical: Dimens.paddingX3,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: false,
                                  reverse: true,
                                  controller: scrollController,
                                  itemBuilder: (context, index) {
                                    // Show resolved message at the bottom (first item in reversed list)
                                    if (isResolved && index == 0) {
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: Dimens.marginX2,
                                          vertical: Dimens.marginX2,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: Dimens.paddingX3,
                                          vertical: Dimens.paddingX2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppPalettes.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            Dimens.radiusX2,
                                          ),
                                          border: Border.all(
                                            color: AppPalettes.primaryColor
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: AppPalettes.primaryColor,
                                              size: Dimens.scaleX3,
                                            ),
                                            SizedBox(width: Dimens.paddingX1),
                                            Flexible(
                                              child: TranslatedText(
                                                text: localization
                                                    .your_complaint_has_been_resolved,
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                      color: AppPalettes
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    // Thread messages use adjusted index (resolved message is at index 0)
                                    final threadIndex = isResolved
                                        ? index - 1
                                        : index;
                                    if (threadIndex < 0 ||
                                        threadIndex >=
                                            provider.threadsList.length) {
                                      return SizedBox.shrink();
                                    }

                                    return _buildThreadMessage(
                                      provider.threadsList[threadIndex],
                                      textTheme,
                                    );
                                  },
                                  itemCount: isResolved
                                      ? provider.threadsList.length + 1
                                      : provider.threadsList.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Disable chat input if resolved
                      if (!isResolved)
                        Padding(
                          padding: EdgeInsets.only(
                            // Add padding when Hindi keyboard is visible to push input above keyboard
                            bottom: _isHindiKeyboardVisible
                                ? (MediaQuery.of(context).size.height * 0.45)
                                      .clamp(350.0, 550.0)
                                : 0,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimens.paddingX2,
                              vertical: Dimens.paddingX4,
                            ),
                            decoration: boxDecorationRoundedWithShadow(
                              Dimens.radius,
                              backgroundColor: AppPalettes.liteGreenColor,
                            ),
                            child: Row(
                              spacing: Dimens.gapX2,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: Dimens.paddingX2,
                                    right: Dimens.paddingX1,
                                    bottom: Dimens.paddingX,
                                  ),
                                  child: CommonHelpers.buildIcons(
                                    path: AppImages.cameraIcon,
                                    iconSize: Dimens.scaleX3,
                                    iconColor: AppPalettes.primaryColor,
                                    onTap: () {
                                      // 🔥 Use plain bottom sheet for camera (DraggableSheet causes crashes on low-RAM)
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: false,
                                        useRootNavigator: false,
                                        builder: (bottomSheetContext) =>
                                            Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(
                                                  bottomSheetContext,
                                                ).viewInsets.bottom,
                                              ),
                                              child: selectMultipleFiles(
                                                onTap: provider.addFiles,
                                                context: bottomSheetContext,
                                              ),
                                            ),
                                      );
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: FormTextFormField(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: Dimens.paddingX3,
                                      vertical: Dimens.paddingX3B,
                                    ),
                                    radius: Dimens.radius100,
                                    hintText: localization.message,
                                    controller: provider.nextThreadController,
                                    focus: _messageFocusNode,
                                    enableSpeechInput: true,
                                    maxLines: 1,
                                    keyboardType: TextInputType.text,
                                    disableHindiKeyboardOverlay:
                                        true, // Parent will handle keyboard display
                                    onChanged: (value) {
                                      // Ensure we're only working with what user types
                                      // This prevents any unwanted text from being added
                                    },
                                    suffixWidget:
                                        provider.multipleFiles.isNotEmpty
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                              right: Dimens.paddingX2,
                                            ),
                                            child: Chip(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimens.radiusX4,
                                                    ),
                                                side: BorderSide(
                                                  color:
                                                      AppPalettes.primaryColor,
                                                  width: 1,
                                                ),
                                              ),
                                              label: Text(
                                                "${provider.multipleFiles.length} ${localization.images}",
                                              ),
                                              onDeleted: () =>
                                                  provider.removefiles(),
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                Consumer<ThreadViewModel>(
                                  builder: (context, value, _) {
                                    return Container(
                                      padding: EdgeInsets.all(
                                        Dimens.paddingX2B,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppPalettes.primaryColor,
                                      ),
                                      child: GestureDetector(
                                        onTap: value.isLoading
                                            ? () {}
                                            : () {
                                                // Get the exact text from controller (what user typed)
                                                final messageText = value
                                                    .nextThreadController
                                                    .text
                                                    .trim();
                                                debugPrint(
                                                  "📤 Main thread view - Message being sent: '$messageText'",
                                                );
                                                // Ensure we're sending only what's in the text field
                                                // The controller already has the user's input
                                                provider.replyThread(
                                                  id: widget.data.sId ?? "",
                                                );
                                              },
                                        child: value.isLoading
                                            ? SizedBox(
                                                width: Dimens.scaleX3,
                                                height: Dimens.scaleX3,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                  left: Dimens.paddingX1,
                                                ),
                                                child: Icon(
                                                  Icons.send,
                                                  size: Dimens.scaleX3,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Hindi keyboard widget - shown when Hindi keyboard is visible (overlay at bottom)
                  if (_isHindiKeyboardVisible && !isResolved)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate responsive height: 45% of screen height, with min 350 and max 550
                          final screenHeight = MediaQuery.of(
                            context,
                          ).size.height;
                          final keyboardHeight = (screenHeight * 0.45).clamp(
                            350.0,
                            550.0,
                          );
                          return SizedBox(
                            height: keyboardHeight,
                            child: Material(
                              elevation: 8,
                              child: HindiKeyboard(
                                controller: provider.nextThreadController,
                                onDismiss: () {
                                  _messageFocusNode.unfocus();
                                },
                                onEnter: () {
                                  _messageFocusNode.unfocus();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Attempt to fix subjects returned as double-encoded UTF-8 (e.g. "Ã Â¤Â…")

class _FollowUpReplyForm extends StatefulWidget {
  final String complaintId;
  final String currentStatus;

  const _FollowUpReplyForm({
    required this.complaintId,
    required this.currentStatus,
  });

  @override
  State<_FollowUpReplyForm> createState() => _FollowUpReplyFormState();
}

class _FollowUpReplyFormState extends State<_FollowUpReplyForm>
    with HandleMultipleFilesSheet {
  final messageController = TextEditingController();
  final statusController = SingleSelectController<String>(null);
  // Only these three statuses are available in the dropdown
  final List<String> statusOptions = ['pending', 'in-progress', 'resolved'];

  String get selectedStatus => statusController.value ?? 'pending';

  @override
  void initState() {
    super.initState();
    final currentStatusLower = widget.currentStatus.toLowerCase();
    String initialStatus = 'pending';
    // Map old statuses to available ones if they're not in the dropdown
    if (currentStatusLower == 'closed') {
      initialStatus = 'resolved'; // Map closed to resolved
    } else if (currentStatusLower == 'escalated') {
      initialStatus = 'in-progress'; // Map escalated to in-progress
    } else if (statusOptions.contains(currentStatusLower)) {
      initialStatus = currentStatusLower;
    } else {
      initialStatus = 'pending'; // Default to pending if status is unknown
    }
    statusController.value = initialStatus;
  }

  @override
  void dispose() {
    messageController.dispose();
    statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;

    return DraggableSheetWidget(
      size: 0.9,
      child: Padding(
        padding: EdgeInsets.all(Dimens.paddingX3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText(
              text: 'Reply to Complaint',
              style: textTheme.headlineSmall?.copyWith(
                color: AppPalettes.primaryColor,
              ),
            ).verticalPadding(Dimens.paddingX2),
            // Status Dropdown
            FormCommonDropDown<String>(
              isRequired: true,
              heading: localization.status,
              hintText: localization.select_status,
              controller: statusController,
              items: statusOptions,
              listItemBuilder: (context, status, _, __) {
                String statusText;
                switch (status) {
                  case 'pending':
                    statusText = localization.pending;
                    break;
                  case 'in-progress':
                    statusText = localization.in_progress;
                    break;
                  case 'resolved':
                    statusText = localization.resolved;
                    break;
                  default:
                    statusText = status
                        .split('-')
                        .map(
                          (word) => word[0].toUpperCase() + word.substring(1),
                        )
                        .join(' ');
                }
                return Text(statusText, style: context.textTheme.bodySmall);
              },
              headerBuilder: (context, status, _) {
                String statusText;
                switch (status) {
                  case 'pending':
                    statusText = localization.pending;
                    break;
                  case 'in-progress':
                    statusText = localization.in_progress;
                    break;
                  case 'resolved':
                    statusText = localization.resolved;
                    break;
                  default:
                    statusText = status
                        .split('-')
                        .map(
                          (word) => word[0].toUpperCase() + word.substring(1),
                        )
                        .join(' ');
                }
                return Text(statusText, style: context.textTheme.bodySmall);
              },
              onChanged: (value) {
                if (value != null) {
                  setState(() {});
                }
              },
            ).verticalPadding(Dimens.paddingX2),

            // Message Field
            FormTextFormField(
              headingText: localization.message,
              hintText: localization.message,
              controller: messageController,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              enforceFirstLetterUppercase: true,
            ).verticalPadding(Dimens.paddingX2),

            // Attachments
            FormCommonChild(
              heading: 'Attachments',
              child: Consumer<ThreadViewModel>(
                builder: (context, provider, _) {
                  return Column(
                    children: [
                      if (provider.multipleFiles.isNotEmpty) ...[
                        Wrap(
                          spacing: Dimens.gapX2,
                          runSpacing: Dimens.gapX2,
                          children: provider.multipleFiles.map((file) {
                            return Chip(
                              label: Text(
                                file.path.split('/').last,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ).verticalPadding(Dimens.paddingX2),
                        CommonButton(
                          text: 'Clear All Attachments',
                          onTap: () {
                            provider.removefiles();
                          },
                          fullWidth: true,
                          color: AppPalettes.redColor,
                        ).verticalPadding(Dimens.paddingX1),
                      ],
                      CommonButton(
                        text: 'Add Attachments',
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => DraggableSheetWidget(
                              size: 0.5,
                              child: selectMultipleFiles(
                                onTap: provider.addFiles,
                              ),
                            ),
                          );
                        },
                        fullWidth: true,
                      ),
                    ],
                  );
                },
              ),
            ).verticalPadding(Dimens.paddingX2),
            // Submit Button
            Consumer<ThreadViewModel>(
              builder: (context, provider, _) {
                return CommonButton(
                  text: 'Send Reply',
                  isLoading: provider.isLoading,
                  onTap: () async {
                    // Allow sending if either message has text or files are attached
                    if (messageController.text.trim().isEmpty &&
                        provider.multipleFiles.isEmpty) {
                      CommonSnackbar(
                        text: "Message or image is required",
                      ).showToast();
                      return;
                    }
                    // Get the exact text user typed (trimmed)
                    final userMessage = messageController.text.trim();

                    // Clear previous text completely and set only what user typed
                    provider.nextThreadController.clear();
                    provider.nextThreadController.text = userMessage;

                    // Debug: Verify what we're about to send
                    debugPrint("📤 User typed: '$userMessage'");
                    debugPrint(
                      "📤 Controller text before send: '${provider.nextThreadController.text}'",
                    );

                    await provider.replyThread(
                      id: widget.complaintId,
                      status: selectedStatus,
                    );

                    // Clear the message controller after sending
                    messageController.clear();

                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ).verticalPadding(Dimens.paddingX3);
              },
            ),
          ],
        ),
      ),
    );
  }
}
