import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/request_donate_help_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/services/wall_of_help_repository.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/wall_of_help_view_model.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:uuid/uuid.dart';

class ContributeHelpViewModel extends BaseViewModel {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  final amountController = TextEditingController();
  Future<void> donateToHelpRequest({
    required String? id,
    // required String? transactionID,
  }) async {
    try {
      if (formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        return;
      }
      isLoading = true;
      var uuid = Uuid();

      final model = RequestDonateHelpModel(
        requestId: id,
        amount: int.tryParse(amountController.text),
        paymentMethod: "upi",
        transactionId: uuid.v1(),
      );

      log(model.toJson().toString());

      final response = await WallOfHelpRepository().donateToHelpRequest(
        token: token,
        model: model,
      );

      if (response.data?.responseCode == 200 ||
          response.data?.responseCode == 201) {
        if (RouteManager.context.mounted) {
          await RouteManager.context
              .read<WallOfHelpViewModel>()
              .getWallOfHelpList();
        }
        await CommonSnackbar(
          text: response.data?.message ?? "Donated successfully",
        ).showAnimatedDialog(type: QuickAlertType.success);
      } else {
        await CommonSnackbar(
          text: response.data?.message ?? "Something went wrong",
        ).showAnimatedDialog(type: QuickAlertType.warning);
      }
      RouteManager.pop(true);
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }
}
