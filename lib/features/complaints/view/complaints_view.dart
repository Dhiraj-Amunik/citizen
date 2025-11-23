import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/commom_text_form_field.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/form_common_child.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart';
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:inldsevak/features/complaints/widgets/complaint_widget.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_departments_model.dart'
    as departments;

class ComplaintsView extends StatefulWidget {
  const ComplaintsView({super.key});

  @override
  State<ComplaintsView> createState() => _ComplaintsViewState();
}

class _ComplaintsViewState extends State<ComplaintsView>
    with DateAndTimePicker {
  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final localization = context.localizations;
    final bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    final provider = context.read<ComplaintsViewModel>();
    return Scaffold(
      appBar: commonAppBar(
        appBarHeight: 110,
        title: localization.my_complaints,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child:
              Row(
                spacing: Dimens.gapX2,
                children: [
                  Expanded(
                    child: FormTextFormField(
                      hintText: localization.search,
                      suffixIcon: AppImages.searchIcon,
                      controller: context
                          .read<ComplaintsViewModel>()
                          .searchController,
                      borderColor: AppPalettes.primaryColor,
                      fillColor: AppPalettes.whiteColor,
                      onChanged: (text) {
                        context.read<ComplaintsViewModel>().filterList();
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
                            size: 0.65,
                            bottomChild: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimens.paddingX6,
                              ).copyWith(bottom: Dimens.paddingX6),
                              child: Row(
                                spacing: Dimens.gapX3,
                                children: [
                                  Expanded(
                                    child: CommonButton(
                                      height: 45,
                                      color: AppPalettes.whiteColor,
                                      borderColor: AppPalettes.primaryColor,
                                      textColor: AppPalettes.primaryColor,
                                      onTap: () {
                                        RouteManager.pop();
                                        provider.selectedStatusList = [];
                                        provider.departmentKey = null;
                                        provider.fromDate.clear();
                                        provider.toDate.clear();
                                        provider.fromDateCompany = null;
                                        provider.toDateCompany = null;
                                      provider.getComplaints();
                                      },
                                      child: TranslatedText(
                                        text: 'Clear',
                                        style: context.textTheme.bodyLarge?.copyWith(
                                          color: AppPalettes.primaryColor,
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
                                        provider.getComplaints();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: Dimens.gapX3,
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

                                Consumer<ComplaintsViewModel>(
                                  builder: (context, _, _) {
                                    final textTheme = context.textTheme;
                                    return FormCommonChild(
                                      heading: localization.status,
                                      child: Wrap(
                                        spacing: Dimens.gapX2,
                                        runSpacing: Dimens.gapX2,
                                        alignment: WrapAlignment.start,
                                        children: [
                                          ...List.generate(
                                            provider.complaintFilterList.length,
                                            (index) {
                                              final bool isSelected = provider
                                                  .selectedStatusList!
                                                  .any(
                                                    (status) =>
                                                        status ==
                                                        provider
                                                            .complaintFilterList[index],
                                                  );
                                              return CommonButton(
                                                fullWidth: false,
                                                borderColor:
                                                    AppPalettes.primaryColor,
                                                textColor: isSelected
                                                    ? AppPalettes.whiteColor
                                                    : AppPalettes
                                                          .lightTextColor,
                                                color: isSelected
                                                    ? AppPalettes.primaryColor
                                                    : AppPalettes.whiteColor,
                                                radius: Dimens.radiusX3,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: Dimens.paddingX4,
                                                  vertical: Dimens.paddingX1B,
                                                ),
                                                height: 33.height(),
                                                onTap: () => provider.setStatus(
                                                  provider
                                                      .complaintFilterList[index],
                                                ),
                                                child: TranslatedText(
                                                  text: provider
                                                      .complaintFilterList[index],
                                                  style: textTheme.labelMedium?.copyWith(
                                                    color: isSelected
                                                        ? AppPalettes.whiteColor
                                                        : AppPalettes.lightTextColor,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                // MultiSelectDropDown<String>(
                                //   heading: "Status",
                                //   hintText: "Select Status",
                                //   initialItems: provider.selectedStatusList,
                                //   items: provider.complaintFilterList,
                                //   onListChanged: (items) {
                                //     provider.selectedStatusList = items;
                                //   },
                                // ),
                                FormCommonDropDown<departments.Data>(
                                  heading: localization.department,
                                  initialData: provider.departmentKey,
                                  hintText: localization.select_department,
                                  items: provider.departmentLists,
                                  listItemBuilder: (p0, department, p2, p3) {
                                    return TranslatedText(
                                      text: "${department.name}",
                                      style: context.textTheme.bodySmall,
                                    );
                                  },
                                  headerBuilder: (p0, department, p2) {
                                    return TranslatedText(
                                      text: "${department.name}",
                                      style: context.textTheme.bodySmall,
                                    );
                                  },
                                  onChanged: (value) {
                                    provider.departmentKey = value;
                                  },
                                ),

                                FormCommonChild(
                                  heading: localization.date,
                                  child: Column(
                                    children: [
                                      Row(
                                        spacing: Dimens.gapX2,
                                        children: [
                                          Expanded(
                                            child: CommonTextFormField(
                                              prefixIcon:
                                                  AppImages.calenderIcon,
                                              showCursor: false,
                                              keyboardType: TextInputType.none,
                                              controller: provider.fromDate,
                                              hintText: "From",
                                              onTap: () async {
                                                final date =
                                                    await customDatePicker(
                                                      endDate: DateTime.now(),
                                                      startDate: DateTime(
                                                        2025,
                                                        DateTime.september,
                                                      ),
                                                    );
                                                if (date != null) {
                                                  provider.fromDateCompany =
                                                      date
                                                          .toString()
                                                          .toYyyyMmDd();
                                                  provider.fromDate.text =
                                                      provider.fromDateCompany
                                                          ?.toDdMmYyyy() ??
                                                      "";
                                                }
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: CommonTextFormField(
                                              prefixIcon:
                                                  AppImages.calenderIcon,
                                              showCursor: false,
                                              keyboardType: TextInputType.none,
                                              controller: provider.toDate,
                                              hintText: "To",
                                              onTap: () async {
                                                final date =
                                                    await customDatePicker(
                                                      endDate: DateTime.now(),
                                                      startDate: DateTime(
                                                        2025,
                                                        DateTime.september,
                                                      ),
                                                    );
                                                if (date != null) {
                                                  provider.toDateCompany = date
                                                      .toString()
                                                      .toYyyyMmDd();
                                                  provider.toDate.text =
                                                      provider.toDateCompany
                                                          ?.toDdMmYyyy() ??
                                                      "";
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizeBox.sizeHX3,

                                      Row(
                                        spacing: Dimens.gapX2,
                                        children: [
                                          Expanded(
                                            child: CommonButton(
                                              borderColor:
                                                  AppPalettes.primaryColor,
                                              textColor:
                                                  AppPalettes.lightTextColor,
                                              color: AppPalettes.whiteColor,
                                              radius: Dimens.radiusX3,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: Dimens.paddingX2,
                                                vertical: Dimens.paddingX1B,
                                              ),
                                              height: 33.height(),
                                              onTap: () => provider
                                                  .determineSelectedFilter(
                                                    "today",
                                                  ),
                                              child: TranslatedText(
                                                text: "Today",
                                                style: context.textTheme.labelMedium?.copyWith(
                                                  color: AppPalettes.lightTextColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: CommonButton(
                                              borderColor:
                                                  AppPalettes.primaryColor,
                                              textColor:
                                                  AppPalettes.lightTextColor,
                                              color: AppPalettes.whiteColor,
                                              radius: Dimens.radiusX3,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: Dimens.paddingX2,
                                                vertical: Dimens.paddingX1B,
                                              ),
                                              height: 33.height(),
                                              onTap: () => provider
                                                  .determineSelectedFilter(
                                                    "week",
                                                  ),
                                              child: TranslatedText(
                                                text: "This Week",
                                                style: context.textTheme.labelMedium?.copyWith(
                                                  color: AppPalettes.lightTextColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: CommonButton(
                                              borderColor:
                                                  AppPalettes.primaryColor,
                                              textColor:
                                                  AppPalettes.lightTextColor,
                                              color: AppPalettes.whiteColor,
                                              radius: Dimens.radiusX3,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: Dimens.paddingX2,
                                                vertical: Dimens.paddingX1B,
                                              ),
                                              height: 33.height(),
                                              onTap: () => provider
                                                  .determineSelectedFilter(
                                                    "month",
                                                  ),
                                              child: TranslatedText(
                                                text: "This Month",
                                                style: context.textTheme.labelMedium?.copyWith(
                                                  color: AppPalettes.lightTextColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ).symmetricPadding(horizontal: Dimens.horizontalspacing),
                          );
                        },
                      );
                    },
                  ),
                ],
              ).symmetricPadding(
                horizontal: Dimens.horizontalspacing,
                vertical: Dimens.paddingX2,
              ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () => context.read<ComplaintsViewModel>().getComplaints(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimens.paddingX3,
                      ),
                      child: Consumer<ComplaintsViewModel>(
                        builder: (context, value, child) {
                          if (value.isLoading) {
                            return Column(
                              children: [
                                SizedBox(height: 0.3.screenHeight),
                                Center(child: CustomAnimatedLoading()),
                              ],
                            );
                          }
                          return buildComplaintsList(
                            value.filteredComplaintsList,
                          );
                        },
                      ),
                    ),
                    if (!canPop) SizeBox.sizeHX16,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: Visibility(
        visible: !keyboardIsOpen,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.horizontalspacing,
          ).copyWith(bottom: canPop ? null : Dimens.paddingX22),
          child: CommonButton(
            text: localization.raise_complaint,
            onTap: () => RouteManager.pushNamed(Routes.lodgeComplaintPage),
          ),
        ),
      ),
    );
  }
}

Widget buildComplaintsList(List<Data> complaintList) {
  if (complaintList.isEmpty) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: 0.3.screenHeight),
        Center(child: Text("No Complaints Found", style: AppStyles.bodyMedium)),
      ],
    );
  }

  return ListView.separated(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    padding: EdgeInsets.symmetric(
      horizontal: Dimens.paddingX2,
    ).copyWith(bottom: Dimens.paddingX25),
    separatorBuilder: (_, index) => SizeBox.widgetSpacing,
    itemCount: complaintList.length,
    itemBuilder: (context, index) {
      final thread = complaintList[index];
      return ComplaintThreadWidget(
        showCompaint: true,
        thread: thread,
        onTap: () async {
          await RouteManager.pushNamed(
            Routes.threadComplaintPage,
            arguments: thread,
          );
        },
      );
    },
  );
}
