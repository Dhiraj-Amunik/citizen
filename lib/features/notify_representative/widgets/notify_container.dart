import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:inldsevak/core/extensions/string_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_lists_model.dart';

class NotifyContainer extends StatelessWidget {
  final NotifyRepresentative model;
  final Function? onDelete;
  const NotifyContainer({super.key, this.onDelete, required this.model});

  String _getLocationText(NotifyRepresentative model, dynamic localization) {
    // First check if location string is available and valid
    if (model.location != null && model.location!.isNotEmpty) {
      final locationTrimmed = model.location!.trim();
      // Handle case where location might be an object string representation
      if (locationTrimmed.startsWith('{') || locationTrimmed.startsWith('[')) {
        // If it's a JSON object/array string, construct from address fields
        return _buildLocationFromAddress(model, localization);
      }
      // If location is a valid string, use it directly
      return locationTrimmed;
    }
    
    // If location is null/empty, try to construct from address fields
    return _buildLocationFromAddress(model, localization);
  }

  String _buildLocationFromAddress(NotifyRepresentative model, dynamic localization) {
    final List<String> addressParts = [];
    final Set<String> seenParts = {}; // To prevent duplicates
    
    // Helper function to add non-duplicate parts
    void addIfNotDuplicate(String? value) {
      if (value != null && value.trim().isNotEmpty) {
        final trimmed = value.trim();
        // Check if we haven't seen this exact value before
        if (!seenParts.contains(trimmed.toLowerCase())) {
          addressParts.add(trimmed);
          seenParts.add(trimmed.toLowerCase());
        }
      }
    }
    
    addIfNotDuplicate(model.street);
    addIfNotDuplicate(model.village);
    addIfNotDuplicate(model.mandal);
    addIfNotDuplicate(model.district);
    addIfNotDuplicate(model.pincode);
    
    if (addressParts.isNotEmpty) {
      return addressParts.join(', ');
    }
    
    return localization.not_found;
  }

  String _getStatusText(NotifyRepresentative model) {
    String? statusText;
    
    // First check if status is directly provided from API
    if (model.status != null && model.status!.isNotEmpty) {
      statusText = model.status!;
    }
    // Check responses array for status
    else if (model.responses != null && model.responses!.isNotEmpty) {
      final latestResponse = model.responses!.last;
      if (latestResponse.status != null && latestResponse.status!.isNotEmpty) {
        statusText = latestResponse.status!;
      }
    }
    
    // Map "attending" to "seen"
    if (statusText != null && statusText.toLowerCase() == 'attending') {
      return "Seen";
    }
    
    // Return capitalized status if we have one
    if (statusText != null && statusText.isNotEmpty) {
      return statusText.capitalize();
    }
    
    // Fallback to checking isDeleted
    if (model.isDeleted == true) {
      return "Closed";
    }
    
    // Fallback to isActive logic
    return model.isActive == true ? "Pending" : "Completed";
  }

