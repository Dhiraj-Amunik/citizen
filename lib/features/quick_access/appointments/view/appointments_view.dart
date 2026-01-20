import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/core/widgets/form_common_child.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/quick_access/appointments/viewmodel/appointments_view_model.dart';
import 'package:inldsevak/features/quick_access/appointments/widget/appointment_card.dart';
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:provider/provider.dart';

class AppointmentsView extends StatefulWidget {
  const AppointmentsView({super.key});

  @override
  State<AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends State<AppointmentsView> {
  DateTime? _lastRefreshTime;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    // Always reload appointments when view is opened to get latest status changes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AppointmentsViewModel>();
      // Always reload appointments list to ensure status changes are reflected
      await provider.getAppointmentsList();
      // Always call complaints list API when landing on appointments view
      context.read<ComplaintsViewModel>().getComplaints();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh appointments and complaints when returning to this route (e.g., after navigating back)
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      // Skip the initial load since initState() already handles it
      if (_isInitialLoad) {
        _isInitialLoad = false;
        _lastRefreshTime = DateTime.now();
        return;
      }
      
      final now = DateTime.now();
      // Only refresh if it's been more than 1 second since last refresh
      // This prevents excessive refreshes while allowing refresh on return
      if (_lastRefreshTime == null || 
          now.difference(_lastRefreshTime!) > const Duration(seconds: 1)) {
        _lastRefreshTime = now;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Reload appointments list to get latest status changes
            final provider = context.read<AppointmentsViewModel>();
            provider.getAppointmentsList();
            // Also refresh complaints
            context.read<ComplaintsViewModel>().getComplaints();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final SingleSelectController<String> searchController =
        SingleSelectController<String>(null);
    final localization = context.localizations;
    final textTheme = context.textTheme;
    final provider = context.read<AppointmentsViewModel>();
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          provider.searchController.clear();
          provider.statusKey = null;
          provider.dateKey = null;
          provider.filterList();
        }
      },
      child: Scaffold(
      appBar: commonAppBar(title: localization.appointments),
      body: RefreshIndicator(
        onRefresh: () => provider.getAppointmentsList(),
        color: AppPalettes.primaryColor,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.horizontalspacing,
            vertical: Dimens.paddingX2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Dimens.gapX4,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.paddingX3,
                  vertical: Dimens.paddingX3,
                ),
                decoration: boxDecorationRoundedWithShadow(
                  backgroundColor: AppPalettes.greenColor.withOpacityExt(0.2),
                  Dimens.radiusX5,
                  spreadRadius: 2,
                  blurRadius: 2,
                ),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          localization.appointments,
                          style: textTheme.bodyMedium,
                        ),
                        SizedBox(height: Dimens.gapX2),
                        Row(
                          children: [
                            Expanded(
                              child: TranslatedText(
                                text: "Beyond politics, we build trust and support. With the Appointments, you are never alone assistance is always near.",
                                style: textTheme.labelMedium?.copyWith(
                                  color: AppPalettes.lightTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizeBox.sizeHX8,
                      ],
                    ).onlyPadding(bottom: Dimens.paddingX2),
                    CommonButton(
                      fullWidth: false,
                      height: 30,
                      padding: EdgeInsets.symmetric(
                        vertical: Dimens.paddingX1,
                        horizontal: Dimens.paddingX3,
                      ),
                      onTap: () =>
                          RouteManager.pushNamed(Routes.requestAppointmentPage),
                      text: localization.request_appointment,
                      color: AppPalettes.buttonColor,
                    ),
                  ],
                ),
              ),
              Text(
                localization.appointment_list,
                style: textTheme.headlineSmall,
              ),
              Row(
                spacing: Dimens.gapX2,
                children: [
                  Expanded(
                    child: FormTextFormField(
                      hintText: localization.search,
                      suffixIcon: AppImages.searchIcon,
                      controller: provider.searchController,
                      borderColor: AppPalettes.primaryColor,
                      fillColor: AppPalettes.whiteColor,
                      onChanged: (text) {
                        provider.filterList();
                      },
                    ),
                  ),
                  
                  CommonHelpers.buildIcons(
                    path: AppImages.filterIcon,
                    color: AppPalettes.primaryColor,
                    iconSize: Dimens.scaleX2B,
                    padding: Dimens.paddingX3,
                    radius: Dimens.radiusX3,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return DraggableSheetWidget(
                            showClose: true,
                            size: 0.5,
                            bottomChild: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: Dimens.paddingX4,
                                horizontal: Dimens.paddingX4,
                              ),
                              child: Row(
                                spacing: Dimens.gapX4,
                                children: [
                                  Expanded(
                                    child: CommonButton(
                                      height: 45,
                                      color: Colors.white,
                                      borderColor: AppPalettes.greenColor,
                                      textColor: AppPalettes.greenColor,
                                      onTap: () {
                                        RouteManager.pop();
                                        searchController.clear();
                                        provider.statusKey = null;
                                        provider.dateKey = null;
                                        provider.getAppointmentsList();
                                      },
                                      child: TranslatedText(
                                        text: 'Clear',
                                        style: context.textTheme.bodyLarge?.copyWith(
                                          color: AppPalettes.greenColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: CommonButton(
                                      height: 45,
                                      child: TranslatedText(
                                        text: 'Apply',
                                        style: context.textTheme.bodyLarge?.copyWith(
                                          color: AppPalettes.whiteColor,
                                        ),
                                      ),
                                      onTap: () {
                                        RouteManager.pop();
                                        provider.getAppointmentsList();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TranslatedText(
                                      text: 'Filters',
                                      style: context.textTheme.headlineSmall,
                                    ),
                                  ],
                                ),
                                SizeBox.sizeHX2,

                                Consumer<AppointmentsViewModel>(
                                  builder: (_, _, _) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: Dimens.gapX2,
                                      children: [
                                        FormCommonChild(
                                          heading: localization.status,
                                          child: Wrap(
                                            spacing: Dimens.gapX2,
                                            runSpacing: Dimens.gapX2,
                                            alignment: WrapAlignment.start,
                                            children: [
                                              ...List.generate(
                                                provider.statusItems.length,
                                                (index) {
                                                  final bool isSelected =
                                                      provider.statusKey ==
                                                      provider
                                                          .statusItems[index];
                                                  return CommonButton(
                                                    fullWidth: false,
                                                    borderColor: AppPalettes
                                                        .primaryColor,
                                                    textColor: isSelected
                                                        ? AppPalettes.whiteColor
                                                        : AppPalettes
                                                              .lightTextColor,
                                                    color: isSelected
                                                        ? AppPalettes
                                                              .primaryColor
                                                        : AppPalettes
                                                              .whiteColor,
                                                    radius: Dimens.radiusX3,

                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal:
                                                              Dimens.paddingX4,
                                                          vertical:
                                                              Dimens.paddingX1B,
                                                        ),
                                                    child: TranslatedText(
                                                      text: provider
                                                          .statusItems[index],
                                                      style: context.textTheme.labelMedium?.copyWith(
                                                        color: isSelected
                                                            ? AppPalettes.whiteColor
                                                            : AppPalettes.lightTextColor,
                                                      ),
                                                    ),
                                                    height: 33.height(),
                                                    onTap: () =>
                                                        provider.setStatus(
                                                          provider
                                                              .statusItems[index],
                                                        ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        FormCommonChild(
                                          heading: localization.date,
                                          child: Wrap(
                                            spacing: Dimens.gapX2,
                                            runSpacing: Dimens.gapX2,
                                            alignment: WrapAlignment.start,
                                            children: [
                                              ...List.generate(
                                                provider.dateItems.length,
                                                (index) {
                                                  final bool isSelected =
                                                      provider.dateKey ==
                                                      provider.dateItems[index];
                                                  return CommonButton(
                                                    fullWidth: false,
                                                    borderColor: AppPalettes
                                                        .primaryColor,
                                                    textColor: isSelected
                                                        ? AppPalettes.whiteColor
                                                        : AppPalettes
                                                              .lightTextColor,
                                                    color: isSelected
                                                        ? AppPalettes
                                                              .primaryColor
                                                        : AppPalettes
                                                              .whiteColor,
                                                    radius: Dimens.radiusX3,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal:
                                                              Dimens.paddingX4,
                                                          vertical:
                                                              Dimens.paddingX1B,
                                                        ),
                                                    child: TranslatedText(
                                                      text: provider
                                                          .dateItems[index],
                                                      style: context.textTheme.labelMedium?.copyWith(
                                                        color: isSelected
                                                            ? AppPalettes.whiteColor
                                                            : AppPalettes.lightTextColor,
                                                      ),
                                                    ),
                                                    height: 33.height(),
                                                    onTap: () =>
                                                        provider.setDate(
                                                          provider
                                                              .dateItems[index],
                                                        ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ).symmetricPadding(horizontal: Dimens.horizontalspacing),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              Expanded(
                child: Consumer<AppointmentsViewModel>(
                  builder: (context, value, _) {
                    // Show loading only if initial load hasn't completed
                    if (provider.isLoading && !provider.hasInitialLoadCompleted) {
                      return Center(child: CustomAnimatedLoading());
                    }

                    // Show empty state only if initial load has completed and list is empty
                    if (provider.hasInitialLoadCompleted && value.filteredAppointmentsList.isEmpty) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: Dimens.paddingX4,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CommonHelpers.buildIcons(
                                        path: AppImages.placeholderEmpty,
                                        iconSize: constraints.maxHeight < 200
                                            ? 0.2.screenWidth
                                            : 0.3.screenWidth,
                                      ),
                                      SizedBox(height: Dimens.gapX2),
                                      TranslatedText(
                                        text: "No Appointments found",
                                        style: textTheme.titleSmall,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    
                    // Show list if we have data or if still loading (preserve existing data during refresh)
                    if (value.filteredAppointmentsList.isNotEmpty || !provider.hasInitialLoadCompleted) {
                      return ListView.separated(
                        itemBuilder: (_, index) {
                          return GestureDetector(
                            onTap: () {
                              RouteManager.pushNamed(
                                Routes.appointmentDetailsPage,
                                arguments: value.filteredAppointmentsList[index],
                              );
                            },
                            child: AppointmentCard(
                              appointment: value.filteredAppointmentsList[index],
                            ),
                          );
                        },
                        separatorBuilder: (_, _) => SizeBox.widgetSpacing,
                        itemCount: value.filteredAppointmentsList.length,
                      );
                    }
                    
                    // Fallback to empty state
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: Dimens.paddingX4,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CommonHelpers.buildIcons(
                                      path: AppImages.placeholderEmpty,
                                      iconSize: constraints.maxHeight < 200
                                          ? 0.2.screenWidth
                                          : 0.3.screenWidth,
                                    ),
                                    SizedBox(height: Dimens.gapX2),
                                    TranslatedText(
                                      text: "No Appointments found",
                                      style: textTheme.titleSmall,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
