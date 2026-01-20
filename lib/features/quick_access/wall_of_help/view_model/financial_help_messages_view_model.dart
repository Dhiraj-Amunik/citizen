import 'package:flutter/material.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/financial_help_messages_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/services/wall_of_help_repository.dart';

class FinancialHelpMessagesViewModel extends BaseViewModel {
  final WallOfHelpRepository repository = WallOfHelpRepository();

  List<FinancialHelpChatData> myFinancialHelpChats = [];
  int totalUnreadCount = 0;

  @override
  Future<void> onInit() async {
    await getMyFinancialHelpRequestMessages();
    return super.onInit();
  }

  Future<void> getMyFinancialHelpRequestMessages({
    String? page,
    String? pageSize,
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      
      final response = await repository.getMyFinancialHelpRequestMessages(
        token: token,
        page: page ?? "1",
        pageSize: pageSize ?? "124",
      );

      if (response.data?.responseCode == 200) {
        final inbox = response.data?.data?.inbox;
        myFinancialHelpChats.clear();
        
        if (inbox != null && inbox.isNotEmpty) {
          myFinancialHelpChats.addAll(inbox);
          
          // Calculate total unread count
          totalUnreadCount = inbox.fold<int>(
            0,
            (sum, chat) {
              final unread = chat.unreadCount ?? 0;
              return sum + unread;
            },
          );
        } else {
          totalUnreadCount = 0;
        }
      } else {
        totalUnreadCount = 0;
      }
    } catch (err, stackTrace) {
      debugPrint("Error fetching financial help messages: $err");
      debugPrint("Stack Trace: $stackTrace");
      totalUnreadCount = 0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onRefresh() async {
    await getMyFinancialHelpRequestMessages();
  }
}

