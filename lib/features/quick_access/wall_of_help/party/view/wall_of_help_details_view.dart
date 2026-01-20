import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/core/widgets/responisve_image_widget.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/my_help_requests_view_model.dart';
import 'package:provider/provider.dart';

class WallOfHelpDetailsView extends StatefulWidget {
  final model.FinancialRequest helpRequest;
  final bool isEditable;
  const WallOfHelpDetailsView({
    super.key,
    required this.helpRequest,
    required this.isEditable,
  });

  @override
  State<WallOfHelpDetailsView> createState() => _WallOfHelpDetailsViewState();
}

class _WallOfHelpDetailsViewState extends State<WallOfHelpDetailsView> {
  late model.FinancialRequest _currentRequest;

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.helpRequest;
    // Check for updated data when view is resumed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateRequestData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update data when dependencies change (e.g., ViewModel updates)
    if (widget.isEditable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateRequestData();
      });
    }
  }

  void _updateRequestData() async {
    if (!widget.isEditable || !mounted) return;
    
    try {
      final viewModel = context.read<MyHelpRequestsViewModel>();
      
      // If list is empty or request not found, trigger a refresh first
      if (viewModel.myWallOFHelpLists.isEmpty || 
          !viewModel.myWallOFHelpLists.any((req) => req.sId == widget.helpRequest.sId)) {
        // Refresh the list to get updated data
        await viewModel.onRefresh();
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      // Find the updated request in the list by ID
      final updatedRequest = viewModel.myWallOFHelpLists.firstWhere(
        (request) => request.sId == widget.helpRequest.sId,
        orElse: () => _currentRequest,
      );
      
      if (updatedRequest.sId == null || updatedRequest.sId != widget.helpRequest.sId) {
        // Request not found or ID mismatch, keep current
        return;
      }
      
      // Always update if we found the request (even if fields appear unchanged)
      // This ensures we get the latest data from the server
      if (mounted) {
        setState(() {
          _currentRequest = updatedRequest;
        });
      }
    } catch (e) {
      // ViewModel not available, ignore
      debugPrint("Error updating request data: $e");
    }
  }

  bool _hasRequestChanged(model.FinancialRequest updated) {
    return updated.name != _currentRequest.name ||
        updated.address != _currentRequest.address ||
        updated.description != _currentRequest.description ||
        updated.amountRequested != _currentRequest.amountRequested ||
        updated.urgency != _currentRequest.urgency ||
        updated.typeOfHelp?.sId != _currentRequest.typeOfHelp?.sId ||
        updated.preferredWayForHelp?.sId != _currentRequest.preferredWayForHelp?.sId ||
        updated.uPI != _currentRequest.uPI ||
        updated.othersTypeOfHelp != _currentRequest.othersTypeOfHelp ||
        updated.othersWayForHelp != _currentRequest.othersWayForHelp ||
        (updated.documents?.length ?? 0) != (_currentRequest.documents?.length ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;
    final bool isFinancialHelp =
        [
          "Financial",
        ].contains(_currentRequest.preferredWayForHelp?.name?.split(" ")[0]) ==
        true;
    
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Update data when returning from edit screen
        if (didPop && widget.isEditable) {
          // Wait a bit to ensure ViewModel refresh is complete
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _updateRequestData();
            }
          });
        }
      },
      child: _buildScaffold(context, textTheme, localization, isFinancialHelp),
    );
  }
  Widget _buildScaffold(
    BuildContext context,
    TextTheme? textTheme,
    dynamic localization,
    bool isFinancialHelp,
  ) {
    return Scaffold(
      appBar: commonAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.horizontalspacing),
          child: Column(
            children: [
              SizedBox(
                width: 0.8.screenWidth,
                child: TranslatedText(
                  text: _currentRequest.typeOfHelp?.name?.capitalize() ?? "",
                  style: textTheme?.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              SizeBox.sizeHX,
              ReadMoreWidget(maxLines: 4, text: _currentRequest.description ?? ""),
              SizeBox.sizeHX2,

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.paddingX4,
                  vertical: Dimens.paddingX4,
                ),
                decoration: boxDecorationRoundedWithShadow(
                  Dimens.radiusX4,
                  backgroundColor: AppPalettes.liteGreenColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TranslatedText(
                      text: localization.urgency_level,
                      style: textTheme?.bodySmall?.copyWith(
                        color: AppPalettes.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                    ),
                    TranslatedText(
                      text: _currentRequest.urgency ?? "",
                      style: textTheme?.bodyMedium?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                    SizeBox.sizeHX1,
                    TranslatedText(
                      text: localization.preferred_way_to_receive_help,
                      style: textTheme?.bodySmall?.copyWith(
                        color: AppPalettes.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TranslatedText(
                      text: _currentRequest.preferredWayForHelp?.name ?? "",
                      style: textTheme?.bodyMedium?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                    SizeBox.sizeHX1,
                    TranslatedText(
                      text: localization.name,
                      style: textTheme?.bodySmall?.copyWith(
                        color: AppPalettes.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TranslatedText(
                      text: _currentRequest.name ?? "",
                      style: textTheme?.bodyMedium?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                    SizeBox.sizeHX1,

                    TranslatedText(
                      text: localization.address,
                      style: textTheme?.bodySmall?.copyWith(
                        color: AppPalettes.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TranslatedText(
                      text: _currentRequest.address ?? "",
                      style: textTheme?.bodyMedium?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                    SizeBox.sizeHX1,
                  ],
                ),
              ),
              SizeBox.sizeHX2,
              if (_currentRequest.documents?.isNotEmpty == true)
                Row(
                  children: [
                    Text(
                      localization.supporting_documents,
                      style: textTheme?.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              SizeBox.sizeHX2,
              if (_currentRequest.documents?.isNotEmpty == true)
                ResponisveImageWidget(images: _currentRequest.documents ?? []),
              SizeBox.sizeHX6,
            ],
          ),
        ),
      ),
      bottomNavigationBar: _currentRequest.status == "closed"
          ? SizedBox()
          : Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: Dimens.horizontalspacing,
                vertical: Dimens.verticalspacing,
              ),
              child: CommonButton(
                isEnable: _currentRequest.status == "rejected" ? false : true,
                disabledColor: AppPalettes.greyColor,
                color: _currentRequest.status == "rejected"
                    ? AppPalettes.greyColor
                    : null,
                text: widget.isEditable
                    ? localization.edit_details
                    : isFinancialHelp
                    ? localization.contribute
                    : localization.chat,
                onTap: () async {
                  final result = await RouteManager.pushNamed(
                    widget.isEditable
                        ? Routes.myHelpRequestEditPage
                        : isFinancialHelp
                        ? Routes.contributePage
                        : Routes.chatContributePage,
                    arguments: _currentRequest,
                  );
                  // Update data when returning from edit screen
                  // If result is true, it means update was successful
                  if (result == true || widget.isEditable) {
                    // Wait a bit for the ViewModel to finish refreshing
                    await Future.delayed(const Duration(milliseconds: 300));
                    _updateRequestData();
                  }
                },
              ),
            ),
    );
  }
}
