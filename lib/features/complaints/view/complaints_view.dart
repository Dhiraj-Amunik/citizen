import 'package:flutter/material.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/default_tabbar.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart';
import 'package:inldsevak/features/complaints/model/thread_model.dart';
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:inldsevak/features/complaints/widgets/complaint_widget.dart';
import 'package:provider/provider.dart';

class ComplaintsView extends StatefulWidget {
  const ComplaintsView({super.key});

  @override
  State<ComplaintsView> createState() => _ComplaintsViewState();
}

class _ComplaintsViewState extends State<ComplaintsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComplaintsViewModel>().complaintsList;
    return Scaffold(
      appBar: commonAppBar(
        appBarHeight: 130,
        title: "My Complaints",
        action: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<ComplaintsViewModel>().getComplaints(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Column(
            children: [
              DefaultTabBar(
                controller: _tabController,
                tabLabels: const ["All", "In Progress", "Resolved"],
              ),
              SizeBox.sizeHX7,
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  context.read<ComplaintsViewModel>().getComplaints(),
              child: Consumer<ComplaintsViewModel>(
                builder: (context, value, _) {
                  if (value.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimens.paddingX3),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildComplaintsList(provider),
                        _buildComplaintsList(provider),
                        _buildComplaintsList(provider),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          RouteManager.pushNamed(Routes.lodgeComplaintPage);
        },
        icon: const Icon(Icons.add),
        label: const Text('Lodge Complaint'),
      ),
    );
  }

  Widget _buildComplaintsList(List<Data> complaintList) {
    if (complaintList.isEmpty) {
      return Center(
        child: Text("No Complaints Found", style: AppStyles.bodyMedium),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ComplaintsViewModel>().getComplaints();
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.paddingX2,
          vertical: Dimens.verticalspacing,
        ),
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
                  subject: thread.subject,
                  inReplyTo: thread.threadId,
                  to: thread.messages?.first.to,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
