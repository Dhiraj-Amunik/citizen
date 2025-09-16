import 'package:flutter/material.dart';
import 'package:inldsevak/features/offline/view_model/connectivty_provider.dart';
import 'package:inldsevak/features/auth/view_model/login_view_model.dart';
import 'package:inldsevak/features/common_fields/view_model/constituency_view_model.dart';
import 'package:inldsevak/features/common_fields/view_model/mla_view_model.dart';
import 'package:inldsevak/features/common_fields/view_model/map_search_view_model.dart';
import 'package:inldsevak/features/auth/view_model/user_register_view_model.dart';
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:inldsevak/features/events/view_model/events_view_model.dart';
import 'package:inldsevak/features/id_card/view_model.dart/id_card_view_model.dart';
import 'package:inldsevak/features/lok_varta/view_model/lok_varta_view_model.dart';
import 'package:inldsevak/features/navigation/view_model/role_view_model.dart';
import 'package:inldsevak/features/profile_tabs/view_model/emergency_contact_view_model.dart';
import 'package:inldsevak/features/profile_tabs/view_model/help_and_support_view_model.dart';
import 'package:inldsevak/features/donation/view_model/donation_view_model.dart';
import 'package:inldsevak/features/navigation/view_model/navigation_view_model.dart';
import 'package:inldsevak/features/profile/view_model/avatar_view_model.dart';
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/wall_of_help_view_model.dart';
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AppProviders {
  AppProviders._privateConstructor();
  static List<SingleChildWidget> provider = [
    StreamProvider<Locale>.value(
      initialData: const Locale("en"),
      value: GeneralStream.languageStream.stream,
      catchError: (_, __) => const Locale("en"),
    ),
    ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
    ChangeNotifierProvider(create: (_) => LoginViewModel()),
    ChangeNotifierProvider(create: (_) => ProfileViewModel()),
    ChangeNotifierProvider(create: (_) => MapSearchViewModel()),
    ChangeNotifierProvider(create: (_) => AvatarViewModel()),
    ChangeNotifierProvider(create: (_) => UserRegisterViewModel()),
    ChangeNotifierProvider(create: (_) => NavigationViewModel()),
    ChangeNotifierProvider(create: (_) => DonationViewModel()),
    ChangeNotifierProvider(create: (_) => ComplaintsViewModel()),
    ChangeNotifierProvider(create: (_) => HelpAndSupportViewModel()),
    ChangeNotifierProvider(create: (_) => EmergencyContactViewModel()),
    ChangeNotifierProvider(create: (_) => RoleViewModel()),

    //
    ChangeNotifierProvider(create: (_) => QrCodeViewModel()),
    //user-party
    ChangeNotifierProvider(create: (_) => WallOfHelpViewModel()),
    //User Providers
    ChangeNotifierProvider(create: (_) => EventsViewModel()),
    ChangeNotifierProvider(create: (_) => LokVartaViewModel()),
    ChangeNotifierProvider(create: (_) => ConstituencyViewModel()),
    ChangeNotifierProvider(create: (_) => MlaViewModel()),
  ];
}
