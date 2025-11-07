import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/features/common_fields/view_model/mla_view_model.dart';
import 'package:inldsevak/features/quick_access/appointments/model/mla_dropdown_model.dart'
    as mla;
import 'package:provider/provider.dart';

class MlaDropDownWidget extends StatelessWidget {
  final SingleSelectController<mla.Data?> mlaController;

  const MlaDropDownWidget({super.key, required this.mlaController});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;

    return Consumer<MlaViewModel>(
      builder: (context, value, _) {
        return FormCommonDropDown<mla.Data?>(
          isRequired: true,
          heading: localization.select_associate,
          hintText: localization.choose_your_associate,
          controller: mlaController,
          items: value.mlaLists,
          listItemBuilder: (p0, mla, p2, p3) {
            return Text(mla?.user?.name ?? "", style: textTheme.bodySmall);
          },
          headerBuilder: (p0, mla, p2) {
            return Text(mla?.user?.name ?? "", style: textTheme.bodySmall);
          },
          validator: (data) {
            if (data == null) {
              return localization.mla_validator;
            }
          },
        );
      },
    );
  }
}
