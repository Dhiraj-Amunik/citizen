import 'package:flutter/material.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';

class HoursSliderWidget extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  const HoursSliderWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 160,
  });

  @override
  Widget build(BuildContext context) {
    final hours = value.round();
    
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppPalettes.primaryColor,
        inactiveTrackColor: AppPalettes.liteGreyColor,
        thumbColor: AppPalettes.whiteColor,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
        ),
        overlayShape: const RoundSliderOverlayShape(
          overlayRadius: 20,
        ),
        trackHeight: 4,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: max.toInt(),
        label: "$hours hours",
        onChanged: onChanged,
      ),
    );
  }
}

