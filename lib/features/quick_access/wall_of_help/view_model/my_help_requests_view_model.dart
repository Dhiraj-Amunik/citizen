import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/models/request/pagination_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;
import 'package:inldsevak/features/quick_access/wall_of_help/services/wall_of_help_repository.dart';
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:quickalert/quickalert.dart';

class MyHelpRequestsViewModel extends BaseViewModel with CupertinoDialogMixin {
  @override
  Future<void> onInit() async {
    scrollController.addListener(_scrollListener);
    // Ensure token is loaded before calling onRefresh
    if (token == null) {
      await getToken();
    }
    // Wait a bit if token is still null (initialization might be in progress)
    int retries = 0;
    while (token == null && retries < 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      await getToken();
      retries++;
    }
    await onRefresh();
    return super.onInit();
  }

  List<model.FinancialRequest> myWallOFHelpLists = [];
  List<model.FinancialRequest> _filteredList = [];
  List<model.FinancialRequest> get filteredList => _filteredList;

  final WallOfHelpRepository repository = WallOfHelpRepository();

  // Pagination
  final ScrollController scrollController = ScrollController();

  final TextEditingController searchController = TextEditingController();
  bool showSearchWidget = false;

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      loadMoreData();

      // _scrollController.animateTo(
      //   _scrollController.position.maxScrollExtent /
      //       1.5,
      //   duration: Duration(milliseconds: 300),
      //   curve: Curves.easeIn,
      // );
    }
  }

  void loadMoreData() async {
    if (isLoading || _isScrollLoading) {
      return; // Don't load more data if already loading
    }
    if (!_isLastPage) {
      _currentPage++;
      getMyWallOfHelpList();
    }
  }

  Future<void> onRefresh() async {
    // Ensure token is loaded before making API call
    if (token == null) {
      await getToken();
    }
    
    // Wait a bit if token is still null (initialization might be in progress)
    int retries = 0;
    while (token == null && retries < 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      await getToken();
      retries++;
    }
    
    _currentPage = 1;
    _isLastPage = false;
    await getMyWallOfHelpList();
  }

  int _currentPage = 1;
  bool _isLastPage = false;

  bool _isScrollLoading = false;
  bool get isScrollLoading => _isScrollLoading;
  set isScrollLoading(bool value) {
    _isScrollLoading = value;
    notifyListeners();
  }

  Future<void> getMyWallOfHelpList() async {
    // Ensure token is available before making API call
    if (token == null) {
      await getToken();
      if (token == null) {
        debugPrint("Token is null, cannot fetch help requests");
        isScrollLoading = false;
        isLoading = false;
        notifyListeners();
        return;
      }
    }
    
    if (_currentPage == 1) {
      myWallOFHelpLists.clear();
      isLoading = true;
      _applySearchFilter(searchController.text);
    } else {
      isScrollLoading = true;
    }
    try {
      final paginationModel = PaginationModel(page: _currentPage);
      final response = await repository.getMyWallOFHelp(
        token: token,
        model: paginationModel,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data?.financialRequest ?? [];
        if (data.isEmpty) {
          _isLastPage = true;
        } else {
          final rawItems = List<model.FinancialRequest>.from(data);
          
          // Translate items if app is in Hindi
          final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
          final translatedItems = isHindiLocale 
              ? await _translateFinancialRequests(rawItems)
              : rawItems;
          
          myWallOFHelpLists.addAll(translatedItems);
        }
        _applySearchFilter(searchController.text);
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isScrollLoading = false;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> closeMyFinancialHelp(model.FinancialRequest request) async {
    final context = RouteManager.navigatorKey.currentState!.context;
    final localization = context.localizations;
    
    // Show confirmation dialog
    await customRightCupertinoDialog(
      content: localization.close_confirmation,
      rightButton: localization.close_request,
      onTap: () async {
        RouteManager.pop(); // Close dialog
        try {
          isLoading = true;
          final index = myWallOFHelpLists.indexWhere(
            (element) => element.sId == request.sId,
          );
          if (index == -1) {
            isLoading = false;
            return;
          }
          final response = await repository.closeFinancialHelp(
            token: token,
            id: myWallOFHelpLists[index].sId!,
          );

          if (response.data?.responseCode == 200) {
            onRefresh();
            await CommonSnackbar(
              text: response.data?.message ?? "Request Closed Successfully",
            ).showAnimatedDialog(type: QuickAlertType.success);
          } else {
            await CommonSnackbar(
              text: response.data?.message ?? "Failed to close my request",
            ).showAnimatedDialog(type: QuickAlertType.error);
          }
        } catch (err, stackTrace) {
          debugPrint("Error: $err");
          debugPrint("Stack Trace: $stackTrace");
          await CommonSnackbar(
            text: "Failed to close request",
          ).showAnimatedDialog(type: QuickAlertType.error);
        } finally {
          isLoading = false;
        }
      },
    );
  }

  void toggleSearch() {
    if (showSearchWidget) {
      hideSearch();
    } else {
      showSearchWidget = true;
      notifyListeners();
    }
  }

  void hideSearch() {
    if (!showSearchWidget) return;
    showSearchWidget = false;
    searchController.clear();
    _applySearchFilter("");
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    _applySearchFilter("");
  }

  void onSearchChanged(String query) {
    _applySearchFilter(query);
  }

  void _applySearchFilter(String query) {
    if (query.trim().isEmpty) {
      _filteredList = List.from(myWallOFHelpLists);
    } else {
      // Convert Hindi to English for search matching
      final englishQuery = _convertHindiToEnglish(query).toLowerCase();
      final originalQuery = query.trim().toLowerCase();
      
      _filteredList = myWallOFHelpLists.where((request) {
        final title = request.title?.toLowerCase() ?? "";
        final status = request.status?.toLowerCase() ?? "";
        final helpType = request.typeOfHelp?.name?.toLowerCase() ?? "";
        final requester = request.name?.toLowerCase() ?? "";
        
        // Search using English query (transliterated from Hindi if needed)
        // Also try original query in case it's already in English
        return title.contains(englishQuery) ||
            status.contains(englishQuery) ||
            helpType.contains(englishQuery) ||
            requester.contains(englishQuery) ||
            title.contains(originalQuery) ||
            status.contains(originalQuery) ||
            helpType.contains(originalQuery) ||
            requester.contains(originalQuery);
      }).toList();
    }
    notifyListeners();
  }

  /// Convert Hindi text to English for search matching
  String _convertHindiToEnglish(String hindiText) {
    if (hindiText.isEmpty) return hindiText;
    
    // Check if text contains Hindi characters
    if (!_isHindi(hindiText)) {
      return hindiText; // Already in English, return as is
    }

    // Use transliteration mapping for common Hindi to English conversions
    return _transliterateHindiToEnglish(hindiText);
  }

  /// Transliterate Hindi to English using phonetic conversion
  String _transliterateHindiToEnglish(String hindiText) {
    // Common Hindi to English transliteration mapping
    final Map<String, String> hindiToEnglish = {
      'सहायता': 'help',
      'अनुरोध': 'request',
      'शीर्षक': 'title',
      'विवरण': 'description',
      'स्थिति': 'status',
      'अनुमोदित': 'approved',
      'बंद': 'closed',
    };

    // Check if entire word matches
    final lowerHindi = hindiText.toLowerCase().trim();
    if (hindiToEnglish.containsKey(lowerHindi)) {
      return hindiToEnglish[lowerHindi]!;
    }

    // For partial matches or unknown words, try character-by-character transliteration
    return _phoneticTransliteration(hindiText);
  }

  /// Phonetic transliteration for Hindi to English
  String _phoneticTransliteration(String hindiText) {
    // Basic phonetic mapping for common Hindi characters to English
    final Map<String, String> charMap = {
      'अ': 'a', 'आ': 'aa', 'इ': 'i', 'ई': 'ee', 'उ': 'u', 'ऊ': 'oo',
      'ए': 'e', 'ऐ': 'ai', 'ओ': 'o', 'औ': 'au',
      'क': 'k', 'ख': 'kh', 'ग': 'g', 'घ': 'gh', 'ङ': 'ng',
      'च': 'ch', 'छ': 'chh', 'ज': 'j', 'झ': 'jh', 'ञ': 'ny',
      'ट': 't', 'ठ': 'th', 'ड': 'd', 'ढ': 'dh', 'ण': 'n',
      'त': 't', 'थ': 'th', 'द': 'd', 'ध': 'dh', 'न': 'n',
      'प': 'p', 'फ': 'ph', 'ब': 'b', 'भ': 'bh', 'म': 'm',
      'य': 'y', 'र': 'r', 'ल': 'l', 'व': 'v',
      'श': 'sh', 'ष': 'sh', 'स': 's', 'ह': 'h',
    };

    String result = '';
    for (int i = 0; i < hindiText.length; i++) {
      final char = hindiText[i];
      if (charMap.containsKey(char)) {
        result += charMap[char]!;
      } else if (RegExp(r'[a-zA-Z0-9\s]').hasMatch(char)) {
        result += char; // Keep English characters and numbers
      }
    }
    
    return result.isNotEmpty ? result : hindiText;
  }

  /// Check if text contains Hindi/Devanagari characters
  bool _isHindi(String text) {
    final hindiRegex = RegExp(r'[\u0900-\u097F]');
    return hindiRegex.hasMatch(text);
  }

  /// Translate financial requests based on app language
  /// Translates title, description, and typeOfHelp.name fields when app is in Hindi
  Future<List<model.FinancialRequest>> _translateFinancialRequests(
    List<model.FinancialRequest> rawItems,
  ) async {
    final translatedItems = <model.FinancialRequest>[];
    
    // Translate all items in parallel for better performance
    final translationFutures = rawItems.map((item) async {
      // Translate title and description
      final translatedTitle = await TranslationHelper.translateText(
        item.title,
        force: true, // Force translation based on locale (English -> Hindi)
      );
      
      final translatedDescription = await TranslationHelper.translateText(
        item.description,
        force: true,
      );
      
      // Translate typeOfHelp.name if it exists
      String? translatedTypeOfHelpName;
      if (item.typeOfHelp?.name != null) {
        translatedTypeOfHelpName = await TranslationHelper.translateText(
          item.typeOfHelp!.name,
          force: true,
        );
      }
      
      // Create new TypeOfHelp with translated name if needed
      model.TypeOfHelp? translatedTypeOfHelp;
      if (item.typeOfHelp != null) {
        translatedTypeOfHelp = model.TypeOfHelp(
          sId: item.typeOfHelp!.sId,
          name: translatedTypeOfHelpName ?? item.typeOfHelp!.name,
        );
      }
      
      // Create new FinancialRequest with translated fields
      return model.FinancialRequest(
        sId: item.sId,
        partyMember: item.partyMember,
        name: item.name,
        phone: item.phone,
        amountRequested: item.amountRequested,
        urgency: item.urgency,
        description: translatedDescription,
        documents: item.documents,
        status: item.status,
        isActive: item.isActive,
        isDeleted: item.isDeleted,
        amountCollected: item.amountCollected,
        address: item.address,
        uPI: item.uPI,
        typeOfHelp: translatedTypeOfHelp,
        preferredWayForHelp: item.preferredWayForHelp,
        othersWayForHelp: item.othersWayForHelp,
        othersTypeOfHelp: item.othersTypeOfHelp,
        transactions: item.transactions,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
        iV: item.iV,
        messageDetails: item.messageDetails,
        messageId: item.messageId,
        title: translatedTitle,
      );
    }).toList();
    
    // Wait for all translations to complete
    translatedItems.addAll(await Future.wait(translationFutures));
    
    return translatedItems;
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
