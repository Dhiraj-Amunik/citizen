import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';

class AvailabilityOptionsWidgets extends StatefulWidget {
  final List<String> options;
  final String? initiallySelected;
  final ValueChanged<String?> onOptionSelected;

  const AvailabilityOptionsWidgets({
    super.key,
    required this.options,
    this.initiallySelected,
    required this.onOptionSelected,
  });

  @override
  State<AvailabilityOptionsWidgets> createState() => _AvailabilityOptionsWidgetsState();
}

class _AvailabilityOptionsWidgetsState extends State<AvailabilityOptionsWidgets> {
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (int i = 0; i < widget.options.length; i++) ...[
          _buildRadioOption(
            context: context,
            isSelected: _selectedOption == widget.options[i],
            label: widget.options[i],
            onTap: () => _selectOption(widget.options[i]),
          ),
          if (i < widget.options.length - 1) 16.horizontalSpace,
        ],
      ],
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
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
              ? Center(
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppPalettes.primaryColor,
                    ),
                  ),
                )
              : null,
        ),
        8.horizontalSpace,
        Text(label, style: context.textTheme.labelMedium),
      ],
    ),
  );
}