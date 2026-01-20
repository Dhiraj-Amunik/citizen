import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/animated_search_widget.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/party_help_card.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/wall_of_help_helpers.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/my_help_requests_view_model.dart';
import 'package:provider/provider.dart';

class MyHelpRequestsView extends StatefulWidget {
  const MyHelpRequestsView({super.key});

  @override
  State<MyHelpRequestsView> createState() => _MyHelpRequestsViewState();
}

class _MyHelpRequestsViewState extends State<MyHelpRequestsView> {
  MyHelpRequestsViewModel? _viewModel;
  DateTime? _lastRefreshTime;
  bool _isInitialLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when returning to this route (e.g., after editing)
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      // Skip the initial load since onInit() already handles it
      if (_isInitialLoad) {
        _isInitialLoad = false;
        _lastRefreshTime = DateTime.now();
        return;
      }
      
      final now = DateTime.now();
      // Only refresh if it's been more than 1 second since last refresh
      // This prevents excessive refreshes while allowing refresh on return
      if (_lastRefreshTime == null || 
          now.difference(_lastRefreshTime!) > const Duration(seconds: 1)) {
        _lastRefreshTime = now;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _viewModel != null) {
            _viewModel!.onRefresh();
          }
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = MyHelpRequestsViewModel();
        _viewModel = viewModel;
        return viewModel;
      },
      builder: (context, _) {
        return ChangeNotifierProvider(
          create: (contextP) => ShowSearchHelpRequestsProvider(
            clear: () {
              _viewModel?.searchController.clear();
              _viewModel?.onSearchChanged("");
            },
          ),
          child: Consumer2<MyHelpRequestsViewModel, ShowSearchHelpRequestsProvider>(
            builder: (context, value, searchProvider, _) {
              if (value.filteredList.isEmpty && !value.isLoading) {
                return Scaffold(
                  appBar: commonAppBar(
                    title: localization.my_requests,
                    action: [
                      Consumer<ShowSearchHelpRequestsProvider>(
                        builder: (contextP, search, _) {
                          return !search.showSearchWidget
                              ? CommonHelpers.buildIcons(
                                  color: AppPalettes.liteGreenColor,
                                  padding: Dimens.paddingX2,
                                  path: AppImages.searchIcon,
                                  onTap: () => search.showSearchWidget = true,
                                )
                              : SizedBox();
                        },
                      ),
                    ],
                  ),
                  body: Column(
                    children: [
                      Consumer<ShowSearchHelpRequestsProvider>(
                        builder: (contextP, search, _) {
                          return AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            child: search.showSearchWidget
                                ? AnimatedSearchBar(
                                    key: ValueKey('search_bar'),
                                    controller: value.searchController,
                                    onChanged: (text) => value.onSearchChanged(text),
                                    onClear: () {
                                      value.searchController.clear();
                                      value.onSearchChanged("");
                                      search.showSearchWidget = false;
                                    },
                                  )
                                : SizedBox(key: ValueKey('empty')),
                          );
                        },
                      ),
                      SizeBox.sizeHX2,
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: WallOfHelpHelpers.emptyHelper(
                                text: "No requests found",
                                onRefresh: value.onRefresh,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimens.horizontalspacing,
                                vertical: Dimens.verticalspacing,
                              ),
                              child: CommonButton(
                                text: "Raise a Request",
                                onTap: () {
                                  RouteManager.pushNamed(Routes.requestWallOfHelpPage);
                                },
                                color: AppPalettes.gradientSecondColor,
                              ),
                            ),
                          ],
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
                    Consumer<ShowSearchHelpRequestsProvider>(
                      builder: (contextP, search, _) {
                        return !search.showSearchWidget
                            ? CommonHelpers.buildIcons(
                                color: AppPalettes.liteGreenColor,
                                padding: Dimens.paddingX2,
                                path: AppImages.searchIcon,
                                onTap: () => search.showSearchWidget = true,
                              )
                            : SizedBox();
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Consumer<ShowSearchHelpRequestsProvider>(
                      builder: (contextP, search, _) {
                        return AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          child: search.showSearchWidget
                              ? AnimatedSearchBar(
                                  key: ValueKey('search_bar'),
                                  controller: value.searchController,
                                  onChanged: (text) => value.onSearchChanged(text),
                                  onClear: () {
                                    value.searchController.clear();
                                    value.onSearchChanged("");
                                    search.showSearchWidget = false;
                                  },
                                )
                              : SizedBox(key: ValueKey('empty')),
                        );
                      },
                    ),
                    SizeBox.sizeHX2,
                    Expanded(
                      child: value.isLoading && value.filteredList.isEmpty
                          ? Center(child: CustomAnimatedLoading())
                          : RefreshIndicator(
                              onRefresh: value.onRefresh,
                              color: AppPalettes.primaryColor,
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
          ),
        );
      },
    );
  }
}

// Search provider for help requests view
class ShowSearchHelpRequestsProvider extends ChangeNotifier {
  final Function() clear;

  ShowSearchHelpRequestsProvider({required this.clear});
  bool _showSearchWidget = false;

  bool get showSearchWidget => _showSearchWidget;

  set showSearchWidget(bool value) {
    _showSearchWidget = value;
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}
