import 'dart:developer';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/models/response/constituency/constituency_model.dart';

import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/features/common_fields/view_model/constituency_view_model.dart';
import 'package:provider/provider.dart';

class AssemblyConstituencyDropDownWidget extends StatefulWidget {
  final Constituency? initialData;
  final SingleSelectController<Constituency> constituencyController;
  const AssemblyConstituencyDropDownWidget({
    super.key,
    required this.constituencyController,
    this.initialData,
  });

  @override
  State<AssemblyConstituencyDropDownWidget> createState() =>
      _AssemblyConstituencyDropDownWidgetState();
}

class _AssemblyConstituencyDropDownWidgetState
    extends State<AssemblyConstituencyDropDownWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.constituencyController.clear();
      if (widget.initialData == null) {
        return;
      }

      widget.constituencyController.value = context
          .read<ConstituencyViewModel>()
          .assemblyConstituencyLists
          .firstWhere(
            (constituency) => constituency?.sId == widget.initialData?.sId,
          );
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AssemblyConstituencyDropDownWidget oldWidget) {
    log("===========================================>");
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;

    return Consumer<ConstituencyViewModel>(
      builder: (context, value, child) {
        return FormCommonDropDown<Constituency?>(
          isRequired: true,
          heading: localization.assembly_constituency,
          controller: widget.constituencyController,
          items: value.assemblyConstituencyLists,
          hintText: localization.select_your_constituency,
          listItemBuilder: (p0, constituency, p2, p3) {
            return Text(
              "${constituency?.name}",
              style: context.textTheme.bodySmall,
            );
          },
          headerBuilder: (p0, constituency, p2) {
            return Text(
              "${constituency?.name}",
              style: context.textTheme.bodySmall,
            );
          },
          validator: (text) => text.toString().validateDropDown(
            argument: "Select your constituency",
          ),
        );
      },
    );
  }
}
