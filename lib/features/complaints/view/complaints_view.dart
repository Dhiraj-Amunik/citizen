import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart';
import 'package:inldsevak/features/complaints/model/thread_model.dart';
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:inldsevak/features/complaints/widgets/complaint_widget.dart';
import 'package:provider/provider.dart';

class ComplaintsView extends StatefulWidget {
  const ComplaintsView({super.key});

  @override
  State<ComplaintsView> createState() => _ComplaintsViewState();
}

class _ComplaintsViewState extends State<ComplaintsView> {
  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final localization = context.localizations;
    final bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;

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
                      hintText: 'Search...',
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
        thread: thread,
        onTap: () async {
          await RouteManager.pushNamed(
            Routes.threadComplaintPage,
            arguments: ThreadModel(
              threadID: thread.threadId,
              subject: thread.messages?.first.subject ?? "No Subject found !",
              complaintID: thread.sId,
            ),
          );
        },
      );
    },
  );
}
