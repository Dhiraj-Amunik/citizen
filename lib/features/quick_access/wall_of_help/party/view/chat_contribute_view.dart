import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/mixin/handle_multiple_files_sheet.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/hindi_keyboard.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/get_help_details.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/handle_chat_contribute_images_ui.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/chat_contribute_help_view_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/my_help_requests_view_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/wall_of_help_view_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/services/wall_of_help_repository.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/woh_pagination_model.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:provider/provider.dart';

class ChatContributeView extends StatefulWidget {
  final model.FinancialRequest helpRequest;

  const ChatContributeView({super.key, required this.helpRequest});

  @override
  State<ChatContributeView> createState() => _ChatContributeViewState();
}

class _ChatContributeViewState extends State<ChatContributeView> with HandleMultipleFilesSheet {
  late model.FinancialRequest _helpRequest;
  final FocusNode _messageFocusNode = FocusNode();
  bool _isHindiKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _helpRequest = widget.helpRequest;
    // Try to fetch full request details if missing fields
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFullRequestDetailsIfNeeded();
    });
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
    final shouldShowHindiKeyboard = isHindiLanguage && hasFocus && viewInsets == 0;
    
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
        if (mounted && _messageFocusNode.hasFocus) {
          final currentViewInsets = MediaQuery.of(context).viewInsets.bottom;
          if (currentViewInsets == 0) {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          }
        }
      });
    }
  }

  // Helper method to check if address is valid (not null and not empty)
  bool _isValidAddress(String? address) {
    return address != null && address.trim().isNotEmpty;
  }

  // Helper method to get the best available address
  String? _getBestAddress(String? currentAddress, String? newAddress) {
    if (_isValidAddress(newAddress)) {
      return newAddress;
    }
    if (_isValidAddress(currentAddress)) {
      return currentAddress;
    }
    return null;
  }

  Future<void> _fetchFullRequestDetailsIfNeeded() async {
    // Check if we have all required fields - handle empty strings as missing
    final hasAddress = _isValidAddress(_helpRequest.address);
    final hasDescription = _helpRequest.description != null && _helpRequest.description!.trim().isNotEmpty;
    final hasTypeOfHelp = _helpRequest.typeOfHelp != null;
    
    // If we're missing critical fields, try to fetch them
    if ((!hasAddress || !hasDescription || !hasTypeOfHelp) && _helpRequest.sId != null && mounted) {
      try {
        // First, try to get from MyHelpRequestsViewModel (user's own requests)
        try {
          final myHelpRequestsVm = context.read<MyHelpRequestsViewModel>();
          if (myHelpRequestsVm.myWallOFHelpLists.isNotEmpty) {
            final fullRequest = myHelpRequestsVm.myWallOFHelpLists.firstWhere(
              (req) => req.sId == _helpRequest.sId,
              orElse: () => _helpRequest,
            );
            
            if (mounted && fullRequest.sId == _helpRequest.sId) {
              // Check if we got better data
              final hasBetterAddress = _isValidAddress(fullRequest.address) && !hasAddress;
              final hasBetterDescription = fullRequest.description != null && 
                  fullRequest.description!.trim().isNotEmpty && 
                  (!hasDescription || _helpRequest.description == null || _helpRequest.description!.trim().isEmpty);
              final hasBetterTypeOfHelp = fullRequest.typeOfHelp != null && !hasTypeOfHelp;
              // Always update name from API if available (it's the correct name from request creator)
              final hasBetterName = fullRequest.name != null && fullRequest.name!.isNotEmpty;
              
              if (hasBetterAddress || hasBetterDescription || hasBetterTypeOfHelp || hasBetterName) {
                setState(() {
                  _helpRequest = model.FinancialRequest(
                    sId: _helpRequest.sId,
                    messageId: _helpRequest.messageId,
                    name: fullRequest.name ?? _helpRequest.name, // Prioritize name from API
                    address: _getBestAddress(_helpRequest.address, fullRequest.address),
                    description: _helpRequest.description ?? fullRequest.description,
                    typeOfHelp: _helpRequest.typeOfHelp ?? fullRequest.typeOfHelp,
                    updatedAt: _helpRequest.updatedAt ?? fullRequest.updatedAt,
                  );
                });
                // Continue to check if we still need more data
                final currentHasAddress = _isValidAddress(_helpRequest.address);
                final currentHasDescription = _helpRequest.description != null && _helpRequest.description!.trim().isNotEmpty;
                final currentHasTypeOfHelp = _helpRequest.typeOfHelp != null;
                if (currentHasAddress && currentHasDescription && currentHasTypeOfHelp) {
                  return; // All data found, exit early
                }
              }
            }
          }
        } catch (e) {
          debugPrint("MyHelpRequestsViewModel not available or request not found: $e");
        }
        
        // If not found in MyHelpRequestsViewModel, try WallOfHelpViewModel (all requests)
        try {
          final wallOfHelpVm = context.read<WallOfHelpViewModel>();
          if (wallOfHelpVm.wallOFHelpLists.isNotEmpty) {
            final fullRequest = wallOfHelpVm.wallOFHelpLists.firstWhere(
              (req) => req.sId == _helpRequest.sId,
              orElse: () => _helpRequest,
            );
            
            if (mounted && fullRequest.sId == _helpRequest.sId) {
              // Check if we got better data
              final hasBetterAddress = _isValidAddress(fullRequest.address) && !_isValidAddress(_helpRequest.address);
              final hasBetterDescription = fullRequest.description != null && 
                  fullRequest.description!.trim().isNotEmpty && 
                  (_helpRequest.description == null || _helpRequest.description!.trim().isEmpty);
              final hasBetterTypeOfHelp = fullRequest.typeOfHelp != null && _helpRequest.typeOfHelp == null;
              // Always update name from API if available (it's the correct name from request creator)
              final hasBetterName = fullRequest.name != null && fullRequest.name!.isNotEmpty;
              
              if (hasBetterAddress || hasBetterDescription || hasBetterTypeOfHelp || hasBetterName) {
                setState(() {
                  _helpRequest = model.FinancialRequest(
                    sId: _helpRequest.sId,
                    messageId: _helpRequest.messageId,
                    name: fullRequest.name ?? _helpRequest.name, // Prioritize name from API
                    address: _getBestAddress(_helpRequest.address, fullRequest.address),
                    description: _helpRequest.description ?? fullRequest.description,
                    typeOfHelp: _helpRequest.typeOfHelp ?? fullRequest.typeOfHelp,
                    updatedAt: _helpRequest.updatedAt ?? fullRequest.updatedAt,
                  );
                });
                // Continue to check if we still need more data
                final currentHasAddress = _isValidAddress(_helpRequest.address);
                final currentHasDescription = _helpRequest.description != null && _helpRequest.description!.trim().isNotEmpty;
                final currentHasTypeOfHelp = _helpRequest.typeOfHelp != null;
                if (currentHasAddress && currentHasDescription && currentHasTypeOfHelp) {
                  return; // All data found, exit early
                }
              }
            }
          }
        } catch (e) {
          debugPrint("WallOfHelpViewModel not available or request not found: $e");
        }
        
        // If still not found, try to fetch from API (search multiple pages if needed)
        if (mounted && (!_isValidAddress(_helpRequest.address) || !hasTypeOfHelp)) {
          await _fetchRequestFromAPI();
        }
      } catch (e) {
        debugPrint("Error fetching full request details: $e");
      }
    }
  }

  Future<void> _fetchRequestFromAPI() async {
    try {
      final token = await SessionController.instance.getToken();
      if (token == null || token.isEmpty || _helpRequest.sId == null) {
        return;
      }
      
      final repository = WallOfHelpRepository();
      
      // Try to search through multiple pages (up to 5 pages to avoid too many requests)
      for (int page = 1; page <= 5; page++) {
        if (!mounted) break;
        
        final paginationModel = WOHPaginationModel(page: page);
        final response = await repository.getUsersWallOFHelp(
          token: token,
          model: paginationModel,
        );
        
        if (response.data?.responseCode == 200 && mounted) {
          final allRequests = response.data?.data?.financialRequest ?? [];
          
          // Check if we found the request
          try {
            final request = allRequests.firstWhere(
              (req) => req.sId == _helpRequest.sId,
            );
            
            // Found the request, update it
            if (mounted) {
              final hasBetterAddress = _isValidAddress(request.address) && !_isValidAddress(_helpRequest.address);
              final hasBetterDescription = request.description != null && 
                  request.description!.trim().isNotEmpty && 
                  (_helpRequest.description == null || _helpRequest.description!.trim().isEmpty);
              final hasBetterTypeOfHelp = request.typeOfHelp != null && _helpRequest.typeOfHelp == null;
              
              // Always update name from API if available (it's the correct name from request creator)
              final hasBetterName = request.name != null && request.name!.isNotEmpty;
              if (hasBetterAddress || hasBetterDescription || hasBetterTypeOfHelp || hasBetterName) {
                setState(() {
                  _helpRequest = model.FinancialRequest(
                    sId: _helpRequest.sId,
                    messageId: _helpRequest.messageId,
                    name: request.name ?? _helpRequest.name, // Prioritize name from API
                    address: _getBestAddress(_helpRequest.address, request.address),
                    description: _helpRequest.description ?? request.description,
                    typeOfHelp: _helpRequest.typeOfHelp ?? request.typeOfHelp,
                    updatedAt: _helpRequest.updatedAt ?? request.updatedAt,
                  );
                });
              }
              break; // Found the request, exit loop
            }
          } catch (e) {
            // Request not found on this page, continue to next page
            continue;
          }
          
          // If this page has fewer items than page size, we've reached the end
          final pageSize = response.data?.data?.pageSize ?? 10;
          if (allRequests.length < pageSize) {
            break; // No more pages
          }
        } else {
          break; // Error response, stop searching
        }
      }
    } catch (e) {
      debugPrint("Error fetching request from API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    log(_helpRequest.toJson().toString());
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return ChangeNotifierProvider(
      create: (context) =>
          ChatContributeHelpViewModel(arguments: _helpRequest.messageId ?? ""),
      builder: (contextP, widget) {
        final provider = contextP.watch<ChatContributeHelpViewModel>();

        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: commonAppBar(
            title: localization.contribute,
            scrollElevation: 0,
          ),
          body: Stack(
            children: [
              Column(
                children: [
              StreamBuilder<Locale>(
                stream: GeneralStream.instance.language,
                builder: (context, localeSnapshot) {
                  // Access localization inside StreamBuilder to get updated translations
                  final updatedLocalization = context.localizations;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: Dimens.paddingX3),
                    padding: EdgeInsets.all(Dimens.paddingX3B),
                    decoration: boxDecorationRoundedWithShadow(
                      Dimens.radiusX3,
                      border: Border.all(color: AppPalettes.primaryColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Dimens.gapX1B,
                      children: [
                        TranslatedText(
                          text: "${updatedLocalization.request_details} :",
                          style: textTheme.headlineSmall,
                        ),
                        SizeBox.size,
                        getHelpDetails(
                          text: updatedLocalization.name,
                          desc: _helpRequest.name ?? "Not available",
                        ),
                        getHelpDetails(
                          text: updatedLocalization.location,
                          desc: _isValidAddress(_helpRequest.address) 
                              ? _helpRequest.address! 
                              : "Not available",
                        ),
                        getHelpDetails(
                          text: updatedLocalization.category,
                          desc: _helpRequest.typeOfHelp?.name?.capitalize() ?? "Not available",
                        ),
                        getHelpDetails(
                          text: updatedLocalization.description,
                          desc: _helpRequest.description ?? "Not available",
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: Container(
                  decoration: boxDecorationRoundedWithShadow(
                    Dimens.radiusX2,
                    border: BoxBorder.all(color: AppPalettes.primaryColor),
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: Dimens.paddingX3,
                    vertical: Dimens.paddingX3,
                  ),
                  child: provider.isLoading
                      ? Center(child: CustomAnimatedLoading())
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimens.paddingX4,
                          ),
                          shrinkWrap: false,
                          reverse: true,
                          separatorBuilder: (_, _) => SizeBox.sizeHX4,
                          itemBuilder: (context, index) {
                            final message = provider.messages[index];
                            bool showMessage = false;
                            if (message == provider.messages.last) {
                              showMessage = true;
                            } else {
                              showMessage =
                                  provider.messages[index + 1].date
                                      ?.toWhatsAppRelativeTime() !=
                                  provider.messages[index].date
                                      ?.toWhatsAppRelativeTime();
                            }
                            return Column(
                              crossAxisAlignment: message.isSent == true
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (showMessage)
                                  _buildDateHeader(
                                    message.date ?? "",
                                    textTheme,
                                  ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      Dimens.radiusX4,
                                    ),
                                    color: message.isSent == true
                                        ? AppPalettes.liteGreenColor
                                        : AppPalettes.backGroundColor,
                                  ),
                                  margin:
                                      EdgeInsets.symmetric(
                                        horizontal: Dimens.marginX2,
                                      ).copyWith(
                                        left: message.isSent == true
                                            ? Dimens.paddingX15
                                            : null,
                                        right: message.isSent != true
                                            ? Dimens.paddingX15
                                            : null,
                                      ),
                                  padding: message.isSent == true
                                      ? EdgeInsets.symmetric(
                                          horizontal: Dimens.paddingX5,
                                          vertical: Dimens.paddingX2,
                                        ).copyWith(right: Dimens.paddingX4)
                                      : EdgeInsets.symmetric(
                                          horizontal: Dimens.paddingX4,
                                          vertical: Dimens.paddingX2,
                                        ).copyWith(right: Dimens.paddingX5),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    spacing: Dimens.gap,
                                    children: [
                                      if (message.message != "")
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minWidth:
                                                message.documents?.isNotEmpty ==
                                                    true
                                                ? Dimens.screenWidth
                                                : Dimens.scale50,
                                          ),
                                          child: TranslatedText(
                                            text: message.message ?? "",
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: AppPalettes
                                                      .lightTextColor,
                                                ),
                                          ),
                                        ),
                                      if (message.message == "")
                                        SizeBox.sizeHX1,
                                      if (message.documents?.isNotEmpty == true)
                                        HandleChatContributeImagesUiWidget(
                                          documents: message.documents ?? [],
                                        ).verticalPadding(Dimens.paddingX1B),
                                      Text(
                                        (DateTime.tryParse(
                                                  message.date ?? "",
                                                ) ??
                                                DateTime.now())
                                            .add(
                                              Duration(hours: 5, minutes: 30),
                                            )
                                            .toString()
                                            .to12HourTime(),
                                        style: textTheme.labelMedium?.copyWith(
                                          color: AppPalettes.lightTextColor,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          itemCount: provider.messages.length,
                        ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  // Add padding when Hindi keyboard is visible to push input above keyboard
                  bottom: _isHindiKeyboardVisible 
                      ? (MediaQuery.of(context).size.height * 0.45).clamp(350.0, 550.0)
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
                            builder: (bottomSheetContext) => Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
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
                        controller: provider.messageController,
                        focus: _messageFocusNode,
                        maxLines: 1,
                        keyboardType: TextInputType.text,
                        enableSpeechInput: true,
                        disableHindiKeyboardOverlay: true, // Parent will handle keyboard display
                        suffixWidget: provider.multipleFiles.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(
                                  right: Dimens.paddingX2,
                                ),
                                child: Chip(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      Dimens.radiusX4,
                                    ),
                                    side: BorderSide(
                                      color: AppPalettes.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                  label: TranslatedText(
                                    text: "${provider.multipleFiles.length} ${localization.images}",
                                  ),
                                  onDeleted: () => provider.removefiles(),
                                ),
                              )
                            : null,
                      ),
                    ),

                    Consumer<ChatContributeHelpViewModel>(
                      builder: (context, value, _) {
                        return Container(
                          padding: EdgeInsets.all(Dimens.paddingX2B),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppPalettes.primaryColor,
                          ),
                          child: GestureDetector(
                            onTap: value.isLoading
                                ? () {}
                                : () {
                                    provider.replyMessage(
                                      financialID: _helpRequest.sId ?? ""
                                    );
                                  },
                            child: value.isLoading
                                ? SizedBox(
                                    width: Dimens.scaleX3,
                                    height: Dimens.scaleX3,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppPalettes.whiteColor,
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                      left: Dimens.paddingX1,
                                    ),
                                    child: Icon(
                                      Icons.send,
                                      size: Dimens.scaleX3,
                                      color: AppPalettes.whiteColor,
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
              if (_isHindiKeyboardVisible)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate responsive height: 45% of screen height, with min 350 and max 550
                      final screenHeight = MediaQuery.of(context).size.height;
                      final keyboardHeight = (screenHeight * 0.45).clamp(350.0, 550.0);
                      return SizedBox(
                        height: keyboardHeight,
                        child: Material(
                          elevation: 8,
                          child: HindiKeyboard(
                            controller: provider.messageController,
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
          ),
        );
      },
    );
  }

  Widget _buildDateHeader(String dateText, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: Dimens.paddingX2),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.paddingX3,
          vertical: Dimens.paddingX1B,
        ),
        decoration: BoxDecoration(
          color: AppPalettes.primaryColor.withOpacityExt(0.1),
          borderRadius: BorderRadius.circular(Dimens.radiusX4),
        ),
        child: TranslatedText(
          text: dateText.toWhatsAppRelativeTime(),
          style: textTheme.bodySmall?.copyWith(
            color: AppPalettes.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
