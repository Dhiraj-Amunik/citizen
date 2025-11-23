import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/common_search_dropdown.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/core/widgets/form_common_child.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/nearest_member/model/nearest_members_model.dart';
import 'package:inldsevak/features/nearest_member/view_model/nearest_member_view_model.dart';

import 'package:provider/provider.dart';

class NearestMemberSilverAppbar extends StatefulWidget {
  final List<PartyMember> membersList;
  final bool isScrolled;
  final Set<Marker> markers;
  const NearestMemberSilverAppbar({
    super.key,
    required this.isScrolled,
    required this.membersList,
    required this.markers,
  });

  @override
  State<NearestMemberSilverAppbar> createState() =>
      _NearestMemberSilverAppbarState();
}

class _NearestMemberSilverAppbarState extends State<NearestMemberSilverAppbar> {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.read<NearestMemberViewModel>();
    final localization = context.localizations;
    final textTheme = context.textTheme;
    final collapsedHeightValue = 60.height();
    final navigatorContext = RouteManager.navigatorKey.currentContext;
    final bool canPop =
        navigatorContext != null ? Navigator.canPop(navigatorContext) : false;

    return SliverAppBar(
      actionsPadding: EdgeInsets.only(right: Dimens.horizontalspacing),
      centerTitle: false,
      leading: canPop
          ? Padding(
              padding: EdgeInsets.only(
                left: Dimens.horizontalspacing,
              ),
              child: Center(
                child: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppPalettes.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppPalettes.liteGreenColor.withOpacityExt(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(
                        RouteManager.navigatorKey.currentContext!,
                      ).pop(),
                      child: Center(
                        child: Icon(
                          Icons.chevron_left,
                          color: AppPalettes.blackColor,
                          size: 24.r,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      leadingWidth: canPop ? 60.r : 0,
      title: widget.isScrolled
          ? Text(
              localization.nearest_member,
              style: textTheme.headlineMedium?.copyWith(
                color: AppPalettes.blackColor,
              ),
            )
          : CommonSearchDropDown<Predictions?>(
              hintText: "Find Members",
              items: provider.searchplaces,
              controller: provider.searchController,
              future: (text) async {
                final data = await provider.getSearchPlaces(text);
                return data;
              },
              onChanged: (place) {
                provider.getLocationByPlaceID(place?.placeId ?? "");
              },
              listItemBuilder: (p0, p1, p2, onTap) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(Dimens.paddingX1B),
                      decoration: boxDecorationRoundedWithShadow(
                        Dimens.radius100,
                        backgroundColor: AppPalettes.liteGreyColor,
                      ),
                      child: Icon(
                        Icons.location_on_sharp,
                        color: AppPalettes.lightTextColor,
                        size: Dimens.scaleX2,
                      ),
                    ),
                    SizeBox.sizeWX3,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (p1?.structuredFormatting?.mainText ?? ""),
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                          ),
                          Text(
                            p1?.structuredFormatting?.secondaryText ?? "~~~",
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppPalettes.lightTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Divider(height: 10, color: AppPalettes.liteGreyColor),
                        ],
                      ),
                    ),
                  ],
                );
              },
              headerBuilder: (p0, p1, p2) {
                return Row(
                  children: [
                    SvgPicture.asset(AppImages.locationIcon),
                    SizeBox.sizeWX3,
                    Flexible(
                      child: Text(
                        (p1?.description ?? ""),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                );
              },
            ),
            
      actions: widget.isScrolled
          ? null
          : [
              CommonHelpers.buildIcons(
                path: AppImages.filterIcon,
                color: AppPalettes.whiteColor,
                iconSize: Dimens.scaleX2,
                padding: Dimens.paddingX3,
                radius: Dimens.radiusX3,
                iconColor: AppPalettes.blackColor ,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (modalContext) {
                      return ChangeNotifierProvider<NearestMemberViewModel>.value(
                        value: provider,
                        child: DraggableSheetWidget(
                          showClose: true,
                          size: 0.4,
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
                                      provider.clearDistance();
                                      provider.getMembers();
                                    },
                                    child: TranslatedText(
                                      text: 'Clear',
                                      style: modalContext.textTheme.bodyLarge?.copyWith(
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
                                      style: modalContext.textTheme.bodyLarge?.copyWith(
                                        color: AppPalettes.whiteColor,
                                      ),
                                    ),
                                    onTap: () {
                                      RouteManager.pop();
                                      provider.getMembers();
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
                                    style: modalContext.textTheme.headlineSmall,
                                  ),
                                ],
                              ),
                              SizeBox.sizeHX2,
                              Consumer<NearestMemberViewModel>(
                                builder: (_, provider, _) {
                                  return FormCommonChild(
                                    heading: 'Distance (${provider.radiusValue.round()} km)',
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Slider(
                                          value: provider.radiusValue,
                                          min: 0,
                                          max: 100,
                                          divisions: 100,
                                          label: '${provider.radiusValue.round()} km',
                                          onChanged: (value) {
                                            provider.setRadius(value);
                                          },
                                          activeColor: AppPalettes.primaryColor,
                                          inactiveColor: AppPalettes.liteGreyColor,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '0 km',
                                              style: modalContext.textTheme.bodySmall?.copyWith(
                                                color: AppPalettes.lightTextColor,
                                              ),
                                            ),
                                            Text(
                                              '100 km',
                                              style: modalContext.textTheme.bodySmall?.copyWith(
                                                color: AppPalettes.lightTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ).symmetricPadding(horizontal: Dimens.horizontalspacing),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
      backgroundColor: AppPalettes.liteGreenColor,
      pinned: true,
      expandedHeight: 400.height(),
      collapsedHeight: collapsedHeightValue >= kToolbarHeight
          ? collapsedHeightValue
          : kToolbarHeight,
      floating: true,
      snap: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Consumer<NearestMemberViewModel>(
          builder: (context, value, _) {
            return GoogleMap(
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              initialCameraPosition: value.cameraPosition,
              mapType: MapType.normal,
              compassEnabled: false,
              mapToolbarEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              rotateGesturesEnabled: false,
              onCameraMove: (position) async {
                value.cameraPosition = position;
              },
              onMapCreated: (GoogleMapController controller) =>
                  value.mapController.complete(controller),
              markers:widget.markers,
            );
          },
        ),
      ),
    );
  }
}