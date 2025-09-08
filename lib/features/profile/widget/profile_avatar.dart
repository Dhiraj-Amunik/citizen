import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';

class ProfileAvatar extends StatelessWidget with CupertinoDialogMixin {
  final File? file;
  final String? image;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProfileAvatar({
    super.key,
    this.image,
    this.onTap,
    this.onDelete,
    this.file,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(Dimens.paddingX1),
            width: Dimens.scaleX15,
            height: Dimens.scaleX15,
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: AppPalettes.backGroundColor),
              borderRadius: BorderRadius.circular(Dimens.radius100),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimens.radius100),
              child: file == null
                  ? CommonHelpers.getCacheNetworkImage(
                      image,
                      placeholder: GestureDetector(
                        onTap: onTap,
                        child:
                            SvgPicture.asset(
                              AppImages.userProfileIcon,
                              colorFilter: ColorFilter.mode(
                                AppPalettes.backGroundColor,
                                BlendMode.srcIn,
                              ),
                              fit: BoxFit.cover,
                            ).onlyPadding(
                              top: Dimens.paddingX2,
                              left: Dimens.paddingX2,
                              right: Dimens.paddingX2,
                            ),
                      ),
                    )
                  : ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.radius100),
                    child: Image.file(file!, fit: BoxFit.cover),
                  ),
            ),
          ),
          Positioned(
            bottom: Dimens.paddingX1B,
            right: Dimens.paddingX1B,
            child: GestureDetector(
              onTap: file == null ? onTap : onDelete,
              child: CircleAvatar(
                radius: Dimens.scaleX2,
                backgroundColor: file == null
                    ? AppPalettes.primaryColor
                    : AppPalettes.redColor,
                child: Icon(
                  file == null ? Icons.edit : Icons.delete,
                  size: Dimens.scaleX2,
                  color: AppPalettes.whiteColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
