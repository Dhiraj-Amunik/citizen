import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/widgets/common_checkbox.dart';

class InterestChoiceWidget extends StatefulWidget {
  final List<String>? selected;
  final List<String> options;
  final ValueChanged<Map<String, bool>>? onSelectionChanged;

  const InterestChoiceWidget({
    super.key,
    required this.options,
    required this.onSelectionChanged,
    this.selected,
  });

  @override
  State<InterestChoiceWidget> createState() => _InterestChoiceWidgetState();
}

class _InterestChoiceWidgetState extends State<InterestChoiceWidget> {
  late Map<String, bool> selectionStates;

  @override
  void initState() {
    super.initState();
    selectionStates = {};
    for (var key in widget.options) {
      selectionStates[key] = widget.selected?.contains(key) ?? false;
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
      children: widget.options.map((entry) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth / 2.04,
              child: CommonCheckbox(
                borderColor: AppPalettes.primaryColor,
                backgroundColor: AppPalettes.whiteColor,
                title: entry,
                isSelected: selectionStates[entry]!,
                onTap: () => _toggleOption(entry),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
