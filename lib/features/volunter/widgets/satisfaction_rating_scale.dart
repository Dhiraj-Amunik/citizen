import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';

class SatisfactionRatingScale extends StatelessWidget {
  final int? selectedRating;
  final Function(int)? onRatingSelected;
  final String question;

  const SatisfactionRatingScale({
    super.key,
    this.selectedRating,
    this.onRatingSelected,
    this.question = "How satisfied are you with our customer service today?",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimens.paddingX4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(Dimens.radiusX4),
        border: Border.all(
          color: Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade900,
            ),
          ),
          SizeBox.sizeHX4,
          _buildRatingBar(context),
        ],
      ),
    );
  }

  Widget _buildRatingBar(BuildContext context) {
    final ratings = [
      _RatingItem(
        value: 1,
        emoji: '😞',
        label: 'Very Dissatisfied',
        color: Colors.orange.shade700,
      ),
      _RatingItem(
        value: 2,
        emoji: '😕',
        label: 'Dissatisfied',
        color: Colors.orange.shade600,
      ),
      _RatingItem(
        value: 3,
        emoji: '😐',
        label: 'Neutral',
        color: Colors.yellow.shade600,
      ),
      _RatingItem(
        value: 4,
        emoji: '🙂',
        label: 'Satisfied',
        color: Colors.green.shade400,
      ),
      _RatingItem(
        value: 5,
        emoji: '😊',
        label: 'Very Satisfied',
        color: Colors.green.shade600,
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ratings.map((rating) {
        final isSelected = selectedRating == rating.value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onRatingSelected?.call(rating.value),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              padding: EdgeInsets.symmetric(
                vertical: Dimens.paddingX2,
                horizontal: Dimens.paddingX1,
              ),
              decoration: BoxDecoration(
                color: isSelected ? rating.color : rating.color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(Dimens.radiusX2),
                border: Border.all(
                  color: isSelected ? rating.color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    rating.emoji,
                    style: TextStyle(fontSize: 24.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    rating.value.toString(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppPalettes.blackColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    rating.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppPalettes.blackColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RatingItem {
  final int value;
  final String emoji;
  final String label;
  final Color color;

  _RatingItem({
    required this.value,
    required this.emoji,
    required this.label,
    required this.color,
  });
}

