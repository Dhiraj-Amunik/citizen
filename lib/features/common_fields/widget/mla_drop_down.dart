import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/features/common_fields/view_model/mla_view_model.dart';
import 'package:inldsevak/features/quick_access/appointments/model/mla_dropdown_model.dart'
    as mla;
import 'package:inldsevak/l10n/app_localizations.dart';
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
        if (value.isLoading && value.mlaLists.isEmpty) {
          return _buildLoadingState(localization, textTheme);
        }

        if (!value.isLoading &&
            value.mlaLists.isEmpty &&
            value.hasLoaded &&
            value.errorMessage != null) {
          return _buildEmptyState(
            textTheme,
            heading: localization.select_associate,
            message: value.errorMessage ?? localization.choose_your_associate,
            retryLabel: "Retry",
            onRetry: () => value.retry(),
          );
        }

        return FormCommonDropDown<mla.Data?>(
          isRequired: true,
          heading: localization.select_associate,
          hintText: localization.choose_your_associate,
          controller: mlaController,
          items: value.mlaLists,
          listItemBuilder: (p0, mlaItem, p2, p3) {
            return Text(
              mlaItem?.user?.name ?? localization.choose_your_associate,
              style: textTheme.bodySmall,
            );
          },
          headerBuilder: (p0, mlaItem, p2) {
            return Text(
              mlaItem?.user?.name ?? localization.choose_your_associate,
              style: textTheme.bodySmall,
            );
          },
          validator: (data) {
            if (data == null) {
              return localization.mla_validator;
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildLoadingState(
    AppLocalizations localization,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.select_associate,
          style: textTheme.bodyMedium,
        ),
        SizedBox(height: Dimens.paddingX1),
        Container(
          height: Dimens.paddingX10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimens.radiusX3),
            border: Border.all(color: Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
            color: AppPalettes.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    TextTheme textTheme,
    {
    required String heading,
    required String message,
    required String retryLabel,
    required VoidCallback onRetry,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: textTheme.bodyMedium,
        ),
        SizedBox(height: Dimens.paddingX1),
        Container(
          padding: EdgeInsets.all(Dimens.paddingX3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimens.radiusX3),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: textTheme.bodySmall,
              ),
              SizedBox(height: Dimens.gapX2),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onRetry,
                  child: Text(retryLabel),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
