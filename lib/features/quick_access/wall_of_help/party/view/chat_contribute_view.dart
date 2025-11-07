import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/mixin/handle_multiple_files_sheet.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/commom_text_form_field.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/get_help_details.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/handle_chat_contribute_images_ui.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/chat_contribute_help_view_model.dart';
import 'package:provider/provider.dart';

class ChatContributeView extends StatelessWidget with HandleMultipleFilesSheet {
  final model.FinancialRequest helpRequest;

  const ChatContributeView({super.key, required this.helpRequest});

  @override
  Widget build(BuildContext context) {
    log(helpRequest.toJson().toString());
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return ChangeNotifierProvider(
      create: (context) =>
          ChatContributeHelpViewModel(arguments: helpRequest.messageId ?? ""),
      builder: (contextP, widget) {
        final provider = contextP.watch<ChatContributeHelpViewModel>();

        return Scaffold(
          appBar: commonAppBar(
            title: localization.contribute,
            scrollElevation: 0,
          ),
          body: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: Dimens.paddingX3),
                padding: EdgeInsets.all(Dimens.paddingX3B),
                decoration: boxDecorationRoundedWithShadow(
                  Dimens.radiusX3,
                  border: Border.all(color: AppPalettes.primaryColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Dimens.gapX1B,
                  children: [
                    Text(
                      "${localization.request_details} :",
                      style: textTheme.headlineSmall,
                    ),
                    SizeBox.size,
                    getHelpDetails(
                      text: localization.name,
                      desc: helpRequest.name,
                    ),
                    getHelpDetails(
                      text: localization.location,
                      desc: helpRequest.address,
                    ),
                    getHelpDetails(
                      text: localization.category,
                      desc: helpRequest.typeOfHelp?.name?.capitalize(),
                    ),
                    getHelpDetails(
                      text: localization.description,
                      desc: helpRequest.description,
                    ),
                  ],
                ),
              ),
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

                    Consumer<ChatContributeHelpViewModel>(
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
                                    provider.replyMessage(
                                      financialID: helpRequest.sId ?? ""
                                    );
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
