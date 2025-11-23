import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';

class ChoiceWidget extends StatefulWidget {
  final List<String> options;
  final String? initiallySelected;
  final ValueChanged<String?> onOptionSelected;

  const ChoiceWidget({
    super.key,
    required this.options,
    this.initiallySelected,
    required this.onOptionSelected,
  });

  @override
  State<ChoiceWidget> createState() => _ChoiceWidgetState();
}

class _ChoiceWidgetState extends State<ChoiceWidget> {
  late String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initiallySelected;
  }

  void _selectOption(String option) {
    setState(() {
      // Toggle selection - if already selected, deselect it
      _selectedOption = _selectedOption == option ? null : option;
    });
    widget.onOptionSelected(_selectedOption);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: Dimens.gapX1B,
      spacing: Dimens.gapX4,
      alignment: WrapAlignment.start,
      children: List.generate(widget.options.length, (i) {
        return _buildRadioOption(
          context: context,
          isSelected: _selectedOption == widget.options[i],
          label: widget.options[i],
          onTap: () => _selectOption(widget.options[i]),
        );
      }).toList(),
    );
  }
}

Widget _buildRadioOption({
  required BuildContext context,
  required bool isSelected,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.center,
          width: 18.w,
          height: 18.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? AppPalettes.primaryColor
                  : AppPalettes.greyColor,
              width: 2.w,
            ),
          ),
          child: isSelected
              ? Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppPalettes.primaryColor,
                  ),
                )
              : null,
        ),
        8.horizontalSpace,
        TranslatedText(text: label, style: context.textTheme.labelMedium),
      ],
    ),
  );
}
