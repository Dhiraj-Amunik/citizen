import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/notify_representative/model/request/nr_pagination_model.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_filters_model.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_lists_model.dart';
import 'package:inldsevak/features/notify_representative/services/notify_repository.dart';
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:quickalert/quickalert.dart';

class NotifyRepresentativeViewModel extends BaseViewModel with CupertinoDialogMixin {
  final _repository = NotifyRepository();

  @override
  Future<void> onInit() async {
    recentScrollController.addListener(_recentScrollListener);
    pastScrollController.addListener(_pastScrollListener);
    await Future.wait([
      getNotifyFilters(),
      getAllNotifyData(),
    ]);
    return super.onInit();
  }

  // Filters
  NotifyFiltersData? filtersData;
  MlaFilter? selectedMla;
  String? selectedDistrict;
  String? selectedMandal;
  String? selectedVillage;
  bool _isFiltersLoading = false;
  bool get isFiltersLoading => _isFiltersLoading;

  Future<void> getNotifyFilters() async {
    _isFiltersLoading = true;
    notifyListeners();
    try {
      final response = await _repository.getNotifyFilters(token: token);
      if (response.data?.responseCode == 200) {
        filtersData = response.data?.data;
        notifyListeners();
      } else {
        CommonSnackbar(
          text: response.data?.message ?? 'Unable to fetch filters',
        ).showToast();
      }
    } catch (err, stackTrace) {
      debugPrint("Error fetching filters: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      _isFiltersLoading = false;
      notifyListeners();
    }
  }

  void setMla(MlaFilter? mla) {
    selectedMla = mla;
    notifyListeners();
    _applyFilters();
  }

  void setDistrict(String? district) {
    selectedDistrict = district;
    notifyListeners();
    _applyFilters();
  }

  void setMandal(String? mandal) {
    selectedMandal = mandal;
    notifyListeners();
    _applyFilters();
  }

  void setVillage(String? village) {
    selectedVillage = village;
    notifyListeners();
    _applyFilters();
  }

  void clearFilters() {
    selectedMla = null;
    selectedDistrict = null;
    selectedMandal = null;
    selectedVillage = null;
    notifyListeners();
    _applyFilters();
  }

  void _applyFilters() {
    onRecentRefresh();
    onPastRefresh();
  }

  Future<void> getAllNotifyData() async {
    isLoading = true;

    try {
      await Future.wait([
        getNotifyLists(NotifyReprFilter.recent),
        getNotifyLists(NotifyReprFilter.past),
      ]);
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  final searchController = TextEditingController();
  Timer? _debounce;

  onSearchChanged(int tab) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (tab == 0) {
        onRecentRefresh();
      } else {
        onPastRefresh();
      }
    });
  }

  // Pagination

  final ScrollController recentScrollController = ScrollController();
  final ScrollController pastScrollController = ScrollController();

  List<NotifyRepresentative> recentNotifyLists = [];
  List<NotifyRepresentative> pastNotifyLists = [];

  void _recentScrollListener() {
    if (recentScrollController.position.pixels >=
        recentScrollController.position.maxScrollExtent * 0.8) {
      loadRecentMoreData();
    }
  }

  void _pastScrollListener() {
    if (pastScrollController.position.pixels >=
        pastScrollController.position.maxScrollExtent * 0.8) {
      loadPastMoreData();
    }
  }

  void loadRecentMoreData() async {
    if (isLoading || _isScrollLoading) {
      return;
    }
    if (!_recentIsLastPage) {
      _recentCurrentPage++;
      getNotifyLists(NotifyReprFilter.recent);
    }
  }

  void loadPastMoreData() async {
    if (isLoading || _isScrollLoading) {
      return;
    }
    if (!_pastIsLastPage) {
      _pastCurrentPage++;
      getNotifyLists(NotifyReprFilter.past);
    }
  }

