import 'package:flutter/widgets.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';


class WallOfHelpViewModel extends BaseViewModel {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  final nameFocus = FocusNode();
  final titleFocus = FocusNode();
  final descriptionFocus = FocusNode();

  final nameController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final dobController = TextEditingController();
  String? companyDateFormat;

  final contactController = TextEditingController();

}
