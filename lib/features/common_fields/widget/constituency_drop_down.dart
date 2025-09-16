import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/features/complaints/model/response/constituency_model.dart'
    as constituency;
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/features/common_fields/view_model/constituency_view_model.dart';
import 'package:provider/provider.dart';

class ConstituencyDropDownWidget extends StatefulWidget {
  final constituency.Data? initialData;
  final SingleSelectController<constituency.Data> constituencyController;
  const ConstituencyDropDownWidget({
    super.key,
    required this.constituencyController,
    this.initialData,
  });

  @override
  State<ConstituencyDropDownWidget> createState() =>
      _ConstituencyDropDownWidgetState();
}

class _ConstituencyDropDownWidgetState
    extends State<ConstituencyDropDownWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConstituencyViewModel>().constituencyLists.add(
        widget.initialData!,
      );
      widget.constituencyController.value = context
          .read<ConstituencyViewModel>()
          .constituencyLists
          .first;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;

    return PopScope(
      onPopInvokedWithResult: (_, _) {
        widget.constituencyController.clear();
        context.read<ConstituencyViewModel>().constituencyLists.clear();
      },
      child: Consumer<ConstituencyViewModel>(
        builder: (context, value, child) {
          return FormCommonDropDown<constituency.Data>(
            isRequired: true,
            heading: localization.constituency,
            controller: widget.constituencyController,
            items: value.constituencyLists,
            hintText: localization.select_your_constituency,
            listItemBuilder: (p0, constituency, p2, p3) {
              return Text(
                "${constituency.name}",
                style: context.textTheme.bodySmall,
              );
            },
            headerBuilder: (p0, constituency, p2) {
              return Text(
                "${constituency.name}",
                style: context.textTheme.bodySmall,
              );
            },
            validator: (text) => text.toString().validateDropDown(
              argument: "Select your constituency",
            ),
          );
        },
      ),
    );
  }
}
