import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/party_help_card.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/wall_of_help_helpers.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/my_help_requests_view_model.dart';
import 'package:provider/provider.dart';

class MyHelpRequestsView extends StatelessWidget {
  const MyHelpRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    return ChangeNotifierProvider(
      create: (context) => MyHelpRequestsViewModel(),
      builder: (context, _) {
        return Consumer<MyHelpRequestsViewModel>(
          builder: (context, value, _) {
            if (value.filteredList.isEmpty && !value.isLoading) {
              return Scaffold(
                appBar: commonAppBar(
                  title: localization.my_requests,
                  action: [
                    IconButton(
                      icon: Icon(
                        value.showSearchWidget ? Icons.close : Icons.search,
                        color: context.cardColor.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      ),
                      onPressed: value.toggleSearch,
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    if (value.showSearchWidget) _buildSearchField(context, value),
                    Expanded(
                      child: WallOfHelpHelpers.emptyHelper(
                        text: "No requests found",
                        onRefresh: value.onRefresh,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return Scaffold(
              appBar: commonAppBar(
                title: localization.my_requests,
                action: [
                  IconButton(
                    icon: Icon(
                      value.showSearchWidget ? Icons.close : Icons.search,
                      color: context.cardColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    ),
                    onPressed: value.toggleSearch,
                  ),
                ],
              ),
              body: value.isLoading && value.filteredList.isEmpty
                  ? Center(child: CustomAnimatedLoading())
                  : Column(
                      children: [
                        if (value.showSearchWidget)
                          _buildSearchField(context, value),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: value.onRefresh,
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimens.horizontalspacing,
                              ).copyWith(bottom: Dimens.verticalspacing),
                              controller: value.scrollController,
                              itemCount: value.filteredList.length,
                              itemBuilder: (context, index) {
                                final request = value.filteredList[index];
                                return Column(
                                  spacing: Dimens.gapX4,
                                  children: [
                                    PartyHelpCard(
                                      closeRequest: () =>
                                          value.closeMyFinancialHelp(request),
                                      helpRequest: request,
                                      isEditable: true,
                                    ),
                                    if (value.isScrollLoading &&
                                        value.filteredList.last == request)
                                      CustomAnimatedLoading(),
                                  ],
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  SizeBox.widgetSpacing,
                            ),
                          ),
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    MyHelpRequestsViewModel value,
  ) {
    final localization = context.localizations;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.horizontalspacing,
        vertical: Dimens.paddingX2,
      ),
      child: TextField(
        controller: value.searchController,
        cursorColor: AppPalettes.primaryColor,
        decoration: InputDecoration(
          hintText: localization.search,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: value.searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: value.clearSearch,
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusX3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusX3),
            borderSide: const BorderSide(
              color: AppPalettes.primaryColor,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusX3),
            borderSide: BorderSide(
              color: AppPalettes.borderColor,
            ),
          ),
        ),
        onChanged: value.onSearchChanged,
        textInputAction: TextInputAction.search,
        onSubmitted: value.onSearchChanged,
      ),
    );
  }
}
