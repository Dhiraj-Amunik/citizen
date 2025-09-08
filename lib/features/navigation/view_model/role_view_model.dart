import 'package:inldsevak/core/provider/base_view_model.dart';

class RoleViewModel extends BaseViewModel {
  bool isUIEnabled = false;
  late bool isPartyMember;

  @override
  Future<void> onInit() async {
    await getRole();
    isPartyMember = role ?? false;
    isUIEnabled = true;
    notifyListeners();
    return super.onInit();
  }
}
