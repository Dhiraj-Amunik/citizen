import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/features/complaints/model/thread_model.dart';
import 'package:inldsevak/features/complaints/view_model/thread_view_model.dart';
import 'package:inldsevak/features/complaints/widgets/painter.dart';
import 'package:provider/provider.dart';

class ThreadComplaintView extends StatelessWidget {
  final ThreadModel data;
  const ThreadComplaintView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: commonAppBar(
          title: (data.subject ?? ''),
          elevation: Dimens.elevation,
        ),
        body: ChangeNotifierProvider(
          create: (context) => ThreadViewModel(arguments: data),
          builder: (contextP, child) {
            final provider = contextP.watch<ThreadViewModel>();
            if (provider.loadMessages) {
              return Center(child: CustomAnimatedLoading());
            }
            return Column(
              spacing: Dimens.gapX2,
              children: [
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final threadData = provider.threadsList[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          left: threadData.from == "anusha.flyferry@gmail.com"
                              ? Dimens.paddingX8
                              : Dimens.padding,
                          right: threadData.from != "anusha.flyferry@gmail.com"
                              ? Dimens.paddingX8
                              : Dimens.padding,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              threadData.from == "anusha.flyferry@gmail.com"
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            CustomPaint(
                              painter: ChatBubbleCustomPainter(
                                color:
                                    threadData.from ==
                                        "anusha.flyferry@gmail.com"
                                    ? AppPalettes.liteGreenColor
                                    : AppPalettes.backGroundColor,
                                alignment:
                                    threadData.from ==
                                        "anusha.flyferry@gmail.com"
                                    ? Alignment.topRight
                                    : Alignment.bottomCenter,
                              ),
                              child: Container(
                                padding:
                                    threadData.from ==
                                        "anusha.flyferry@gmail.com"
                                    ? const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ).copyWith(right: 24)
                                    : const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 8,
                                      ).copyWith(right: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      threadData.from ==
                                              "anusha.flyferry@gmail.com"
                                          ? threadData.snippet ?? ""
                                          : threadData.snippet
                                                    ?.split('On')
                                                    .sublist(
                                                      0,
                                                      threadData.snippet!
                                                              .split('On')
                                                              .length -
                                                          1,
                                                    )
                                                    .join('On') ??
                                                "",
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: AppPalettes.lightTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemCount: provider.threadsList.length,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    spacing: Dimens.gapX2,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: provider.nextThreadController,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Type your reply...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      Consumer<ThreadViewModel>(
                        builder: (context, value, _) {
                          return Container(
                            decoration: boxDecorationRoundedWithShadow(
                              Dimens.radius100,
                              backgroundColor: AppPalettes.primaryColor,
                            ),
                            child: IconButton(
                              onPressed: value.isLoading
                                  ? () {}
                                  : () {
                                      provider.replyThread(model: data);
                                    },
                              icon: value.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: const Icon(
                                        Icons.send,
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
