import 'dart:developer';
import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/complaints/model/official.dart';
import 'package:inldsevak/features/complaints/model/request/add_complaint_request_model.dart';
import 'package:inldsevak/features/complaints/repository/complaints_repository.dart';
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:provider/provider.dart';

class AddComplaintsViewModel extends BaseViewModel with CupertinoDialogMixin {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final constituenciesController = SingleSelectController<String>(null);
  final descriptionController = TextEditingController();
  final departmentController = SingleSelectController<String>(null);
  final officialController = SingleSelectController<Official>(null);

  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  List<String> constituencies = [
    "KALKA",
    "PANCHKULA",
    "NARAINGARH",
    "AMBALA CANTT.",
    "AMBALA CITY",
    "MULANA (SC)",
    "SADHAURA(SC)",
    "JAGADHRI",
    "YAMUNANAGAR",
    "RADAUR",
    "LADWA",
    "SHAHBAD(SC)",
    "THANESAR",
    "PEHOWA",
    "GUHLA(SC)",
    "KALAYAT",
    "KAITHAL",
    "PUNDRI",
    "NILOKHERI(SC)",
    "INDRI",
    "KARNAL",
    "GHARAUNDA",
    "ASSANDH",
    "PANIPAT RURAL",
    "PANIPAT CITY",
    "ISRANA(SC)",
    "SAMALKHA",
    "GANAUR",
    "RAI",
    "KHARKHAUDA(SC)",
    "SONIPAT",
    "GOHANA",
    "BARODA",
    "MEHAM",
    "GARHI SAMPLA-KILOI",
    "ROHTAK",
    "KALANAUR(SC)",
    "BAHADURGARH",
    "BADLI",
    "JHAJJAR(SC)",
    "BERI",
    "BADHRA",
    "DADRI",
    "LOHARU",
    "BHIWANI",
    "TOSHAM",
    "BAWANI KHERA(SC)",
    "JULANA",
    "SAFIDON",
    "JIND",
    "UCHANA KALAN",
    "NARWANA(SC)",
    "TOHANA",
    "FATEHABAD",
    "RATIA(SC)",
    "KALAWALI(SC)",
    "DABWALI",
    "RANIA",
    "SIRSA",
    "ELLENABAD",
    "ADAMPUR",
    "UKLANA(SC)",
    "NARNAUND",
    "HANSI",
    "BARWALA",
    "HISAR",
    "NALWA",
    "ATELI",
    "MAHENDRAGARH",
    "NARNAUL",
    "NANGAL CHAUDHRY",
    "BAWAL(SC)",
    "KOSLI",
    "REWARI",
    "PATAUDI(SC)",
    "BADSHAHPUR",
    "GURGAON",
    "SOHNA",
    "NUH",
    "FEROZEPUR JHIRKA",
    "PUNAHANA",
    "HATHIN",
    "HODAL(SC)",
    "PALWAL",
    "PRITHLA",
    "FARIDABAD NIT",
    "BADKHAL",
    "BALLABHGARH",
    "FARIDABAD",
    "TIGAON",
  ];

  update() {
    notifyListeners();
  }

  Future<void> lodgeComplaints() async {
    try {
      if (formKey.currentState!.validate()) {
        autoValidateMode = AutovalidateMode.disabled;
      } else {
        autoValidateMode = AutovalidateMode.onUserInteraction;
        notifyListeners();
        return;
      }
      isLoading = true;

      final data = AddComplaintRequestModel(
        department: officialController.value?.department,
        endUserEmail: officialController.value?.email,
        name: officialController.value?.name,
        title: titleController.text,
        description: descriptionController.text,
      );
      log(data.toJson().toString());

      final response = await ComplaintsRepository().addComplaints(
        data: data,
        token: token ?? '',
      );
      if (response.data?.success == true) {
        CommonSnackbar(text: 'Complaints has been Lodge').showToast();
        final BuildContext context =
            RouteManager.navigatorKey.currentState!.context;
        if (context.mounted) {
          await context.read<ComplaintsViewModel>().getComplaints();
        }
        RouteManager.pop();
      } else {
        CommonSnackbar(text: 'Something went wrong').showToast();
      }
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  //image

  File? image;

  Future<void> selectImage() async {
    customRightCupertinoDialog(
      content: "Choose Image",
      rightButton: "Sure",
      onTap: () async {
        try {
          image = await pickGalleryImage();
          notifyListeners();
        } catch (err, stackTrace) {
          debugPrint("Error: $err");
          debugPrint("Stack Trace: $stackTrace");
        }
        RouteManager.pop();
      },
    );
  }

  void removeImage() {
    image = null;
    notifyListeners();
  }
}
