import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';
import 'package:inldsevak/core/mixin/upload_files_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/request_finanical_help_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/woh_pagination_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/services/wall_of_help_repository.dart';
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;
import 'package:inldsevak/features/quick_access/wall_of_help/model/type_of_help_model.dart'
    as types;
import 'package:inldsevak/features/quick_access/wall_of_help/model/preferred_way_model.dart'
    as preferred;

class WallOfHelpViewModel extends BaseViewModel with UploadFilesMixin {
  final WallOfHelpRepository repository = WallOfHelpRepository();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  final nameFocus = FocusNode();
  final phoneFocus = FocusNode();
  final addressFocus = FocusNode();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final upiIdController = TextEditingController();
  final otherTypeController = TextEditingController();
  final otherPreferredController = TextEditingController();

  final searchController = TextEditingController();
  Timer? _debounce;

  String? statusKey;
  String? dateKey;
  List<String> statusItems = [
    "all",
    "approved",
    "Partially-Funded",
    "Fully-Funded",
    "closed",
  ];
  List<String> dateItems = ["Recent", "One Month", "Six Months"];

  setStatus(String status) {
    statusKey = status;
    notifyListeners();
  }

  setDate(String status) {
    dateKey = status;
    notifyListeners();
  }

  @override
  Future<void> onInit() {
    Future.wait([getWallOfHelpList(), getTypes(), getPreferred()]);
    scrollController.addListener(_scrollListener);
    return super.onInit();
  }

  List<model.FinancialRequest> wallOFHelpLists = [];
  List<preferred.Data> preferredWaysList = [];
  List<types.Data> typeOfHelpsList = [];
  List<String> urgencyList = [
    'Immediate (within 24 hours)',
    'Soon (within a week)',
    'Not Urgent (whenever possible)',
  ];

  //documents
  List<File> multipleFiles = [];

  Future<void> addFiles(Future<dynamic> future) async {
    // Note: Bottom sheet is already closed in handle_multiple_files_sheet.dart
    // No need to pop here as it would close the form page
    try {
      final data = await future;
      if (data != null) {
        List<File> tempFiles = [...multipleFiles];
        tempFiles.addAll(data);
        if (tempFiles.length >= 6) {
          return CommonSnackbar(
            text: "Max 5 Files are accepted",
          ).showAnimatedDialog(type: QuickAlertType.warning);
        } else {
          multipleFiles.addAll(await future);
          notifyListeners();
        }
      }
    } catch (err) {
      debugPrint("-------->$err");
    }
  }

  void removefile(int index) {
    multipleFiles.removeAt(index);
    notifyListeners();
  }

  onSearchChanged(String? query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (statusKey != null || dateKey != null) {
        statusKey = null;
        dateKey = null;
      }
      onRefresh();
    });
  }

  // Pagination

  final ScrollController scrollController = ScrollController();

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
      getWallOfHelpList();
    }
  }

  onRefresh() {
    _currentPage = 1;
    _isLastPage = false;
    getWallOfHelpList();
  }

  int _currentPage = 1;
  bool _isLastPage = false;

  bool _isScrollLoading = false;
  bool get isScrollLoading => _isScrollLoading;
  set isScrollLoading(bool value) {
    _isScrollLoading = value;
    notifyListeners();
  }

  Future<void> getWallOfHelpList() async {
    if (_currentPage == 1) {
      isLoading = true;
      wallOFHelpLists.clear();
    } else {
      isScrollLoading = true;
    }
    try {
      // Convert Hindi search to English before sending to API
      String? searchQuery = searchController.text.isEmpty 
          ? null 
          : _convertHindiToEnglishForSearch(searchController.text);
      
      final paginationModel = WOHPaginationModel(
        page: _currentPage,
        search: searchQuery,
        status: statusKey == "all" || statusKey == null ? null : statusKey,
        date: dateKey == "Recent"
            ? 7
            : dateKey == "One Month"
            ? 30
            : dateKey == "Six Months"
            ? 180
            : null,
      );
      final response = await WallOfHelpRepository().getUsersWallOFHelp(
        token: token,
        model: paginationModel,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data?.financialRequest;

        if (data?.isEmpty == true) {
          _isLastPage = true;
          return;
        }
        if (data?.isNotEmpty == true) {
          final rawItems = List<model.FinancialRequest>.from(data as List);
          
          // Translate items if app is in Hindi
          final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
          final translatedItems = isHindiLocale 
              ? await _translateFinancialRequests(rawItems)
              : rawItems;
          
          wallOFHelpLists.addAll(translatedItems);
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

  Future<bool> createFinancialHelp({
    String? urgency,
    String? typeOFHelp,
    String? preferredWay,
  }) async {
    try {
      if (formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        return false;
      }
      isLoading = true;

      final model = RequestFinancialHelpModel(
        name: nameController.text,
        phone: phoneController.text,
        amountRequested: int.tryParse(amountController.text) ?? 0,
        urgency: urgency,
        description: descriptionController.text,
        documents: multipleFiles.isEmpty
            ? []
            : await uploadMultipleImage(multipleFiles),
        typeOfHelpId: typeOFHelp,
        otherTypeOfHelp: otherTypeController.text,
        preferredWayForHelpId: preferredWay,
        otherPreferredWay: otherPreferredController.text,
        address: addressController.text,
        upi: upiIdController.text,
      );

      final response = await WallOfHelpRepository().createFinancialHelp(
        token: token,
        model: model,
      );

      if (response.data?.responseCode == 200) {
        await CommonSnackbar(
          text: response.data?.message ?? "Request sended successfully",
        ).showAnimatedDialog(type: QuickAlertType.success);
        // Clear form before returning success
        clear();
        // Refresh wall of help list cache to show the new request
        onRefresh();
        return true;
      } else {
        await CommonSnackbar(
          text: response.data?.message ?? "Something went wrong",
        ).showAnimatedDialog(type: QuickAlertType.warning);
        return false;
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<void> getTypes() async {
    try {
      final response = await repository.getHelpsDD(token);

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        typeOfHelpsList = List<types.Data>.from(data as List);
      } else {
        CommonSnackbar(
          text: response.data?.message ?? "Something went wrong",
        ).showToast();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }

  Future<void> getPreferred() async {
    try {
      final response = await repository.getPreferredWaysDD(token);

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        preferredWaysList = List<preferred.Data>.from(data as List);
      } else {
        CommonSnackbar(
          text: response.data?.message ?? "Something went wrong",
        ).showToast();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }

  clear() {
    // Reset form validation state first
    if (formKey.currentState != null) {
      formKey.currentState!.reset();
    }
    autoValidateMode = AutovalidateMode.disabled;
    
    // Clear all text controllers
    nameController.clear();
    phoneController.clear();
    addressController.clear();
    descriptionController.clear();
    amountController.clear();
    upiIdController.clear();
    otherTypeController.clear();
    otherPreferredController.clear();
    // Note: Don't clear searchController here as it's used in list view
    
    // Clear file list
    multipleFiles.clear();
    
    // Reset focus nodes
    if (nameFocus.hasFocus) nameFocus.unfocus();
    if (phoneFocus.hasFocus) phoneFocus.unfocus();
    if (addressFocus.hasFocus) addressFocus.unfocus();

    // Force notify listeners to update UI
    notifyListeners();
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
      'सहायता': 'help',
      'अनुरोध': 'request',
      'शीर्षक': 'title',
      'विवरण': 'description',
      'स्थिति': 'status',
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
}
