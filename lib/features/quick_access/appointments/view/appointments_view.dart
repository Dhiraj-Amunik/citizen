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
import 'package:inldsevak/features/quick_access/appointments/viewmodel/appointments_view_model.dart';
import 'package:inldsevak/features/quick_access/appointments/widget/appointment_card.dart';
import 'package:provider/provider.dart';

class AppointmentsView extends StatelessWidget {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SingleSelectController<String> searchController =
        SingleSelectController<String>(null);
    final localization = context.localizations;
    final textTheme = context.textTheme;
    final provider = context.read<AppointmentsViewModel>();
    return Scaffold(
      appBar: commonAppBar(title: localization.appointments),
      body: RefreshIndicator(
        onRefresh: () => provider.getAppointmentsList(),
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
                        Text(
                          "Beyond politics, we build trust and support. With the Appointments, you are never alone assistance is always near.",
                          style: textTheme.labelMedium?.copyWith(
                            color: AppPalettes.lightTextColor,
                          ),
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
                      hintText: 'Search...',
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
                                      text: 'Clear',
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
                                    ),
                                  ),
                                  Expanded(
                                    child: CommonButton(
                                      height: 45,
                                      text: 'Apply',
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
                                    Text(
                                      'Filters',
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
                                          heading: "Status",
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
                                                    text: provider
                                                        .statusItems[index],
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
                                          heading: "Date",
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
                                                    text: provider
                                                        .dateItems[index],
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
                    if (provider.isLoading) {
                      return Center(child: CustomAnimatedLoading());
                    }

                    if (value.filteredAppointmentsList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CommonHelpers.buildIcons(
                              path: AppImages.placeholderEmpty,
                              iconSize: 0.3.screenWidth,
                            ),
                            Text(
                              "No Appointments found",
                              style: textTheme.titleSmall,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                            SizeBox.sizeHX6,
                          ],
                        ),
                      );
                    }
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