  onRecentRefresh() {
    _recentCurrentPage = 1;
    _recentIsLastPage = false;
    recentNotifyLists.clear(); // Ensure list is cleared before refresh
    getNotifyLists(NotifyReprFilter.recent);
  }

  onPastRefresh() {
    _pastCurrentPage = 1;
    _pastIsLastPage = false;
    pastNotifyLists.clear(); // Ensure list is cleared before refresh
    getNotifyLists(NotifyReprFilter.past);
  }

  int _recentCurrentPage = 1;
  int _pastCurrentPage = 1;
  bool _recentIsLastPage = false;
  bool _pastIsLastPage = false;

  bool _isScrollLoading = false;
  bool get isScrollLoading => _isScrollLoading;
  set isScrollLoading(bool value) {
    _isScrollLoading = value;
    notifyListeners();
  }

  Future<void> getNotifyLists(NotifyReprFilter filter) async {
    switch (filter) {
      case NotifyReprFilter.recent:
        if (_recentCurrentPage == 1) {
          recentNotifyLists.clear();
          isLoading = true;
        } else {
          isScrollLoading = true;
        }
        break;

      case NotifyReprFilter.past:
        if (_pastCurrentPage == 1) {
          pastNotifyLists.clear();
          isLoading = true;
        } else {
          isScrollLoading = true;
        }
        break;
    }

    try {
      // Convert Hindi search to English before sending to API
      String? searchQuery = searchController.text.isEmpty 
          ? null 
          : _convertHindiToEnglishForSearch(searchController.text);
      
      // Convert single selections to arrays as API expects
      final paginationModel = NotifyReprPaginationModel(
        filter: filter,
        page: NotifyReprFilter.recent == filter
            ? _recentCurrentPage
            : _pastCurrentPage,
        search: searchQuery,
        constituencies: null,
        mlaIds: selectedMla?.sId != null 
            ? [selectedMla!.sId!] 
            : null,
        districts: selectedDistrict != null && selectedDistrict!.isNotEmpty
            ? [selectedDistrict!]
            : null,
        mandals: selectedMandal != null && selectedMandal!.isNotEmpty
            ? [selectedMandal!]
            : null,
        villages: selectedVillage != null && selectedVillage!.isNotEmpty
            ? [selectedVillage!]
            : null,
        sortBy: "-1", // Default to descending (newest first)
      );
      final response = await _repository.getNotifyRepresentative(
        token: token,
        model: paginationModel,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data?.notifyRepresentative;

        if (data?.isEmpty == true) {
          // Set the appropriate last page flag
          if (filter == NotifyReprFilter.recent) {
            _recentIsLastPage = true;
          } else {
            _pastIsLastPage = true;
          }
          return;
        }
        if (data?.isNotEmpty == true) {
          // Convert to list and filter out duplicates
          final rawItems = List<NotifyRepresentative>.from(data as List);
          final pageSize = response.data?.data?.pageSize ?? 20;
          
          // Translate items if app is in Hindi
          final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
          final newItems = isHindiLocale 
              ? await _translateNotifyItems(rawItems)
              : rawItems;
          
          switch (filter) {
            case NotifyReprFilter.recent:
              // Filter out duplicates based on sId before adding
              final existingIds = recentNotifyLists.map((e) => e.sId).toSet();
              final uniqueItems = newItems.where((item) => !existingIds.contains(item.sId)).toList();
              recentNotifyLists.addAll(uniqueItems);
              // Update last page flag - if we got less items than page size, we're on the last page
              if (newItems.length < pageSize) {
                _recentIsLastPage = true;
              }
              break;

            case NotifyReprFilter.past:
              // Filter out duplicates based on sId before adding
              final existingIds = pastNotifyLists.map((e) => e.sId).toSet();
              final uniqueItems = newItems.where((item) => !existingIds.contains(item.sId)).toList();
              pastNotifyLists.addAll(uniqueItems);
              // Update last page flag - if we got less items than page size, we're on the last page
              if (newItems.length < pageSize) {
                _pastIsLastPage = true;
              }
              break;
          }
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isScrollLoading = false;
      isLoading = false;
    }
  }

  Future<void> deleteNotify(NotifyRepresentative? data) async {
    final context = RouteManager.navigatorKey.currentState!.context;
    final localization = context.localizations;
    
    // Show confirmation dialog
    await customRightCupertinoDialog(
      content: localization.delete_confirmation,
      rightButton: localization.delete,
      onTap: () async {
        RouteManager.pop(); // Close dialog
        try {
          isLoading = true;
          final response = await _repository.deleteNotify(
            token: token,
            id: data?.sId ?? "",
          );

          if (response.data?.responseCode == 200) {
            recentNotifyLists.remove(data);
            pastNotifyLists.remove(data);
            notifyListeners();
            await CommonSnackbar(
              text: response.data?.message ?? "Request deleted successfully",
            ).showAnimatedDialog(type: QuickAlertType.success);
          } else {
            await CommonSnackbar(
              text: response.data?.message ?? "Failed to delete request",
            ).showAnimatedDialog(type: QuickAlertType.error);
          }
        } catch (err, stackTrace) {
          debugPrint("Error: $err");
          debugPrint("Stack Trace: $stackTrace");
          await CommonSnackbar(
            text: "Failed to delete request",
          ).showAnimatedDialog(type: QuickAlertType.error);
        } finally {
          isScrollLoading = false;
          isLoading = false;
        }
      },
    );
  }

  /// Convert Hindi search query to English for API search
  String _convertHindiToEnglishForSearch(String hindiText) {
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
      'अधिसूचना': 'notification',
      'प्रतिनिधि': 'representative',
      'घटना': 'event',
      'शीर्षक': 'title',
      'विवरण': 'description',
      'स्थान': 'location',
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

  /// Translate notify items based on app language
  /// Translates title, eventType, and description fields when app is in Hindi
  Future<List<NotifyRepresentative>> _translateNotifyItems(List<NotifyRepresentative> rawItems) async {
    final translatedItems = <NotifyRepresentative>[];
    
    // Translate all items in parallel for better performance
    final translationFutures = rawItems.map((item) async {
      // Translate title, eventType, and description fields
      final translatedTitle = await TranslationHelper.translateText(
        item.title,
        force: true, // Force translation based on locale (English -> Hindi)
      );
      
      final translatedEventType = await TranslationHelper.translateText(
        item.eventType,
        force: true,
      );
      
      final translatedDescription = await TranslationHelper.translateText(
        item.description,
        force: true,
      );
      
      // Create new NotifyRepresentative with translated fields
      return NotifyRepresentative(
        location: item.location,
        sId: item.sId,
        title: translatedTitle,
        eventType: translatedEventType,
        description: translatedDescription,
        dateAndTime: item.dateAndTime,
        documents: item.documents,
        specialInvites: item.specialInvites,
        isActive: item.isActive,
        isDeleted: item.isDeleted,
        status: item.status,
        responses: item.responses,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
        iV: item.iV,
        partyMember: item.partyMember,
        street: item.street,
        pincode: item.pincode,
        district: item.district,
        mandal: item.mandal,
        village: item.village,
        area: item.area,
        state: item.state,
        assemblyConstituency: item.assemblyConstituency,
        parliamentaryConstituency: item.parliamentaryConstituency,
      );
    }).toList();
    
    // Wait for all translations to complete
    translatedItems.addAll(await Future.wait(translationFutures));
    
    return translatedItems;
  }
}

class ShowSearchNotifyProvider extends ChangeNotifier {
  bool _showSearchWidget = false;

  bool get showSearchWidget => _showSearchWidget;

  set showSearchWidget(bool value) {
    _showSearchWidget = value;
    notifyListeners();
  }
}
