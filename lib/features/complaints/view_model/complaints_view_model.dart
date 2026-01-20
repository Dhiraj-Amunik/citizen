import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/complaints/model/request/my_complaint_request_model.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart'
    as complaint;
import 'package:inldsevak/features/complaints/repository/complaints_repository.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_departments_model.dart'
    as departments;
import 'package:inldsevak/l10n/general_stream.dart';

class ComplaintsViewModel extends BaseViewModel {
  ComplaintsViewModel() {
    // Don't call init() automatically - only initialize when needed
  }

  Timer? _autoRefreshTimer;
  bool _hasInitialized = false;
  bool _departmentsLoaded = false;
  Future<void>? _initializationFuture;

  // Override onInit to do nothing - we'll initialize manually when needed
  @override
  Future<void> onInit() async {
    // Don't do anything automatically - initialization happens lazily
    return super.onInit();
  }

  // Initialize only when complaints view is opened
  // This ensures token is loaded before any API calls
  Future<void> initializeIfNeeded() async {
    // If already initialized, wait for any ongoing initialization
    if (_initializationFuture != null) {
      await _initializationFuture;
      return;
    }
    
    // If not initialized, start initialization
    if (!_hasInitialized) {
      _hasInitialized = true;
      _initializationFuture = _performInitialization();
      await _initializationFuture;
    }
  }

  Future<void> _performInitialization() async {
    try {
      // Ensure BaseViewModel initialization is complete (token loaded)
      // BaseViewModel constructor calls initialize() but doesn't await it
      // So we need to ensure it's complete before proceeding
      if (token == null) {
        // If token is null, wait a bit and check again, or call initialize
        await initialize();
      }
      
      // Wait a bit to ensure token is loaded if BaseViewModel is still initializing
      int retries = 0;
      while (token == null && retries < 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }
      
      // Load departments when view is opened
      if (!_departmentsLoaded && token != null) {
        await getDepartments();
        _departmentsLoaded = true;
      }
    } catch (e) {
      log("Error during initialization: $e");
      _hasInitialized = false; // Allow retry on error
      _initializationFuture = null;
      rethrow;
    }
  }
  
  // Call this method when complaints view is opened
  Future<void> loadComplaintsIfNeeded() async {
    // First ensure base initialization is done (token loaded)
    await initializeIfNeeded();
    
    // Ensure token is available before making API call
    if (token == null) {
      log("⚠️ Token is null, cannot load complaints");
      return;
    }
    
    // Then load complaints if not already loaded
    if (complaintsList.isEmpty) {
      await getComplaints();
    }
  }

  //Filters

  final fromDate = TextEditingController();
  final toDate = TextEditingController();

  List<String>? selectedStatusList = [];
  departments.Data? departmentKey;
  String? date;
  String? fromDateCompany;
  String? toDateCompany;
  String? selectedDateFilter; // Track selected date filter: "today", "week", "month", or null

  // Filter sheet status options
  List<String> complaintFilterList = [
    "Pending",
    "In-progress",
    "Resolved",
    "Escalated",
  ];

  List<complaint.Data> complaintsList = [];
  List<complaint.Data> filteredComplaintsList = [];
  List<departments.Data> departmentLists = [];
  int totalUnreadCount = 0;
  int followUpDueCount = 0; // Count of complaints with isFollowUpDue == true

  final searchController = TextEditingController();

  setStatus(String status) {
    if (selectedStatusList?.contains(status) == true) {
      selectedStatusList?.remove(status);
    } else {
      selectedStatusList?.add(status);
    }
    notifyListeners();
  }

