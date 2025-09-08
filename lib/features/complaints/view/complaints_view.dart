import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart';
import 'package:inldsevak/features/complaints/model/thread_model.dart';
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:inldsevak/features/complaints/widgets/complaint_widget.dart';
import 'package:provider/provider.dart';

class ComplaintsView extends StatelessWidget {
  const ComplaintsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(
        title: "My Complaints",
        action: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<ComplaintsViewModel>().getComplaints(),
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.paddingX3),
        child: Consumer<ComplaintsViewModel>(
          builder: (context, value, child) {
            if (value.isLoading) {
              return Center(child: CustomAnimatedLoading());
            }
            return RefreshIndicator(
              onRefresh: () => value.getComplaints(),
              child: _buildComplaintsList(value.complaintsList),
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          RouteManager.pushNamed(Routes.lodgeComplaintPage);
        },
        icon: const Icon(Icons.add),
        label: const Text('Raise Complaint'),
      ),
    );
  }

  Widget _buildComplaintsList(List<Data> complaintList) {
    if (complaintList.isEmpty) {
      return Center(
        child: Text("No Complaints Found", style: AppStyles.bodyMedium),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX2,
        vertical: Dimens.appBarSpacing,
      ),
      separatorBuilder: (_, index) => SizeBox.widgetSpacing,
      itemCount: complaintList.length,
      itemBuilder: (context, index) {
        final thread = complaintList[index];
        return ComplaintThreadWidget(
          thread: thread,
          onTap: () async {
            await RouteManager.pushNamed(
              Routes.threadComplaintPage,
              arguments: ThreadModel(
                threadID: thread.threadId,
                subject: thread.messages?.first.subject ?? "No Subject found !",
                complaintID: thread.sId,
              ),
            );
          },
        );
      },
    );
  }
}
