import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/models/response/constituency/constituency_model.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/common_fields/model/request_parliment_id_model.dart';
import 'package:inldsevak/features/common_fields/model/request_pincode_model.dart';
import 'package:inldsevak/features/common_fields/services/constituencies_repository.dart';

import 'package:quickalert/models/quickalert_type.dart';

class ConstituencyViewModel extends BaseViewModel {
  List<Constituency?> assemblyConstituencyLists = [];
  List<Constituency?> parliamentaryConstituencyLists = [];

  Future<String?> getParliamentaryConstituencies({
    required String pincode,
    required SingleSelectController<Constituency?> parlimentController,
  }) async {
    try {
      // Trim and validate pincode format
      final trimmedPincode = pincode.trim();

      if (trimmedPincode.isEmpty) {
        CommonSnackbar(
          text: "Please enter a valid Pincode !",
        ).showAnimatedDialog(type: QuickAlertType.warning);
        return null;
      }

      if (trimmedPincode.length != 6) {
        CommonSnackbar(
          text: "Pincode must be 6 digits !",
        ).showAnimatedDialog(type: QuickAlertType.warning);
        return null;
      }

      // Safely parse pincode - use tryParse to prevent FormatException
      final intCode = int.tryParse(trimmedPincode);
      if (intCode == null) {
        CommonSnackbar(
          text: "Please enter a valid numeric Pincode !",
        ).showAnimatedDialog(type: QuickAlertType.warning);
        return null;
      }

      final model = RequestPincodeModel(pincode: intCode);
      final response = await ConstituenciesRepository()
          .getParliamentaryConstituencies(token: token, model: model);
      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data == null) {
          debugPrint("⚠️ Parliamentary constituencies data is null");
          parliamentaryConstituencyLists = [];
        } else if (data.isEmpty) {
          debugPrint("⚠️ No parliamentary constituencies found");
          await CommonSnackbar(
            text: "No Constituencies Found !",
          ).showAnimatedDialog(type: QuickAlertType.warning);
          parliamentaryConstituencyLists = [];
        } else {
          try {
            // Data is already parsed as List<Constituency> from ConstituencyModel.fromJson
            // Convert List<Constituency> to List<Constituency?> to match the field type
            parlimentController.clear();
            parliamentaryConstituencyLists = List<Constituency?>.from(data);
            if (parliamentaryConstituencyLists.isNotEmpty) {
              parlimentController.value = parliamentaryConstituencyLists.first;
            }
            debugPrint(
              "✅ Loaded ${parliamentaryConstituencyLists.length} parliamentary constituencies",
            );
            notifyListeners();
            return response.data?.district;
          } catch (e, stackTrace) {
            debugPrint("❌ Error assigning parliamentary constituencies: $e");
            debugPrint("Stack trace: $stackTrace");
            debugPrint("   Data type: ${data.runtimeType}");
            parliamentaryConstituencyLists = [];
            await CommonSnackbar(
              text: "Error loading constituencies data",
            ).showAnimatedDialog(type: QuickAlertType.error);
          }
        }
      } else {
        debugPrint(
          "⚠️ Failed to get parliamentary constituencies: ${response.data?.message}",
        );
        await CommonSnackbar(
          text: response.data?.message ?? "No Constituencies Found !",
        ).showAnimatedDialog(type: QuickAlertType.warning);
      }
    } catch (err, stackTrace) {
      await CommonSnackbar(
        text: "Something went wrong",
      ).showAnimatedDialog(type: QuickAlertType.error);
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
    return null;
  }

  Future<void> getAssemblyConstituencies({
    required String? id,
    String? oldToken,
  }) async {
    try {
      assemblyConstituencyLists.clear();
      if (id == null || id.trim().isEmpty) {
        notifyListeners();
        return;
      }
      final model = RequestParlimentIdModel(id: id);
      final response = await ConstituenciesRepository()
          .getAssemblyConstituencies(token: oldToken ?? token, model: model);

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        if (data == null) {
          debugPrint("⚠️ Assembly constituencies data is null");
          assemblyConstituencyLists = [];
        } else if (data.isEmpty) {
          debugPrint("⚠️ No assembly constituencies found");
          await CommonSnackbar(
            text: "No Constituencies Found !",
          ).showAnimatedDialog(type: QuickAlertType.warning);
          assemblyConstituencyLists = [];
        } else {
          try {
            // Data is already parsed as List<Constituency> from ConstituencyModel.fromJson
            // Convert List<Constituency> to List<Constituency?> to match the field type
            assemblyConstituencyLists = List<Constituency?>.from(data);
            debugPrint(
              "✅ Loaded ${assemblyConstituencyLists.length} assembly constituencies",
            );
            // Log first item for debugging
            if (assemblyConstituencyLists.isNotEmpty) {
              final first = assemblyConstituencyLists.first;
              debugPrint(
                "   Example - Name: ${first?.name}, sId: ${first?.sId}",
              );
            }
          } catch (e, stackTrace) {
            debugPrint("❌ Error assigning assembly constituencies: $e");
            debugPrint("Stack trace: $stackTrace");
            debugPrint("   Data type: ${data.runtimeType}");
            assemblyConstituencyLists = [];
            await CommonSnackbar(
              text: "Error loading constituencies data",
            ).showAnimatedDialog(type: QuickAlertType.error);
          }
        }
        notifyListeners();
      } else {
        debugPrint(
          "⚠️ Failed to get assembly constituencies: ${response.data?.message}",
        );
        debugPrint("   Response code: ${response.data?.responseCode}");
        assemblyConstituencyLists = [];
        notifyListeners();
      }
    } catch (err, stackTrace) {
      await CommonSnackbar(
        text: "Something went wrong",
      ).showAnimatedDialog(type: QuickAlertType.error);
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
  }
}
