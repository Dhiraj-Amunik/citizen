import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/string_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;

class UserCardHelpWidget extends StatelessWidget {
  final model.FinancialRequest help;
  const UserCardHelpWidget({super.key, required this.help});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX4,
        vertical: Dimens.paddingX4,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX4,
        blurRadius: 2,
        spreadRadius: 2,
        border: Border.all(color: AppPalettes.primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Dimens.gapX1,
        children: [
          Column(
            spacing: Dimens.gapX1,
            children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Dimens.gapX2,
            children: [
              _buildAvatar(textTheme),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Dimens.gapX1,
                      children: [
                        Row(
                  children: [
                            Expanded(
                              child: TranslatedText(
                                text: help.name.isNull(localization.not_found),
                                disableTranslation: true,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                      ),
                                maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                            ),
                            // Don't show status if it's "approved"
                            if (help.status?.toLowerCase() != "approved") ...[
                              SizeBox.sizeWX2,
                              CommonHelpers.buildStatus(
                                _getStatusText(help.status, localization),
                                textColor: AppPalettes.blackColor,
                                statusColor: help.status == "rejected"
                                    ? AppPalettes.liteRedColor
                                    : help.status == "pending"
                                    ? AppPalettes.liteOrangeColor
                                    : help.status == "closed"
                                    ? AppPalettes.liteGreyColor
                                    : AppPalettes.yellowColor,
                              ),
                            ],
                          ],
                        ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Dimens.gapX1B,
                      children: [
                           Row(
                          spacing: Dimens.gapX1,
                      children: [
                        CommonHelpers.buildIcons(
                          path: AppImages.calenderIcon,
                          iconSize: Dimens.scaleX1B,
                              iconColor: AppPalettes.blackColor,
                        ),
                        TranslatedText(
                              text: help.createdAt?.toDdMmmYyyy() ?? "",
                              style: textTheme.labelMedium?.copyWith(
                                color: AppPalettes.lightTextColor,
                              ),
                        ),
                      ],
                    ),
                      ],
                    ),
                  ],
                ),
                  ),
                ],
              ),
            ],
          ),
             Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TranslatedText(
                              text: 'Requested : ',
                              style: textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppPalettes.blackColor,
                              ),
                            ),
                            Expanded(
                              child: ReadMoreWidget(
                                text: (help.typeOfHelp?.name ?? ""),
                                style: AppStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppPalettes.lightTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TranslatedText(
                              text: 'Description : ',
                              style: textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppPalettes.blackColor,
                              ),
                            ),
                            Expanded(
                              child: ReadMoreWidget(
                                text: help.description.isNull(localization.not_found),
                                style: AppStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppPalettes.lightTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
        ],
      ),
    );
  }

  Widget _buildAvatar(TextTheme textTheme) {
    final avatarUrl = _resolveAvatarUrl();
    final fallbackText = help.title?.trim().isNotEmpty == true
        ? help.title!.trim()
        : help.name ?? "";
    final double radius = Dimens.scaleX3;

    // Check if avatarUrl is not null and not empty to prevent invalid URL errors
    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
        onBackgroundImageError: (_, __) {},
      );
    }

    return _InitialsAvatar(
      text: fallbackText,
      radius: radius,
      textTheme: textTheme,
    );
  }

  String? _resolveAvatarUrl() {
    String? candidate = help.partyMember?.user?.avatar;
    if (!(candidate.showDataNull)) {
      final docs = help.documents;
      if (docs != null && docs.isNotEmpty && docs.first.showDataNull) {
        candidate = docs.first;
      }
    }
    if (!(candidate.showDataNull)) return null;

    final trimmed = candidate!.trim();
    if (trimmed.startsWith('http')) return trimmed;
    if (trimmed.startsWith('/')) return "${URLs.baseURL}$trimmed";
    return "${URLs.baseURL}/$trimmed";
  }

  String _getStatusText(String? status, dynamic localization) {
    if (status == null || status.isEmpty) {
      return localization.not_found;
    }
    final rawStatus = status.trim().toLowerCase();
    if (rawStatus == 'approved') {
      return 'Approved';
    }
    if (rawStatus == 'closed') {
      return 'Solved';
    }
    return status.capitalize();
  }
}

/// Widget that displays initials from text, translating it first if needed
class _InitialsAvatar extends StatefulWidget {
  final String text;
  final double radius;
  final TextTheme textTheme;

  const _InitialsAvatar({
    required this.text,
    required this.radius,
    required this.textTheme,
  });

  @override
  State<_InitialsAvatar> createState() => _InitialsAvatarState();
}

class _InitialsAvatarState extends State<_InitialsAvatar> {
  String _initials = "A";
  StreamSubscription<dynamic>? _languageSubscription;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    _updateInitials();
    // Listen to language changes for instant retranslation
    _languageSubscription = GeneralStream.instance.language.listen((_) {
      if (mounted) {
        _updateInitials();
      }
    });
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(_InitialsAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _updateInitials();
    }
  }

  Future<void> _updateInitials() async {
    if (widget.text.isEmpty) {
      setState(() {
        _initials = "A";
        _isTranslating = false;
      });
      return;
    }

    // Check if translation is needed
    final needsTranslation = TranslationHelper.needsTranslation(widget.text);
    
    if (!needsTranslation) {
      // No translation needed, extract initials directly
      setState(() {
        _initials = CommonHelpers.getInitials(widget.text);
        _isTranslating = false;
      });
      return;
    }

    // Translation is needed
    setState(() {
      _isTranslating = true;
    });

    try {
      final translated = await TranslationHelper.translateText(widget.text);
      if (mounted) {
        setState(() {
          _initials = CommonHelpers.getInitials(translated);
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initials = CommonHelpers.getInitials(widget.text);
          _isTranslating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: AppPalettes.primaryColor.withOpacityExt(0.1),
      child: _isTranslating
          ? SizedBox(
              width: widget.radius * 0.6,
              height: widget.radius * 0.6,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppPalettes.primaryColor,
                ),
              ),
            )
          : Text(
              _initials,
              style: widget.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPalettes.primaryColor,
              ),
            ),
    );
  }
}
