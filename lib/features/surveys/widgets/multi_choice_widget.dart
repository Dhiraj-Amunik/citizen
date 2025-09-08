import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/widgets/common_checkbox.dart';

class MultiChoiceWidget extends StatefulWidget {
  final List<String>? answers;
  final bool? isEnabled;
  final Map<String, String> options;
  final ValueChanged<Map<String, bool>>? onSelectionChanged;

  const MultiChoiceWidget({
    super.key,
    required this.options,
    required this.onSelectionChanged,
    this.isEnabled,
    this.answers,
  });

  @override
  State<MultiChoiceWidget> createState() => _MultiChoiceWidgetState();
}

class _MultiChoiceWidgetState extends State<MultiChoiceWidget> {
  late Map<String, bool> selectionStates;

  @override
  void initState() {
    super.initState();
    selectionStates = {};
    for (var key in widget.options.keys) {
      selectionStates[key] = widget.answers?.contains(key) ?? false;
    }
  }

  void _toggleOption(String optionKey) {
    setState(() {
      selectionStates[optionKey] = !selectionStates[optionKey]!;
      widget.onSelectionChanged!(selectionStates);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 4.w,
      runSpacing: 12.h,
      children:
          widget.options.entries.map((entry) {
            return LayoutBuilder(
              builder: (context,constraints) {
                return SizedBox(
                  width: constraints.maxWidth/2.04,
                  child: CommonCheckbox(
                    borderColor: AppPalettes.primaryColor,
                    backgroundColor: AppPalettes.whiteColor,
                    title: entry.value,
                    // title: "${entry.key}. ${entry.value}",
                    isSelected: selectionStates[entry.key]!,
                    onTap:
                        widget.isEnabled == true
                            ? () => _toggleOption(entry.key)
                            : () {},
                  ),
                );
              }
            );
          }).toList(),
    );
  }
}
