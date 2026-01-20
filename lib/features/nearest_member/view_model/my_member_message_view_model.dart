import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/features/nearest_member/model/my_member_chat_model.dart'
    as model;
import 'package:inldsevak/features/nearest_member/services/nearest_member_repository.dart';

class MyMemberMessageViewModel extends BaseViewModel {

  @override
  Future<void> onInit() async {
    // Only fetch chats if token is available
    // This prevents errors on app startup when token might not be ready
    if (token != null && token!.isNotEmpty) {
      getAllChats();
    }
    return super.onInit();
  }

  final NearestMemberRepository repository = NearestMemberRepository();

  List<model.Data> myChatsList = [];
  int totalUnreadCount = 0;

  Future<void> getAllChats() async {
    // Don't fetch if token is not available
    if (token == null || token!.isEmpty) {
      debugPrint("📬 ⚠️ Token not available, skipping getAllChats");
      return;
    }
    
    try {
      isLoading = true;
      notifyListeners();
      debugPrint("📬 Fetching all chats...");
      final response = await repository.getMyChats(token: token, );

      debugPrint("📬 Response received - has data: ${response.data != null}");
      debugPrint("📬 Response has error: ${response.error != null}");
      if (response.error != null) {
        debugPrint("📬 Error message: ${response.error?.message}");
      }
      debugPrint("📬 Response code: ${response.data?.responseCode}");
      debugPrint("📬 Response message: ${response.data?.message}");
      debugPrint("📬 Response data field: ${response.data?.data}");
      debugPrint("📬 Response data is null: ${response.data?.data == null}");
      debugPrint("📬 Response data type: ${response.data?.data.runtimeType}");
      
      // Check for API errors first
      if (response.error != null) {
        debugPrint("📬 ❌ API Error: ${response.error?.message}");
        // Don't show error dialog on initial load - let it fail silently
        // The user can retry by refreshing or navigating away and back
        return;
      }
      
      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        
        debugPrint("📬 Extracted data: $data");
        debugPrint("📬 Data is null: ${data == null}");
        debugPrint("📬 Data is List: ${data is List}");
        if (data != null) {
          debugPrint("📬 Data length: ${data.length}");
        }

        // Store total unread count from API response
        totalUnreadCount = response.data?.totalUnreadCount ?? 0;
        debugPrint("📬 Total unread count: $totalUnreadCount");

        myChatsList.clear();
        if (data != null) {
          myChatsList.addAll(data);
          if (data.isNotEmpty) {
            debugPrint("📬 ✅ Loaded ${myChatsList.length} chats successfully");
          } else {
            debugPrint("📬 ⚠️ Data array is empty (no chats)");
          }
        } else {
          debugPrint("📬 ❌ Data is null - check model parsing");
          debugPrint("📬 Response.data: ${response.data}");
          debugPrint("📬 Response.data?.data: ${response.data?.data}");
        }
        notifyListeners();
      } else {
        debugPrint("📬 ❌ Response code is not 200: ${response.data?.responseCode}");
        // Don't show error dialog on initial load - let it fail silently
        // The user can retry by refreshing
      }
    } catch (err, stackTrace) {
      debugPrint("📬 ❌ Error fetching chats: $err");
      debugPrint("Stack Trace: $stackTrace");
      // Don't show error dialog on catch - let it fail silently on initial load
      // The user can retry by refreshing
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
