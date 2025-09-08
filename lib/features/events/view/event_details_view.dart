import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_expanded_widget.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
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
    return ChangeNotifierProvider(
      create: (context) => EventDetailsViewModel(),
      builder: (contextP, _) {
        final provider = contextP.read<EventDetailsViewModel>();
        return Scaffold(
          appBar: commonAppBar(
            title: localization.event_details,
            elevation: Dimens.elevation,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: Dimens.horizontalspacing,
                vertical: Dimens.verticalspacing,
              ),
              child: FutureBuilder(
                future: provider.getEvents(eventModel: eventModel),
                builder: (context, snapshot) {
                  final event = snapshot.data;
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
                        Text("Event not Found !"),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      SizedBox(
                        height: Dimens.scaleX10,
                        width: Dimens.scaleX10,
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(
                            Dimens.radius100,
                          ),
                          child: CommonHelpers.getCacheNetworkImage(
                            event?.poster,
                          ),
                        ),
                      ),
                      Text(
                        event.title ?? "Unknown title",
                        style: textTheme.bodyMedium,
                      ),
                      // Text("Sambaralu 2024", style: textTheme.bodyMedium),
                      ReadMoreWidget(
                        text: event.description ?? "Unknown description",
                      ),
                      SizeBox.sizeHX4,
                      Column(
                        spacing: Dimens.gapX4,
                        children: [
                          EventInfoContainer(
                            icon: AppImages.calenderIcon,
                            text: event.createdAt?.toDdMmmYyyy() ?? "00-00-0000",
                          ),
                          EventInfoContainer(
                            icon: AppImages.clockIcon,
                            text: event.createdAt?.to12HourTime() ?? "00:00  ",
                          ),
                          EventInfoContainer(
                            icon: AppImages.locationIcon,
                            text: event.location ?? "No Location found",
                          ),
                          CommonExpandedWidget(
                            title: "View Poster",
                            childrenPadding: Dimens.paddingX3,
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimens.paddingX3,
                              vertical: Dimens.paddingX4,
                            ),
                            radius: Dimens.radiusX3,
                            svg: CommonHelpers.buildIcons(
                              color: AppPalettes.primaryColor.withOpacityExt(
                                0.2,
                              ),
                              path: AppImages.cameraIcon,
                              iconColor: AppPalettes.primaryColor,
                              iconSize: Dimens.scaleX2B,
                              padding: Dimens.paddingX2,
                            ),
                            children: [
                              CommonHelpers.getNetworkImage(
                                "https://www.postergully.com/cdn/shop/products/Coffee_Keeps_Me_Busy_Vintage-NGPS2104_Copy.jpg?v=1578633364",
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