  Future<void> getComplaints({
    bool showLoader = true,
    bool preserveSearch = false,
  }) async {
    try {
      log("🔵 getComplaints() called - showLoader: $showLoader, preserveSearch: $preserveSearch");
      
      // Ensure initialization is complete before making API call
      await initializeIfNeeded();
      
      // Check if token is available
      if (token == null || token!.isEmpty) {
        log("⚠️ Token is null or empty, cannot fetch complaints");
        CommonSnackbar(text: "Unable to authenticate. Please try again.").showSnackbar();
        return;
      }
      
      if (showLoader) {
        isLoading = true;
      }
      if (!preserveSearch) {
        searchController.clear();
      }
      log("Token: ${token?.substring(0, 20)}...");

      final filters = MyComplaintRequestModel(
        status: selectedStatusList,
        departmentId: departmentKey?.sId,
        date: fromDateCompany != null || toDateCompany != null ? "custom" : "",
        startDate: fromDateCompany ?? toDateCompany,
        endDate: toDateCompany ?? fromDateCompany,
        limit: 100,
      );
      final response = await ComplaintsRepository().getAllComplaints(
        token: token ?? '',
        filters: filters,
      );

      if (response.data?.responseCode == 200) {
        // Use dynamic to handle changed API response structure
        final dynamic responseData = response.data?.data;
        filteredComplaintsList.clear();
        
        // Handle changed API response structure
        List<complaint.Data> rawComplaints = [];
        
        if (responseData == null) {
          log("⚠️ API response data is null");
          complaintsList = [];
          filteredComplaintsList = [];
          notifyListeners();
          return;
        }
        
        // Check if data is a List
        if (responseData is List) {
          try {
            // Parse each item in the list
            rawComplaints = responseData.map((item) {
              if (item is Map<String, dynamic>) {
                return complaint.Data.fromJson(item);
              } else if (item is complaint.Data) {
                return item;
              } else {
                log("⚠️ Unexpected item type in complaints list: ${item.runtimeType}");
                return null;
              }
            }).whereType<complaint.Data>().toList();
          } catch (e, stackTrace) {
            log("❌ Error parsing complaints list: $e");
            debugPrint("Stack Trace: $stackTrace");
            CommonSnackbar(text: "Error parsing complaints data").showSnackbar();
            complaintsList = [];
            filteredComplaintsList = [];
            notifyListeners();
            return;
          }
        } else if (responseData is Map<String, dynamic>) {
          // Handle case where data might be wrapped in an object
          // Check for common keys like 'complaints', 'data', 'items', 'results'
          final possibleKeys = ['complaints', 'data', 'items', 'results', 'list'];
          bool found = false;
          
          for (final key in possibleKeys) {
            if (responseData.containsKey(key) && responseData[key] is List) {
              try {
                rawComplaints = (responseData[key] as List).map((item) {
                  if (item is Map<String, dynamic>) {
                    return complaint.Data.fromJson(item);
                  } else if (item is complaint.Data) {
                    return item;
                  } else {
                    return null;
                  }
                }).whereType<complaint.Data>().toList();
                found = true;
                log("✅ Found complaints in key: $key");
                break;
              } catch (e) {
                log("⚠️ Error parsing complaints from key $key: $e");
              }
            }
          }
          
          if (!found) {
            // Try to parse the entire map as a single complaint
            try {
              final singleComplaint = complaint.Data.fromJson(responseData);
              rawComplaints = [singleComplaint];
              log("✅ Parsed single complaint from response");
            } catch (e) {
              log("❌ Could not parse complaints from response structure");
              debugPrint("Response data structure: ${responseData.keys.toList()}");
              CommonSnackbar(text: "Unexpected response format").showSnackbar();
              complaintsList = [];
              filteredComplaintsList = [];
              notifyListeners();
              return;
            }
          }
        } else {
          log("❌ Unexpected data type: ${responseData.runtimeType}");
          CommonSnackbar(text: "Unexpected response format").showSnackbar();
          complaintsList = [];
          filteredComplaintsList = [];
          notifyListeners();
          return;
        }
        
        log("✅ Successfully parsed ${rawComplaints.length} complaints");
        
        // Sort complaints by date (newest first)
        // Priority: createdAt > updatedAt > first message date
        rawComplaints.sort((a, b) {
          DateTime? dateA;
          DateTime? dateB;
          
          // Try to get date from createdAt first
          if (a.createdAt != null && a.createdAt!.isNotEmpty) {
            try {
              dateA = DateTime.parse(a.createdAt!);
            } catch (e) {
              log("⚠️ Error parsing createdAt for complaint A: $e");
            }
          }
          
          if (b.createdAt != null && b.createdAt!.isNotEmpty) {
            try {
              dateB = DateTime.parse(b.createdAt!);
            } catch (e) {
              log("⚠️ Error parsing createdAt for complaint B: $e");
            }
          }
          
          // If createdAt not available, try updatedAt
          if (dateA == null && a.updatedAt != null && a.updatedAt!.isNotEmpty) {
            try {
              dateA = DateTime.parse(a.updatedAt!);
            } catch (e) {
              log("⚠️ Error parsing updatedAt for complaint A: $e");
            }
          }
          
          if (dateB == null && b.updatedAt != null && b.updatedAt!.isNotEmpty) {
            try {
              dateB = DateTime.parse(b.updatedAt!);
            } catch (e) {
              log("⚠️ Error parsing updatedAt for complaint B: $e");
            }
          }
          
          // If still not available, try first message date
          if (dateA == null && a.messages?.isNotEmpty == true) {
            final messageDate = a.messages!.first.date;
            if (messageDate != null && messageDate.isNotEmpty) {
              try {
                dateA = DateTime.parse(messageDate);
              } catch (e) {
                log("⚠️ Error parsing message date for complaint A: $e");
              }
            }
          }
          
          if (dateB == null && b.messages?.isNotEmpty == true) {
            final messageDate = b.messages!.first.date;
            if (messageDate != null && messageDate.isNotEmpty) {
              try {
                dateB = DateTime.parse(messageDate);
              } catch (e) {
                log("⚠️ Error parsing message date for complaint B: $e");
              }
            }
          }
          
          // If both dates are null, keep original order
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1; // Put null dates at the end
          if (dateB == null) return -1; // Put null dates at the end
          
          // Sort in descending order (newest first)
          return dateB.compareTo(dateA);
        });
        
        log("✅ Sorted complaints by date (newest first)");
        
        // Calculate total unread count from RAW data BEFORE translation
        // This ensures count is always accurate regardless of translation success/failure
        totalUnreadCount = 0;
        followUpDueCount = 0;
        bool hasUnreadMessages = false;
        
        for (final complaint in rawComplaints) {
          // Add unreadMessageCount from complaint
          final complaintUnreadCount = complaint.unreadMessageCount ?? 0;
          totalUnreadCount += complaintUnreadCount;
          
          // Count complaints with isFollowUpDue == true as notifications
          if (complaint.isFollowUpDue == true) {
            followUpDueCount++;
          }
          
          // Also check individual messages for isRead: false
          if (complaint.messages != null && complaint.messages!.isNotEmpty) {
            for (final message in complaint.messages!) {
              // Check if message has isRead: false
              if (message.isRead == false) {
                hasUnreadMessages = true;
                break; // Found at least one unread message
              }
            }
          }
          
          // If unreadMessageCount > 0, we have unread messages
          if (complaintUnreadCount > 0) {
            hasUnreadMessages = true;
          }
        }
        
        // Include follow-up due count in total unread count
        totalUnreadCount += followUpDueCount;
        
        log("📬 Total complaints unread message count (calculated from raw): $totalUnreadCount (hasUnread: $hasUnreadMessages, followUpDue: $followUpDueCount)");
        
        // IMPORTANT: Show complaints immediately with raw data (unread count already calculated)
        // This ensures fast UI response - users see data right away
        complaintsList = rawComplaints;
        log("📝 Showing complaints immediately (count: ${complaintsList.length}) - unread count: $totalUnreadCount");
        
        // Notify listeners immediately so UI can show data
        notifyListeners();
        
        // Translate complaints in background if app is in Hindi (non-blocking)
        // This allows UI to show immediately while translation happens in background
        final isHindiLocale = GeneralStream.instance.locale.languageCode == 'hi';
        if (isHindiLocale && rawComplaints.isNotEmpty) {
          // Translate in background without blocking UI
          _translateComplaintsInBackground(rawComplaints).catchError((error) {
            log("🔴 Background translation error: $error");
            // Keep original complaints if translation fails
          });
        }
        
        log("📋 Final complaintsList length: ${complaintsList.length}");
        
        // Always populate filtered list with complaints list
        if (searchController.text.trim().isNotEmpty) {
          filterList();
        } else {
          filteredComplaintsList.clear();
          filteredComplaintsList.addAll(complaintsList);
          log("📋 Populated filteredComplaintsList with ${filteredComplaintsList.length} complaints");
          notifyListeners();
        }
      } else {
        final errorMessage = response.data?.message ?? "Unable to fetch Complaints";
        log("❌ API returned error: ${response.data?.responseCode} - $errorMessage");
        CommonSnackbar(text: errorMessage).showSnackbar();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      if (showLoader) {
        isLoading = false;
      }
    }
  }

  Future<void> getDepartments() async {
    try {
      // Ensure token is available
      if (token == null || token!.isEmpty) {
        log("⚠️ Token is null or empty, cannot fetch departments");
        return;
      }
      
      final response = await ComplaintsRepository().getDepartments(token);

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data?.isEmpty == true) {
          CommonSnackbar(text: "No departments found").showToast();
        } else {
          departmentLists = List<departments.Data>.from(data as List);
          notifyListeners();
        }
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }

  filterList() {
    final searchQuery = searchController.text.trim();
    
    // If search is empty, show all
    if (searchQuery.isEmpty) {
      filteredComplaintsList.clear();
      filteredComplaintsList.addAll(complaintsList);
      notifyListeners();
      return;
    }

    // Convert Hindi to English for search matching
    final englishQuery = _convertHindiToEnglish(searchQuery).toLowerCase();
    final originalQuery = searchQuery.toLowerCase();

    // Filter complaints
    filteredComplaintsList.clear();
    filteredComplaintsList.addAll(
      complaintsList.where((complaint) {
        return _matchesSearch(complaint, englishQuery, originalQuery);
      }),
    );

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
      'शिकायत': 'complaint',
      'विषय': 'subject',
      'विवरण': 'description',
      'स्थिति': 'status',
      'लंबित': 'pending',
      'प्रगति में': 'in-progress',
      'हल': 'resolved',
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

  bool _matchesSearch(complaint.Data complaint, String englishQuery, String originalQuery) {
    // Get complaint ID for search (always available)
    final complaintId = complaint.sId?.toLowerCase() ?? '';
    
    // Search in complaint ID first (exact match for IDs)
    if (complaintId.contains(englishQuery) || complaintId.contains(originalQuery)) {
      return true;
    }
    
    // Get subject and body from first message if available
    String subject = '';
    String body = '';
    
    if (complaint.messages != null && complaint.messages!.isNotEmpty) {
      final firstMessage = complaint.messages!.first;
      subject = firstMessage.subject?.toLowerCase() ?? '';
      body = firstMessage.normalizedBody?.toLowerCase() ?? 
             firstMessage.body?.toLowerCase() ?? '';
    }

    // Search using English query (transliterated from Hindi if needed)
    // Also try original query in case it's already in English
    // Search in subject and body
    return subject.contains(englishQuery) ||
        body.contains(englishQuery) ||
        subject.contains(originalQuery) ||
        body.contains(originalQuery);
  }

  /// Translate complaints in background without blocking UI
  /// Updates complaintsList progressively as translations complete
  Future<void> _translateComplaintsInBackground(List<complaint.Data> rawComplaints) async {
    log("🔄 Starting background translation of ${rawComplaints.length} complaints...");
    
    try {
      // Translate complaints in batches to update UI progressively
      // Translate first 5 complaints immediately, then continue with rest
      final batchSize = 5;
      final translatedComplaints = <complaint.Data>[];
      
      for (int i = 0; i < rawComplaints.length; i += batchSize) {
        final batch = rawComplaints.skip(i).take(batchSize).toList();
        final batchEnd = (i + batchSize < rawComplaints.length) ? i + batchSize : rawComplaints.length;
        
        log("🔄 Translating batch ${i ~/ batchSize + 1} (items ${i + 1}-$batchEnd of ${rawComplaints.length})...");
        
        // Translate batch in parallel
        final batchFutures = batch.map((complaintItem) async {
          try {
            if (complaintItem.messages == null || complaintItem.messages!.isEmpty) {
              return complaintItem;
            }
            final firstMessage = complaintItem.messages!.first;
            
            // Translate subject, body, and snippet
            String translatedSubject = firstMessage.subject ?? '';
            String translatedBody = firstMessage.normalizedBody ?? firstMessage.body ?? '';
            String translatedSnippet = firstMessage.snippet ?? '';
            
            try {
              translatedSubject = await TranslationHelper.translateText(
                firstMessage.subject,
                force: true,
              ).timeout(const Duration(seconds: 5), onTimeout: () => firstMessage.subject ?? '');
              
              if (translatedSubject.isEmpty) {
                translatedSubject = firstMessage.subject ?? '';
              }
            } catch (e) {
              log("⚠️ Error translating subject: $e");
              translatedSubject = firstMessage.subject ?? '';
            }
            
            try {
              final bodyText = firstMessage.normalizedBody ?? firstMessage.body;
              translatedBody = await TranslationHelper.translateText(
                bodyText,
                force: true,
              ).timeout(const Duration(seconds: 5), onTimeout: () => bodyText ?? '');
              
              if (translatedBody.isEmpty) {
                translatedBody = bodyText ?? '';
              }
            } catch (e) {
              log("⚠️ Error translating body: $e");
              translatedBody = firstMessage.normalizedBody ?? firstMessage.body ?? '';
            }
            
            try {
              translatedSnippet = await TranslationHelper.translateText(
                firstMessage.snippet,
                force: true,
              ).timeout(const Duration(seconds: 5), onTimeout: () => firstMessage.snippet ?? '');
              
              if (translatedSnippet.isEmpty) {
                translatedSnippet = firstMessage.snippet ?? '';
              }
            } catch (e) {
              log("⚠️ Error translating snippet: $e");
              translatedSnippet = firstMessage.snippet ?? '';
            }
            
            // Create translated complaint
            final translatedMessageMap = <String, dynamic>{
              'from': firstMessage.from,
              'to': firstMessage.to,
              'subject': translatedSubject,
              'snippet': translatedSnippet,
              'date': firstMessage.date,
              'body': translatedBody,
              if (firstMessage.attachments != null)
                'attachments': firstMessage.attachments!.map((a) => a.toJson()).toList(),
              '_id': firstMessage.sId,
              if (firstMessage.profileImage != null) 'profileImage': firstMessage.profileImage,
              if (firstMessage.senderName != null) 'senderName': firstMessage.senderName,
              if (firstMessage.userImage != null) 'userImage': firstMessage.userImage,
            };
            
            final translatedMessage = complaint.Messages.fromJson(translatedMessageMap);
            final translatedMessages = [
              translatedMessage,
              ...(complaintItem.messages?.skip(1).toList() ?? []),
            ];
            
            final translatedComplaintMap = {
              '_id': complaintItem.sId,
              'userId': complaintItem.userId?.toJson(),
              'user': complaintItem.user?.toJson(),
              'department': complaintItem.department?.toJson(),
              'authorityName': complaintItem.authorityName,
              'threadId': complaintItem.threadId,
              'toMail': complaintItem.toMail,
              'messages': translatedMessages.map((m) => m.toJson()).toList(),
              'status': complaintItem.status,
              'isActive': complaintItem.isActive,
              'lastSyncedAt': complaintItem.lastSyncedAt,
              'createdAt': complaintItem.createdAt,
              'updatedAt': complaintItem.updatedAt,
              '__v': complaintItem.iV,
              'isFollowUpDue': complaintItem.isFollowUpDue,
            };
            
            return complaint.Data.fromJson(translatedComplaintMap);
          } catch (e) {
            log("🔴 Error translating complaint: $e");
            return complaintItem; // Return original on error
          }
        }).toList();
        
        // Wait for batch to complete
        final batchResults = await Future.wait(batchFutures);
        translatedComplaints.addAll(batchResults);
        
        // Update UI with translated complaints so far (merge with remaining untranslated)
        final remainingUntranslated = rawComplaints.skip(translatedComplaints.length).toList();
        complaintsList = [...translatedComplaints, ...remainingUntranslated];
        
        // Update filtered list
        if (searchController.text.trim().isEmpty) {
          filteredComplaintsList.clear();
          filteredComplaintsList.addAll(complaintsList);
        } else {
          filterList();
        }
        
        // Notify listeners to update UI
        notifyListeners();
        
        log("✅ Translated ${translatedComplaints.length} of ${rawComplaints.length} complaints");
      }
      
      log("✅ Background translation completed: ${translatedComplaints.length} complaints translated");
    } catch (e, stackTrace) {
      log("🔴 Background translation error: $e");
      debugPrint("Stack Trace: $stackTrace");
      // Keep original complaints on error
    }
  }

  void determineSelectedFilter(String type) {
    final now = DateTime.now();
    final week = now.subtract(const Duration(days: 6));
    final month = now.subtract(const Duration(days: 30));

    // Set the selected filter type
    selectedDateFilter = type;
    
    switch (type) {
      case "today":
        fromDateCompany = now.toString().toYyyyMmDd();
        fromDate.text = fromDateCompany?.toDdMmYyyy() ?? "";
        toDate.text = fromDate.text;
        toDateCompany = fromDateCompany;
        break;
      case "week":
        fromDateCompany = week.toString().toYyyyMmDd();
        toDateCompany = now.toString().toYyyyMmDd();
        fromDate.text = fromDateCompany?.toDdMmYyyy() ?? "";
        toDate.text = toDateCompany?.toDdMmYyyy() ?? "";
        break;
      case "month":
        fromDateCompany = month.toString().toYyyyMmDd();
        toDateCompany = now.toString().toYyyyMmDd();
        fromDate.text = fromDateCompany?.toDdMmYyyy() ?? "";
        toDate.text = toDateCompany?.toDdMmYyyy() ?? "";
        break;
    }
    notifyListeners();
  }

  // Auto-refresh disabled - only call getComplaints when user explicitly requests it
  // void _startAutoRefresh() {
  //   _autoRefreshTimer?.cancel();
  //   _autoRefreshTimer = Timer.periodic(
  //     const Duration(seconds: 30),
  //     (_) => getComplaints(showLoader: false, preserveSearch: true),
  //   );
  // }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    searchController.dispose();
    fromDate.dispose();
    toDate.dispose();
    super.dispose();
  }
}
