import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/utils/url_launcher.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/features/profile_tabs/view_model/emergency_contact_view_model.dart';
import 'package:provider/provider.dart';

class EmergencyContactsView extends StatelessWidget {
  const EmergencyContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return Scaffold(
      appBar: commonAppBar(
        title: localization.emergency_contacts,
        elevation: Dimens.elevation,
      ),
      body: SingleChildScrollView(
        child:
            Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: Dimens.paddingX2B),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.paddingX2B,
                    vertical: Dimens.paddingX2B,
                  ),
                  decoration: boxDecorationRoundedWithShadow(
                    Dimens.radiusX2,
                    spreadRadius: 2,
                    blurRadius: 2,
                    backgroundColor: AppPalettes.redColor.withOpacityExt(0.1),
                  ),
                  child: Row(
                    spacing: Dimens.gapX3,
                    children: [
                      Icon(
                        Icons.info,
                        color: AppPalettes.redColor.withOpacityExt(0.8),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localization.emergency_services,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppPalettes.redColor.withOpacityExt(0.8),
                              ),
                            ),
                            Text(
                              localization.emergency_services_info,
                              style: textTheme.labelMedium?.copyWith(
                                color: AppPalettes.redColor.withOpacityExt(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizeBox.sizeHX5,
                Consumer<EmergencyContactViewModel>(
                  builder: (context, value, _) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimens.paddingX2B,
                      ),
                      itemBuilder: (context, index) {
                        final data = value.emergencyContactsList[index];
                        return InkWell(
                          onTap: () => UrlLauncher().launchURl(),

                          onLongPress: () =>
                              UrlLauncher().launchTel(data.number),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimens.paddingX2,
                              vertical: Dimens.paddingX2,
                            ),
                            decoration: boxDecorationRoundedWithShadow(
                              Dimens.radiusX2,
                              spreadRadius: 2,
                              blurRadius: 2,
                              backgroundColor: AppPalettes.whiteColor,
                            ),
                            child: Row(
                              spacing: Dimens.gapX3,
                              children: [
                                CommonHelpers.buildIcons(
                                  path: data.icon,
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.title,
                                        style: textTheme.bodyMedium,
                                      ),
                                      Text(
                                        data.description,
                                        style: textTheme.labelMedium?.copyWith(
                                          color: AppPalettes.lightTextColor,
                                        ),
                                      ),
                                      Text(
                                        data.number,
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                CommonHelpers.buildIcons(
                                  path: AppImages.phoneEmgIcon,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => SizeBox.sizeHX5,
                      itemCount: value.emergencyContactsList.length,
                    );
                  },
                ),
                SizeBox.sizeHX5,
              ],
            ).symmetricPadding(
              horizontal: Dimens.paddingX3,
              vertical: Dimens.verticalspacing,
            ),
      ),
    );
  }
}
