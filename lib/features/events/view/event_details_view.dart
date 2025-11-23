import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/extensions/string_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_expanded_widget.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/events/model/request_details_event_model.dart';
import 'package:inldsevak/features/events/view_model/event_details_view_model.dart';
import 'package:inldsevak/features/events/widgets/event_info_container.dart';
import 'package:provider/provider.dart';

class EventDetailsView extends StatelessWidget {
  final RequestEventDetailsModel eventModel;
  const EventDetailsView({super.key, required this.eventModel});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    String? url;
    return ChangeNotifierProvider(
      create: (context) => EventDetailsViewModel(),
      builder: (contextP, _) {
        final provider = contextP.read<EventDetailsViewModel>();
        return Scaffold(
          appBar: commonAppBar(
            title: localization.event_details,

            action: [
              Consumer<EventDetailsViewModel>(
                builder: (contextP, value, _) {
                  if (value.showShareIcon) {
                    return CommonHelpers.buildIcons(
                      path: AppImages.shareIcon,
                      color: AppPalettes.primaryColor,
                      iconColor: AppPalettes.whiteColor,
                      padding: Dimens.paddingX3,
                      iconSize: Dimens.scaleX2B,
                      onTap: () {
                        final eventId = eventModel.eventId;
                        CommonHelpers.shareURL(url ?? "", eventId: eventId);
                      },
                    );
                  }
                  return SizedBox();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: Dimens.horizontalspacing,
                vertical: Dimens.paddingX2,
              ),
              child: FutureBuilder(
                future: provider.getEvents(eventModel: eventModel),
                builder: (context, snapshot) {
                  final event = snapshot.data;
                  url = event?.url;
                  provider.showShareIcon = url?.showDataNull ?? false;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 0.3.screenHeight),
                        Center(child: CustomAnimatedLoading()),
                      ],
                    );
                  }
                  if (event == null) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 0.3.screenHeight),
                        TranslatedText(text: localization.event_not_found),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      SizedBox(
                        height: Dimens.scaleX15,
                        width: Dimens.scaleX15,
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(
                            Dimens.radius100,
                          ),
                          child: CommonHelpers.getCacheNetworkImage(
                            event.poster,
                          ),
                        ),
                      ),
                      SizeBox.sizeHX2,
                      SizedBox(
                        width: 0.5.screenWidth,
                        child: TranslatedText(
                          text: event.title ?? "Unknown title",
                          style: textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizeBox.sizeHX1,
                      ReadMoreWidget(
                        text: event.description ?? "Unknown description",
                      ),
                      SizeBox.sizeHX4,
                      Column(
                        spacing: Dimens.gapX4,
                        children: [
                          EventInfoContainer(
                            icon: AppImages.calenderIcon,
                            text:
                                event.dateAndTime?.toDdMmmYyyy() ?? "00-00-0000",
                          ),
                          EventInfoContainer(
                            icon: AppImages.clockIcon,
                            text: event.dateAndTime?.to12HourTime() ?? "00:00  ",
                          ),
                          EventInfoContainer(
                            icon: AppImages.locationIcon,
                            text: event.location ?? localization.no_location_found,
                          ),
                          CommonExpandedWidget(
                            color: AppPalettes.liteGreyColor,

                            title: localization.view_poster,
                            childrenPadding: Dimens.paddingX3,
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimens.paddingX3,
                              vertical: Dimens.paddingX4,
                            ),
                            radius: Dimens.radiusX3,
                            svg: CommonHelpers.buildIcons(
                              color: AppPalettes.liteGreenColor,
                              path: AppImages.cameraIcon,
                              iconColor: AppPalettes.primaryColor,
                              iconSize: Dimens.scaleX2,
                              padding: Dimens.paddingX2B,
                            ),
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(
                                  Dimens.radiusX2,
                                ),
                                child: CommonHelpers.getCacheNetworkImage(
                                  event.poster,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
