import 'dart:async';

import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';

class RoleViewModel extends BaseViewModel {
  bool isUIEnabled = false;
  late bool isPartyMember;
  StreamSubscription<SecureModel?>? _sessionSubscription;

  @override
  Future<void> onInit() async {
    await getRole();
    isPartyMember = role ?? false;
    _sessionSubscription =
        SessionController.instance.userAuthChange.listen((secureModel) {
      final updatedValue = secureModel?.isPartyMemeber ?? false;
      if (isPartyMember != updatedValue) {
        isPartyMember = updatedValue;
        notifyListeners();
      }
    });
    isUIEnabled = true;
    notifyListeners();
    return super.onInit();
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }
}
