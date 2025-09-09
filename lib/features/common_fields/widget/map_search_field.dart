import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_search_dropdown.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/common_fields/view_model/search_view_model.dart';
import 'package:provider/provider.dart';

class MapSearchField extends StatelessWidget {
  final String text;
  final String hintText;
  final SingleSelectController<Predictions?> searchController;
  const MapSearchField({super.key, required this.searchController, required this.text, required this.hintText});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Consumer<SearchViewModel>(
      builder: (context, value, _) {
        return CommonSearchDropDown<Predictions?>(
          onChanged: (place) {
            value.getLocationByPlaceID(place?.placeId ?? "");
          },
          future: (text) async {
            final data = await value.getSearchPlaces(text);
            return data;
          },
          isRequired: true,
          heading: text,
          hintText: hintText,
          items: value.searchplaces,
          controller: searchController,
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
                        (p1?.structuredFormatting?.mainText ?? "").toString(),
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
                    (p1?.description ?? "").toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
