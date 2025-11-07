import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_checkbox.dart';

class MultiChoiceWidget extends StatefulWidget {
  final List<String> selectedOptions;
  final List<String>? answers;
  final List<String> options;
  final Function(List<String>)? onSelectionChanged;
  const MultiChoiceWidget({
    super.key,
    required this.options,
    this.answers,
    required this.selectedOptions,
    this.onSelectionChanged,
  });

  @override
  State<MultiChoiceWidget> createState() => _MultiChoiceWidgetState();
}

class _MultiChoiceWidgetState extends State<MultiChoiceWidget> {
  void _toggleOption(String optionKey) {
    if (widget.answers?.isNotEmpty == true) return;
    setState(() {
      widget.selectedOptions.clear();
      widget.selectedOptions.add(optionKey);
      widget.onSelectionChanged?.call(List.from(widget.selectedOptions));
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.selectedOptions.addAll(widget.answers ?? []);
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: Dimens.gapX1,
      runSpacing: Dimens.gapX2B,
      children: widget.options.asMap().entries.map((entry) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: CommonCheckbox(
                borderColor: AppPalettes.primaryColor,
                backgroundColor: AppPalettes.whiteColor,
                title: entry.value,
                isSelected: widget.selectedOptions.contains(entry.value),
                onTap: () => _toggleOption(entry.value),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
