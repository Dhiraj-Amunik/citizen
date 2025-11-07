import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/mixin/handle_multiple_files_sheet.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/commom_text_form_field.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/features/complaints/view_model/thread_view_model.dart';
import 'package:inldsevak/features/complaints/widgets/complaint_widget.dart';
import 'package:inldsevak/features/complaints/widgets/handle_threads_images.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart';

class ThreadComplaintView extends StatefulWidget {
  final Data data;
  const ThreadComplaintView({super.key, required this.data});

  @override
  State<ThreadComplaintView> createState() => _ThreadComplaintViewState();
}

class _ThreadComplaintViewState extends State<ThreadComplaintView>
    with HandleMultipleFilesSheet {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;
    // final threadIndex = context.read<ThreadIndexBuilder>();
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: commonAppBar(
          child: Text(
            widget.data.messages?.first.subject?.capitalize() ?? '',
            style: textTheme.headlineMedium,
            overflow: TextOverflow.ellipsis,
          ).horizontalPadding(Dimens.horizontalspacing),
          scrollElevation: 0,
        ),

        body: ChangeNotifierProvider(
          create: (context) => ThreadViewModel(arguments: widget.data),
          builder: (contextP, child) {
            final provider = contextP.watch<ThreadViewModel>();
            if (provider.loadMessages) {
              return Center(child: CustomAnimatedLoading());
            }
            return Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ComplaintThreadWidget(
                        showAuthority: true,
                        thread: widget.data,
                        onTap: () {},
                      ).symmetricPadding(horizontal: Dimens.paddingX3),
                      Expanded(
                        child: Container(
                          decoration: boxDecorationRoundedWithShadow(
                            Dimens.radiusX2,
                            border: BoxBorder.all(
                              color: AppPalettes.primaryColor,
                            ),
                          ),
                          margin: EdgeInsets.symmetric(
                            horizontal: Dimens.paddingX3,
                            vertical: Dimens.paddingX3,
                          ),
                          child: ListView.builder(
                            shrinkWrap: false,
                            reverse: true,
                            controller: scrollController,
                            itemBuilder: (context, index) {
                              final threadData =
                                  provider.threadsList[index];
                              return Column(
                                crossAxisAlignment:
                                    threadData.from ==
                                        "ajay.amunik@gmail.com"
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        Dimens.radiusX4,
                                      ),
                                      color:
                                          threadData.from ==
                                              "ajay.amunik@gmail.com"
                                          ? AppPalettes.liteGreenColor
                                          : AppPalettes.backGroundColor,
                                    ),
                                    margin:
                                        EdgeInsets.symmetric(
                                          horizontal: Dimens.marginX2,
                                          vertical: Dimens.marginX2,
                                        ).copyWith(
                                          left:
                                              threadData.from ==
                                                  "ajay.amunik@gmail.com"
                                              ? Dimens.marginX8
                                              : null,
                                          right:
                                              threadData.from ==
                                                  "ajay.amunik@gmail.com"
                                              ?null
                                              :  Dimens.marginX8,
                                        ),
                                    padding:
                                        threadData.from ==
                                            "ajay.amunik@gmail.com"
                                        ? const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ).copyWith(right: 24)
                                        : const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 8,
                                          ).copyWith(right: 16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          threadData.from ==
                                              "ajay.amunik@gmail.com"
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      spacing: Dimens.gapX,
                                      children: [
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minWidth: 50.width(),
                                          ),
                                          child: Text(
                                            threadData.from ==
                                                    "ajay.amunik@gmail.com"
                                                ? threadData.snippet ?? ""
                                                : threadData.snippet
                                                          ?.split('On')
                                                          .sublist(
                                                            0,
                                                            threadData
                                                                    .snippet!
                                                                    .split(
                                                                      'On',
                                                                    )
                                                                    .length -
                                                                1,
                                                          )
                                                          .join('On') ??
                                                      "",
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: AppPalettes
                                                      .lightTextColor,
                                                ),
                                          ),
                                        ),
                                        if (threadData
                                                .attachments
                                                ?.isNotEmpty ==
                                            true)
                                          HandleThreadsImages(
                                            attachment:
                                                threadData.attachments ??
                                                [],
                                          ).verticalPadding(
                                            Dimens.paddingX1B,
                                          ),
                                        Text(
                                          (DateTime.tryParse(
                                                    threadData.date ?? "",
                                                  ) ??
                                                  DateTime.now())
                                              .add(
                                                Duration(
                                                  hours: 5,
                                                  minutes: 30,
                                                ),
                                              )
                                              .toString()
                                              .to12HourTime(),
                                          style: textTheme.labelMedium
                                              ?.copyWith(
                                                color: AppPalettes
                                                    .lightTextColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // ),
                                ],
                                // ),
                              );
                            },
                          
                            itemCount: provider.threadsList.length,
                          ),
                        ),
                      ),
                    ],
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
                          hintText: localization.message,
                          controller: provider.nextThreadController,
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
                                      "${provider.multipleFiles.length} ${localization.images}",
                                    ),
                                    onDeleted: () => provider.removefiles(),
                                  ),
                                )
                              : null,
                        ),
                      ),

                      Consumer<ThreadViewModel>(
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
                                      provider.replyThread(
                                        id: widget.data.sId ?? "",
                                      );
                                    },
                              child: value.isLoading
                                  ? SizedBox(
                                      width: Dimens.scaleX3,
                                      height: Dimens.scaleX3,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
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
                                        color: Colors.white,
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
            );
          },
        ),
      ),
    );
  }
}
