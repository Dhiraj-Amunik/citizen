import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_search_dropdown.dart';
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

    return SliverAppBar(
      actionsPadding: EdgeInsets.zero,
      centerTitle: false,
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
      backgroundColor: AppPalettes.liteGreenColor,
      pinned: true,
      expandedHeight: 400.height(),
      collapsedHeight: 60.height(),
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