import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/mixin/handle_multiple_files_sheet.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/commom_text_form_field.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/features/nearest_member/model/nearest_members_model.dart';
import 'package:inldsevak/features/nearest_member/view_model/chat_member_view_model.dart';
import 'package:inldsevak/features/nearest_member/widgets/member_widget.dart';
import 'package:inldsevak/features/party_member/model/request/request_member_details.dart';
import 'package:inldsevak/features/party_member/services/party_member_repository.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/handle_chat_contribute_images_ui.dart';
import 'package:provider/provider.dart';

class ChatMemberView extends StatefulWidget {
  final PartyMember member;

  const ChatMemberView({super.key, required this.member});

  @override
  State<ChatMemberView> createState() => _ChatMemberViewState();
}

class _ChatMemberViewState extends State<ChatMemberView> with HandleMultipleFilesSheet {
  late PartyMember _member;
  bool _isLoadingMemberDetails = false;

  @override
  void initState() {
    super.initState();
    _member = widget.member;
    // Fetch member details if location is missing
    _fetchMemberDetailsIfNeeded();
  }

  Future<void> _fetchMemberDetailsIfNeeded() async {
    // Check current state
    final hasAddress = _member.address != null && _member.address!.trim().isNotEmpty;
    final hasCoordinates = _member.location?.coordinates != null && 
                           _member.location!.coordinates!.isNotEmpty &&
                           _member.location!.coordinates!.length >= 2;
    
    debugPrint("=== ChatMemberView - Checking member location ===");
    debugPrint("Member ID: ${_member.sId}");
    debugPrint("Member name: ${_member.name}");
    debugPrint("Has address: $hasAddress (value: '${_member.address}')");
    debugPrint("Has coordinates: $hasCoordinates (value: ${_member.location?.coordinates})");
    debugPrint("Phone: ${_member.phone}");
    
    // Only fetch if location and address are both missing
    if (!hasAddress && !hasCoordinates && _member.phone != null && _member.phone!.isNotEmpty) {
      debugPrint("=== Fetching member details for phone: ${_member.phone} ===");
      setState(() {
        _isLoadingMemberDetails = true;
      });
      
      try {
        final token = await SessionController.instance.getToken();
        if (token == null || token.isEmpty) {
          debugPrint("No token available, cannot fetch member details");
          return;
        }
        
        final request = RequestMemberDetails(phoneNumber: _member.phone!);
        final response = await PartyMemberRepository().getUserDetails(
          data: request,
          token: token,
        );

        debugPrint("API Response Code: ${response.data?.responseCode}");
        debugPrint("API Response Message: ${response.data?.message}");
        
        if (response.data?.responseCode == 200) {
          final user = response.data?.data?.user;
          debugPrint("User from API - address: '${user?.address}'");
          debugPrint("User from API - name: '${user?.name}'");
          
          if (user != null && mounted) {
            // Only update if we got a valid address
            final newAddress = (user.address != null && user.address!.trim().isNotEmpty) 
                ? user.address 
                : _member.address;
            
            debugPrint("Updating member - new address: '${newAddress}'");
            
            setState(() {
              // Update member with address from user details
              _member = PartyMember(
                sId: _member.sId ?? user.sId,
                name: _member.name ?? user.name,
                email: _member.email ?? user.email,
                phone: _member.phone ?? user.phone,
                address: newAddress,
                avatar: _member.avatar ?? user.avatar,
                location: _member.location, // User details don't have location coordinates
                distance: _member.distance,
                partyMemberDetails: _member.partyMemberDetails,
              );
            });
            
            debugPrint("Member updated - final address: '${_member.address}'");
          } else {
            debugPrint("User data is null in response");
          }
        } else {
          debugPrint("API error: ${response.data?.message}");
          if (response.error != null) {
            debugPrint("API error details: ${response.error}");
          }
        }
      } catch (e, stackTrace) {
        debugPrint("Exception fetching member details: $e");
        debugPrint("Stack trace: $stackTrace");
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingMemberDetails = false;
          });
          debugPrint("=== Finished fetching member details ===");
        }
      }
    } else {
      debugPrint("Skipping fetch - member already has location data or no phone");
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return ChangeNotifierProvider( 
      create: (context) => ChatMemberViewModel(
        id: _member.partyMemberDetails?.sId ?? "",
        type: _member.partyMemberDetails?.type ?? "PartyMember",
      ),
      builder: (contextP, widget) {
        final provider = contextP.watch<ChatMemberViewModel>();
        
        return Scaffold(
          appBar: commonAppBar(
            title: localization.contribute,
            scrollElevation: 0,
          ),
          body: Column(
            children: [
              if (_isLoadingMemberDetails)
                Container(
                  padding: EdgeInsets.all(Dimens.paddingX3),
                  child: Center(child: CustomAnimatedLoading()),
                )
              else
                MemberWidget(
                  key: ValueKey('${_member.sId}_${_member.address}'), // Force rebuild when member or address changes
                  showIcon: false,
                  member: _member,
                  onTap: () {},
                ).horizontalPadding(Dimens.paddingX3),
              Expanded(
                child: Container(
                  decoration: boxDecorationRoundedWithShadow(
                    Dimens.radiusX2,
                    border: BoxBorder.all(color: AppPalettes.primaryColor),
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: Dimens.paddingX3,
                    vertical: Dimens.paddingX3,
                  ),
                  child: provider.isLoading
                      ? Center(child: CustomAnimatedLoading())
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimens.paddingX4,
                          ),
                          shrinkWrap: false,
                          reverse: true,
                          separatorBuilder: (_, _) => SizeBox.sizeHX4,
                          itemBuilder: (context, index) {
                            final message = provider.messages[index];
                            bool showMessage = false;
                            if (message == provider.messages.last) {
                              showMessage = true;
                            } else {
                              showMessage =
                                  provider.messages[index + 1].date
                                      ?.toWhatsAppRelativeTime() !=
                                  provider.messages[index].date
                                      ?.toWhatsAppRelativeTime();
                            }
                            return Column(
                              crossAxisAlignment: message.isSent == true
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (showMessage)
                                  _buildDateHeader(
                                    message.date ?? "",
                                    textTheme,
                                  ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      Dimens.radiusX4,
                                    ),
                                    color: message.isSent == true
                                        ? AppPalettes.liteGreenColor
                                        : AppPalettes.backGroundColor,
                                  ),
                                  margin:
                                      EdgeInsets.symmetric(
                                        horizontal: Dimens.marginX2,
                                      ).copyWith(
                                        left: message.isSent == true
                                            ? Dimens.paddingX15
                                            : null,
                                        right: message.isSent != true
                                            ? Dimens.paddingX15
                                            : null,
                                      ),
                                  padding: message.isSent == true
                                      ? EdgeInsets.symmetric(
                                          horizontal: Dimens.paddingX5,
                                          vertical: Dimens.paddingX2,
                                        ).copyWith(right: Dimens.paddingX4)
                                      : EdgeInsets.symmetric(
                                          horizontal: Dimens.paddingX4,
                                          vertical: Dimens.paddingX2,
                                        ).copyWith(right: Dimens.paddingX5),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    spacing: Dimens.gap,
                                    children: [
                                      if (message.message != "")
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minWidth:
                                                message.documents?.isNotEmpty ==
                                                    true
                                                ? Dimens.screenWidth
                                                : Dimens.scale50,
                                          ),
                                          child: Text(
                                            message.message ?? "",
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: AppPalettes
                                                      .lightTextColor,
                                                ),
                                          ),
                                        ),
                                      if (message.message == "")
                                        SizeBox.sizeHX1,
                                      if (message.documents?.isNotEmpty == true)
                                        HandleChatContributeImagesUiWidget(
                                          documents: message.documents ?? [],
                                        ).verticalPadding(Dimens.paddingX1B),
                                      Text(
                                        (DateTime.tryParse(
                                                  message.date ?? "",
                                                ) ??
                                                DateTime.now())
                                            .add(
                                              Duration(hours: 5, minutes: 30),
                                            )
                                            .toString()
                                            .to12HourTime(),
                                        style: textTheme.labelMedium?.copyWith(
                                          color: AppPalettes.lightTextColor,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          itemCount: provider.messages.length,
                        ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.paddingX2,
                  vertical: Dimens.paddingX4,
                ),
                decoration: boxDecorationRoundedWithShadow(
                  Dimens.radius,
                  backgroundColor: AppPalettes.liteGreenColor,
                ),
                child: Row(
                  spacing: Dimens.gapX2,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: Dimens.paddingX2,
                        right: Dimens.paddingX1,
                        bottom: Dimens.paddingX,
                      ),
                      child: CommonHelpers.buildIcons(
                        path: AppImages.cameraIcon,
                        iconSize: Dimens.scaleX3,
                        iconColor: AppPalettes.primaryColor,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => DraggableSheetWidget(
                              size: 0.5,
                              child: selectMultipleFiles(
                                onTap: provider.addFiles,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: CommonTextFormField(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: Dimens.paddingX3,
                          vertical: Dimens.paddingX3B,
                        ),
                        radius: Dimens.radius100,
                        hintText: "Message",
                        controller: provider.messageController,
                        maxLines: 1,
                        suffixWidget: provider.multipleFiles.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(
                                  right: Dimens.paddingX2,
                                ),
                                child: Chip(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      Dimens.radiusX4,
                                    ),
                                    side: BorderSide(
                                      color: AppPalettes.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                  label: Text(
                                    "${provider.multipleFiles.length} Images",
                                  ),
                                  onDeleted: () => provider.removefiles(),
                                ),
                              )
                            : null,
                      ),
                    ),

                    Consumer<ChatMemberViewModel>(
                      builder: (context, value, _) {
                        return Container(
                          padding: EdgeInsets.all(Dimens.paddingX2B),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppPalettes.primaryColor,
                          ),
                          child: GestureDetector(
                            onTap: value.isLoading
                                ? () {}
                                : () {
                                    provider.replyMessage();
                                  },
                            child: value.isLoading
                                ? SizedBox(
                                    width: Dimens.scaleX3,
                                    height: Dimens.scaleX3,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppPalettes.whiteColor,
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                      left: Dimens.paddingX1,
                                    ),
                                    child: Icon(
                                      Icons.send,
                                      size: Dimens.scaleX3,
                                      color: AppPalettes.whiteColor,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateHeader(String dateText, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: Dimens.paddingX2),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.paddingX3,
          vertical: Dimens.paddingX1B,
        ),
        decoration: BoxDecoration(
          color: AppPalettes.primaryColor.withOpacityExt(0.1),
          borderRadius: BorderRadius.circular(Dimens.radiusX4),
        ),
        child: Text(
          dateText.toWhatsAppRelativeTime(),
          style: textTheme.bodySmall?.copyWith(
            color: AppPalettes.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
