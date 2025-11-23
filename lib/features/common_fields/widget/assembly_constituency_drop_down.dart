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
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      try {
        // Only set initial data if it exists and doesn't match current value
        if (widget.initialData != null) {
          final lists =
              context.read<ConstituencyViewModel>().assemblyConstituencyLists;
          // Use where().firstOrNull pattern to avoid type error
          final matched = lists.where(
            (constituency) => constituency?.sId == widget.initialData?.sId,
          ).firstOrNull;
          
          if (matched != null && mounted) {
            final currentValue = widget.constituencyController.value;
            // Only update if the value is different
            if (currentValue?.sId != matched.sId) {
              widget.constituencyController.value = matched;
            }
          } else if (mounted) {
            // If initial data exists but not in list, clear to avoid stale data
            final currentValue = widget.constituencyController.value;
            if (currentValue?.sId == widget.initialData?.sId) {
              widget.constituencyController.clear();
            }
          }
        } else if (mounted) {
          // If no initial data, ensure controller is cleared
          final currentValue = widget.constituencyController.value;
          if (currentValue != null) {
            widget.constituencyController.clear();
          }
        }
      } catch (e) {
        // Silently handle any errors if widget is disposed
        debugPrint('Error in assembly constituency initState: $e');
      }
    });
  }

  @override
  void didUpdateWidget(covariant AssemblyConstituencyDropDownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mounted) return;
    
    // Check if the list changed and validate controller value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      try {
        final lists =
            context.read<ConstituencyViewModel>().assemblyConstituencyLists;
        final currentValue = widget.constituencyController.value;
        
        // If controller has a value, ensure it's in the current list
        if (currentValue != null) {
          if (lists.isEmpty) {
            // List is empty, clear controller
            widget.constituencyController.clear();
          } else {
            // Check if value exists in list
            final existsInList = lists.any(
              (item) => item?.sId == currentValue.sId,
            );
            
            if (!existsInList) {
              // Value not in list, clear it
              widget.constituencyController.clear();
            }
          }
        }
        
        // Handle initial data changes
        if (widget.initialData?.sId != oldWidget.initialData?.sId) {
          if (widget.initialData == null) {
            if (mounted && widget.constituencyController.value != null) {
              widget.constituencyController.clear();
            }
            return;
          }

          // Use where().firstOrNull pattern to avoid type error
          final matched = lists.where(
            (constituency) => constituency?.sId == widget.initialData?.sId,
          ).firstOrNull;
          
          if (matched != null && mounted) {
            // Only update if the value is actually different
            final currentVal = widget.constituencyController.value;
            if (currentVal?.sId != matched.sId) {
              widget.constituencyController.value = matched;
            }
          } else if (mounted) {
            // If no match found, clear the controller only if it matches old initial data
            final currentVal = widget.constituencyController.value;
            if (currentVal?.sId == oldWidget.initialData?.sId) {
              widget.constituencyController.clear();
            }
          }
        }
      } catch (e) {
        // Silently handle any errors if widget is disposed
        debugPrint('Error in assembly constituency didUpdateWidget: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;

    return Consumer<ConstituencyViewModel>(
      builder: (context, value, child) {
        // Validate controller value is in the items list
        final currentValue = widget.constituencyController.value;
        final items = value.assemblyConstituencyLists;
        
        // If controller has a value but it's not in the items list, clear it immediately
        if (currentValue != null) {
          if (items.isEmpty) {
            // List is empty, clear controller
            widget.constituencyController.clear();
          } else {
            final existsInList = items.any(
              (item) => item?.sId == currentValue.sId,
            );
            
            if (!existsInList) {
              // Value not in list, clear it immediately to avoid assertion error
              widget.constituencyController.clear();
            }
          }
        }
        
        return FormCommonDropDown<Constituency?>(
          isRequired: true,
          heading: localization.assembly_constituency,
          controller: widget.constituencyController,
          items: value.assemblyConstituencyLists,
          hintText: localization.select_your_constituency,
          onChanged: (constituency) {
            // Ensure value is properly set when changed
            if (constituency != null) {
              widget.constituencyController.value = constituency;
            }
          },
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
