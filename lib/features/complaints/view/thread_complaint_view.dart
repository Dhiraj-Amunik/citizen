import 'package:flutter/material.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/features/complaints/model/response/complaint_by_thread.dart';
import 'package:inldsevak/features/complaints/model/thread_model.dart';
import 'package:inldsevak/features/complaints/view_model/thread_view_model.dart';
import 'package:inldsevak/features/complaints/widgets/painter.dart';
import 'package:provider/provider.dart';

class ThreadComplaintView extends StatelessWidget {
  final ThreadModel data;
  const ThreadComplaintView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: commonAppBar(
          title: (data.subject ?? ''),
          elevation: Dimens.elevation,
        ),

        body: ChangeNotifierProvider(
          create: (context) => ThreadViewModel(),
          child: Consumer<ThreadViewModel>(
            builder: (context, value, _) {
              return Column(
                children: [
                  Expanded(
                    child: FutureBuilder<List<Data>?>(
                      future: value.getThreads(threadID: data.threadID!),
                      builder: (context, AsyncSnapshot<List<Data>?> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return ListView.separated(
                          reverse: true,
                          itemBuilder: (context, index) {
                            final threadData = snapshot.data?[index];
                            return Column(
                              crossAxisAlignment:
                                  threadData?.from == "Citizen Team"
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                CustomPaint(
                                  painter: ChatBubbleCustomPainter(
                                    color: threadData?.from == "Citizen Team"
                                        ? AppPalettes.primaryColor
                                        : AppPalettes.lightTextColor,
                                    alignment:
                                        threadData?.from == "Citizen Team"
                                        ? Alignment.topRight
                                        : Alignment.bottomCenter,
                                  ),
                                  child: Container(
                                    padding: threadData?.from == "Citizen Team"
                                        ? const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ).copyWith(right: 24)
                                        : const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 8,
                                          ).copyWith(right: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          threadData?.snippet ?? "",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemCount: snapshot.data?.length ?? 0,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: value.nextThreadController,
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
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              value.replyThread(model: data);
                            },
                            icon: value.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: const Icon(Icons.send, color: Colors.white),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
