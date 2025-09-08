import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';

class ProfilPicWidget extends StatelessWidget {
  final Function() onEditTap;
  final Function() onRemoveTap;
  final File? imageFile;
  const ProfilPicWidget({
    super.key,
    required this.onEditTap,
    required this.onRemoveTap,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Stack(
            children: [
              Container(
                width: constraints.maxWidth * 0.35,
                height: constraints.maxWidth * 0.35,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: AppPalettes.blackColor.withOpacityExt(0.1),
                  ),
                  borderRadius: BorderRadius.circular(Dimens.radius100),
                ),
                child: imageFile == null
                    ? GestureDetector(
                        onTap: onEditTap,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimens.radius100),
                          child:
                              SvgPicture.asset(
                                AppImages.userProfileIcon,
                                colorFilter: const ColorFilter.mode(
                                  AppPalettes.greyColor,
                                  BlendMode.srcIn,
                                ),
                                fit: BoxFit.cover,
                              ).onlyPadding(
                                top: Dimens.paddingX4,
                                left: Dimens.paddingX2,
                                right: Dimens.paddingX2,
                              ),
                        ),
                      )
                    : GestureDetector(
                        onTap: imageFile == null ? onEditTap : null,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimens.radius100),
                          child: Image.file(imageFile!, fit: BoxFit.cover),
                        ),
                      ),
              ),
              Positioned(
                bottom: 6,
                right: 6,
                child: GestureDetector(
                  onTap: imageFile == null ? onEditTap : onRemoveTap,
                  child: CircleAvatar(
                    backgroundColor: AppPalettes.primaryColor,
                    radius: 14,
                    child: Icon(
                      imageFile == null ? Icons.edit : Icons.delete,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