  Color _getStatusColor(NotifyRepresentative model) {
    // First check if status is directly provided from API
    if (model.status != null && model.status!.isNotEmpty) {
      final statusLower = model.status!.toLowerCase();
      if (statusLower == 'closed' || statusLower == 'rejected' || statusLower == 'cancelled') {
        return AppPalettes.redColor;
      } else if (statusLower == 'approved' || statusLower == 'completed' || statusLower == 'accepted') {
        return AppPalettes.greenColor;
      } else if (statusLower == 'pending' || statusLower == 'in-progress') {
        return AppPalettes.yellowColor;
      }
    }
    
    // Fallback to isDeleted
    if (model.isDeleted == true) {
      return AppPalettes.redColor;
    }
    
    // Check responses array for status
    if (model.responses != null && model.responses!.isNotEmpty) {
      final latestResponse = model.responses!.last;
      if (latestResponse.status != null && latestResponse.status!.isNotEmpty) {
        final statusLower = latestResponse.status!.toLowerCase();
        if (statusLower == 'closed' || statusLower == 'rejected' || statusLower == 'cancelled') {
          return AppPalettes.redColor;
        } else if (statusLower == 'approved' || statusLower == 'completed' || statusLower == 'accepted') {
          return AppPalettes.greenColor;
        } else if (statusLower == 'pending' || statusLower == 'in-progress') {
          return AppPalettes.yellowColor;
        }
      }
    }
    
    // Fallback to isActive logic
    return model.isActive == true
        ? AppPalettes.yellowColor
        : AppPalettes.greenColor;
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX3,
        vertical: Dimens.paddingX3,
      ),
      width: double.infinity,
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX3,
        border: Border.all(color: AppPalettes.primaryColor),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: Dimens.gapX2,
              runSpacing: Dimens.gapX1,
              alignment: WrapAlignment.end,
              children: [
                CommonHelpers.buildStatus(
                  model.dateAndTime?.toRelativeTime() ?? "",
                  statusColor: AppPalettes.liteBlueColor,
                ),
                CommonHelpers.buildStatus(
                  _getStatusText(model),
                  textColor: AppPalettes.blackColor,
                  statusColor: _getStatusColor(model),
                ),
              ],
            ),
          ),
          SizeBox.sizeHX1,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Dimens.gapX,
            children: [
              // Text(
              //   model.partyMember?.user?.name?.capitalize() ??
              //       localization.not_found,
              //   style: textTheme.bodySmall?.copyWith(
              //     color: AppPalettes.lightTextColor,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
              TranslatedText(
                text: model.title?.capitalize() ?? "Unknown Title",
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                spacing: Dimens.gapX1,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: Dimens.scaleX1B,
                    color: AppPalettes.blackColor,
                  ),
                  Expanded(
                    child: TranslatedText(
                      text: _getLocationText(model, localization),
                      style: textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              ReadMoreWidget(
                text: model.description.isNull(localization.not_found),
                style: AppStyles.bodySmall.copyWith(
                  color: AppPalettes.lightTextColor,
                ),
              ),
              SizeBox.sizeHX,
              if (model.documents != null && model.documents!.isNotEmpty)
                _DocumentPreviewGrid(documents: model.documents!),
            ],
          ),
          SizeBox.sizeHX3,
          if (onDelete != null)
            Row(
              spacing: Dimens.gapX2,
              children: [
                Expanded(
                  child: CommonButton(
                    onTap: onDelete,
                    color: AppPalettes.whiteColor,
                    borderColor: AppPalettes.primaryColor,
                    textColor: AppPalettes.primaryColor,
                    text: localization.delete,
                    height: 40,
                    padding: EdgeInsets.symmetric(vertical: Dimens.paddingX2),
                    radius: Dimens.radiusX2,
                  ),
                ),
                Expanded(
                  child: CommonButton(
                    onTap: () => RouteManager.pushNamed(
                      Routes.updateNotifyRepresentativePage,
                      arguments: model,
                    ),
                    text: localization.edit,
                    height: 40,
                    padding: EdgeInsets.symmetric(vertical: Dimens.paddingX2),
                    radius: Dimens.radiusX2,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DocumentPreviewGrid extends StatelessWidget {
  const _DocumentPreviewGrid({required this.documents});

  final List<String> documents;

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: Dimens.gapX1,
      runSpacing: Dimens.gapX1,
      children: documents.map((url) {
        final resolvedUrl = _resolveUrl(url);
        if (resolvedUrl == null) {
          return const SizedBox.shrink();
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(Dimens.radiusX2),
          child: CachedNetworkImage(
            imageUrl: resolvedUrl,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            placeholder: (context, _) => Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              color: AppPalettes.liteGreyColor,
              child: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 64,
              height: 64,
              color: AppPalettes.liteGreyColor,
              alignment: Alignment.center,
              child: Icon(
                Icons.broken_image_outlined,
                size: 20,
                color: AppPalettes.lightTextColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String? _resolveUrl(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http')) return trimmed;
    if (trimmed.startsWith('/')) return "${URLs.baseURL}$trimmed";
    return "${URLs.baseURL}/$trimmed";
  }
}

