import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/dio/network_requester.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/string_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';
import 'package:inldsevak/features/events/services/events_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

class CommonHelpers {
  static Widget shimmer({double? radius}) {
    return Shimmer.fromColors(
      baseColor: AppPalettes.liteGreyColor,
      highlightColor: AppPalettes.whiteColor,
      child: Container(
        decoration: boxDecorationRoundedWithShadow(
          radius ?? 0,
          backgroundColor: AppPalettes.whiteColor,
        ),
      ),
    );
  }

  static Widget showInitials(
    String initials, {
    TextStyle? style,
    Color? color,
  }) {
    return Center(child: Text(getInitials(initials), style: style));
  }

  static Widget getCacheNetworkImage(
    String? image, {
    Widget? placeholder,
    BoxFit? fit,
  }) {
    return CachedNetworkImage(
      imageUrl: image ?? "",
      fit: fit ?? BoxFit.contain,
      progressIndicatorBuilder: (context, child, progress) {
        return shimmer();
      },
      errorWidget: (context, error, stackTrace) {
        return placeholder ??
            Container(
              color: AppPalettes.imageholderColor,
              child: Image.asset(
                AppImages.imagePlaceholder,
                fit: BoxFit.contain,
              ),
            );
      },
    );
  }

  static Widget buildIcons({
    required String path,
    double? iconSize,
    Function()? onTap,
    Color? iconColor,
    Color? color,
    Color? borderColor,
    double? padding,
    double? radius,
  }) {
    return InkWell(
      customBorder: const CircleBorder(),
      overlayColor: const WidgetStatePropertyAll(
        AppPalettes.iconBackgroundColor,
      ),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding ?? 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? Dimens.radius100),
          color: color,
          border: Border.all(
            width: 1,
            color: borderColor ?? AppPalettes.transparentColor,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: path.endsWith('.svg')
              ? SvgPicture.asset(
                  path,
                  height: iconSize,
                  colorFilter: iconColor == null
                      ? null
                      : ColorFilter.mode(iconColor, BlendMode.srcIn),
                )
              : Image.asset(path, height: iconSize, color: iconColor),
        ),
      ),
    );
  }

  static Widget buildStatus(
    String text, {
    required Color statusColor,
    double? opacity,
    Color? textColor,
    TextStyle? textStyle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX4,
        vertical: Dimens.paddingX,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX2,
        backgroundColor: statusColor.withOpacityExt(opacity ?? 0.2),
      ),
      child: TranslatedText(
        text: text,
        style: (textStyle ?? AppStyles.labelMedium).copyWith(
          fontWeight: FontWeight.w500,
          color: textColor ?? AppPalettes.blackColor,
        ),
      ),
    );
  }

  static Widget getRow(TextTheme style, {required String text, String? desc}) {
    return RichText(
      text: TextSpan(
        style: style.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppPalettes.blackColor,
        ),
        children: [
          TextSpan(text: text),
          TextSpan(text: " : "),
          TextSpan(
            text: desc,
            style: style.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppPalettes.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  static String getInitials(String name) {
    return name
        .split(" ")
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0])
        .join()
        .toUpperCase();
  }

  static Future shareURL(String url, {String? eventId}) async {
    if (url == "") {
      CommonSnackbar(text: "No link found").showToast();
      return;
    }
    // Call share event API if eventId is provided
    if (eventId != null && eventId.isNotEmpty) {
      try {
        final token = await SessionController.instance.getToken();
        if (token != null && token.isNotEmpty) {
          await EventsRepository().shareEvent(
            token: token,
            eventId: eventId,
          );
        }
      } catch (e) {
        debugPrint("Error calling share event API: $e");
        // Continue with sharing even if API call fails
      }
    }
    return SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));
  }

  static Future shareImageUsingLink({
    required String url,
    String? description,
  }) async {
    if (url.showDataNull) {
      try {
        final network = NetworkRequester();
        final temp = "${await getTempPath() ?? ""}/image.png";
        final link = url;
        if (temp != "/image.png") {
          final response = await network.download(url: link);
          if (response != null) {
            File file = File(temp);
            var raf = file.openSync(mode: FileMode.write);
            raf.writeFromSync(response);
            await raf.close();
            return SharePlus.instance.share(
              ShareParams(
                files: [XFile(temp)],
                text: description,
                subject: 'Lok Varta',
              ),
            );
          }
        }
      } catch (err) {
        CommonSnackbar(text: "Unable to Download Image").showToast();
        return SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));
      }
    } else {
      return CommonSnackbar(text: "No link found").showToast();
    }
  }

  static Future<void> shareWidgetAsImage({
    required GlobalKey widgetKey,
    String? text,
    String? subject,
  }) async {
    try {
      final RenderRepaintBoundary? boundary = widgetKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        CommonSnackbar(text: "Unable to capture widget").showToast();
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      if (byteData == null) {
        CommonSnackbar(text: "Failed to generate image").showToast();
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          'event_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${tempDir.path}/$fileName');

      // Write the image to file
      await file.writeAsBytes(pngBytes);

      // Share the image file
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: text,
          subject: subject ?? 'Event',
        ),
      );
    } catch (e) {
      CommonSnackbar(
        text: "Failed to share: ${e.toString()}",
      ).showToast();
    }
  }

  /// Converts regular text to Unicode Mathematical Bold characters for bold appearance
  static String _toBoldText(String text) {
    const Map<String, String> boldMap = {
      'A': '𝐀', 'B': '𝐁', 'C': '𝐂', 'D': '𝐃', 'E': '𝐄', 'F': '𝐅',
      'G': '𝐆', 'H': '𝐇', 'I': '𝐈', 'J': '𝐉', 'K': '𝐊', 'L': '𝐋',
      'M': '𝐌', 'N': '𝐍', 'O': '𝐎', 'P': '𝐏', 'Q': '𝐐', 'R': '𝐑',
      'S': '𝐒', 'T': '𝐓', 'U': '𝐔', 'V': '𝐕', 'W': '𝐖', 'X': '𝐗',
      'Y': '𝐘', 'Z': '𝐙',
      'a': '𝐚', 'b': '𝐛', 'c': '𝐜', 'd': '𝐝', 'e': '𝐞', 'f': '𝐟',
      'g': '𝐠', 'h': '𝐡', 'i': '𝐢', 'j': '𝐣', 'k': '𝐤', 'l': '𝐥',
      'm': '𝐦', 'n': '𝐧', 'o': '𝐨', 'p': '𝐩', 'q': '𝐪', 'r': '𝐫',
      's': '𝐬', 't': '𝐭', 'u': '𝐮', 'v': '𝐯', 'w': '𝐰', 'x': '𝐱',
      'y': '𝐲', 'z': '𝐳',
      '0': '𝟎', '1': '𝟏', '2': '𝟐', '3': '𝟑', '4': '𝟒',
      '5': '𝟓', '6': '𝟔', '7': '𝟕', '8': '𝟖', '9': '𝟗',
      ' ': ' ', ':': ':', '&': '&',
    };
    
    return text.split('').map((char) => boldMap[char] ?? char).join();
  }

  static Future<void> shareEventDetails({
    required String? title,
    String? description,
    String? dateAndTime,
    String? location,
    String? eventType,
    String? url,
    String? poster,
    String? eventId,
  }) async {
    try {
      // Call share event API if eventId is provided
      if (eventId != null && eventId.isNotEmpty) {
        try {
          final token = await SessionController.instance.getToken();
          if (token != null && token.isNotEmpty) {
            await EventsRepository().shareEvent(
              token: token,
              eventId: eventId,
            );
          }
        } catch (e) {
          debugPrint("Error calling share event API: $e");
          // Continue with sharing even if API call fails
        }
      }
      final StringBuffer shareText = StringBuffer();
      
      // Header with bold styling
      shareText.writeln('━━━━━━━━━━━━━━━━━━━━');
      shareText.writeln('📅 ${_toBoldText('EVENT DETAILS')}');
      shareText.writeln('━━━━━━━━━━━━━━━━━━━━');
      shareText.writeln('');
      
      if (title != null && title.isNotEmpty) {
        shareText.writeln('📌 ${_toBoldText('TITLE:')}');
        shareText.writeln(title);
        shareText.writeln('');
      }
      
      if (eventType != null && eventType.isNotEmpty) {
        shareText.writeln('🏷️ ${_toBoldText('TYPE:')}');
        shareText.writeln(eventType);
        shareText.writeln('');
      }
      
      if (dateAndTime != null && dateAndTime.isNotEmpty) {
        try {
          final formattedDateTime = dateAndTime.toDdMmmYyyyWithTime();
          shareText.writeln('📅 ${_toBoldText('DATE & TIME:')}');
          shareText.writeln(formattedDateTime);
          shareText.writeln('');
        } catch (e) {
          // If formatting fails, use the original string
          shareText.writeln('📅 ${_toBoldText('DATE & TIME:')}');
          shareText.writeln(dateAndTime);
          shareText.writeln('');
        }
      }
      
      if (location != null && location.isNotEmpty) {
        shareText.writeln('📍 ${_toBoldText('LOCATION:')}');
        shareText.writeln(location);
        shareText.writeln('');
      }
      
      if (description != null && description.isNotEmpty) {
        shareText.writeln('📝 ${_toBoldText('DESCRIPTION:')}');
        shareText.writeln(description);
        shareText.writeln('');
      }
      
      if (url != null && url.isNotEmpty) {
        shareText.writeln('🔗 ${_toBoldText('MORE INFO:')}');
        shareText.writeln(url);
      }
      
      // If poster URL is available, add as link in text
      if (poster != null && poster.isNotEmpty && poster.showDataNull) {
        // Resolve URL - handle both full URLs and relative paths
        String imageUrl = poster.trim();
        if (!imageUrl.startsWith('http')) {
          if (imageUrl.startsWith('/')) {
            imageUrl = "${URLs.baseURL}$imageUrl";
          } else {
            imageUrl = "${URLs.baseURL}/$imageUrl";
          }
        }
        
        shareText.writeln('');
        shareText.writeln('🖼️ ${_toBoldText('IMAGE:')}');
        shareText.writeln(imageUrl);
      }
      
      // Share text with image links
      await SharePlus.instance.share(
        ShareParams(
          text: shareText.toString(),
          subject: title ?? 'Event',
        ),
      );
    } catch (e) {
      CommonSnackbar(
        text: "Failed to share event details: ${e.toString()}",
      ).showToast();
    }
  }

  static Future<void> shareLokVartaDetails({
    required String? title,
    String? content,
    String? date,
    List<String>? images,
    String? url,
    String? eventId,
  }) async {
    try {
      // Call share event API if eventId is provided
      if (eventId != null && eventId.isNotEmpty) {
        try {
          final token = await SessionController.instance.getToken();
          if (token != null && token.isNotEmpty) {
            await EventsRepository().shareEvent(
              token: token,
              eventId: eventId,
            );
          }
        } catch (e) {
          debugPrint("Error calling share event API: $e");
          // Continue with sharing even if API call fails
        }
      }
      final StringBuffer shareText = StringBuffer();
      
      // Header with bold styling
      shareText.writeln('━━━━━━━━━━━━━━━━━━━━');
      shareText.writeln('📰 ${_toBoldText('LOK VARTA')}');
      shareText.writeln('━━━━━━━━━━━━━━━━━━━━');
      shareText.writeln('');
      
      if (title != null && title.isNotEmpty) {
        shareText.writeln(' ${_toBoldText('TITLE:')}');
        shareText.writeln(title);
        shareText.writeln('');
      }
      
      if (date != null && date.isNotEmpty) {
        try {
          final formattedDate = date.toDdMmYyyy();
          shareText.writeln(' ${_toBoldText('DATE:')}');
          shareText.writeln(formattedDate);
          shareText.writeln('');
        } catch (e) {
          shareText.writeln(' ${_toBoldText('DATE:')}');
          shareText.writeln(date);
          shareText.writeln('');
        }
      }
      
      if (content != null && content.isNotEmpty) {
        shareText.writeln(' ${_toBoldText('CONTENT:')}');
        shareText.writeln(content);
        shareText.writeln('');
      }
      
      if (url != null && url.isNotEmpty) {
        shareText.writeln(' ${_toBoldText('MORE INFO:')}');
        shareText.writeln(url);
      }
      
      // If images are available, add as links in text
      if (images != null && images.isNotEmpty) {
        // Filter out empty or invalid image URLs
        final validImages = images.where((img) => 
          img.trim().isNotEmpty && img.showDataNull
        ).toList();
        
        if (validImages.isNotEmpty) {
          shareText.writeln('');
          if (validImages.length == 1) {
            // Single image
            String imageUrl = validImages[0].trim();
            // Resolve URL - handle both full URLs and relative paths
            if (!imageUrl.startsWith('http')) {
              if (imageUrl.startsWith('/')) {
                imageUrl = "${URLs.baseURL}$imageUrl";
              } else {
                imageUrl = "${URLs.baseURL}/$imageUrl";
              }
            }
            shareText.writeln('🖼️ ${_toBoldText('IMAGE:')}');
            shareText.writeln(imageUrl);
          } else {
            // Multiple images
            shareText.writeln('🖼️ ${_toBoldText('IMAGES:')}');
            for (int i = 0; i < validImages.length; i++) {
              String imageUrl = validImages[i].trim();
              // Resolve URL - handle both full URLs and relative paths
              if (!imageUrl.startsWith('http')) {
                if (imageUrl.startsWith('/')) {
                  imageUrl = "${URLs.baseURL}$imageUrl";
                } else {
                  imageUrl = "${URLs.baseURL}/$imageUrl";
                }
              }
              shareText.writeln('${i + 1}. $imageUrl');
            }
          }
        }
      }
      
      // Share text with image links
      await SharePlus.instance.share(
        ShareParams(
          text: shareText.toString(),
          subject: title ?? 'Lok Varta',
        ),
      );
    } catch (e) {
      debugPrint("Error in shareLokVartaDetails: $e");
      CommonSnackbar(
        text: "Failed to share: ${e.toString().length > 50 ? e.toString().substring(0, 50) + '...' : e.toString()}",
      ).showToast();
    }
  }

  static Future<void> shareArticleDetails({
    required String? title,
    String? summary,
    String? date,
    String? url,
    String? eventId,
  }) async {
    try {
      // Call share event API if eventId is provided
      if (eventId != null && eventId.isNotEmpty) {
        try {
          final token = await SessionController.instance.getToken();
          if (token != null && token.isNotEmpty) {
            await EventsRepository().shareEvent(
              token: token,
              eventId: eventId,
            );
          }
        } catch (e) {
          debugPrint("Error calling share event API: $e");
          // Continue with sharing even if API call fails
        }
      }
      final StringBuffer shareText = StringBuffer();

      shareText.writeln('📰 Article Details');
      shareText.writeln('');

      if (title != null && title.isNotEmpty) {
        shareText.writeln('Title: $title');
      }

      if (date != null && date.isNotEmpty) {
        shareText.writeln('Date: $date');
      }

      if (summary != null && summary.isNotEmpty) {
        shareText.writeln('');
        shareText.writeln('Summary:');
        shareText.writeln(summary);
      }

      if (url != null && url.isNotEmpty) {
        shareText.writeln('');
        shareText.writeln('Read more: $url');
      }

      await SharePlus.instance.share(
        ShareParams(
          text: shareText.toString(),
          subject: title ?? 'Article',
        ),
      );
    } catch (e) {
      CommonSnackbar(
        text: "Failed to share article details: ${e.toString()}",
      ).showToast();
    }
  }
}
