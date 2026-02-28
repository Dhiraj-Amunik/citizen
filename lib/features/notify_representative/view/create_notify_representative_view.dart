import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';

import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/mixin/handle_multiple_files_sheet.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/form_CommonDropDown.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/core/widgets/upload_multi_files.dart';
import 'package:inldsevak/features/common_fields/view_model/map_search_view_model.dart';
import 'package:inldsevak/features/common_fields/widget/map_search_location.dart';
import 'package:inldsevak/features/notify_representative/model/request/request_notify_model.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_filters_model.dart';
import 'package:inldsevak/features/notify_representative/view_model/create_notify_representative_view_model.dart';
import 'package:inldsevak/features/notify_representative/view_model/notify_representative_view_model.dart';
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:provider/provider.dart';

class CreateNotifyRepresentativeView extends StatefulWidget {
  const CreateNotifyRepresentativeView({super.key});

  @override
  State<CreateNotifyRepresentativeView> createState() =>
      _CreateNotifyRepresentativeViewState();
}

class _CreateNotifyRepresentativeViewState
    extends State<CreateNotifyRepresentativeView>
    with HandleMultipleFilesSheet, DateAndTimePicker {
  VoidCallback? _addressSyncListener;
  VoidCallback? _mapSearchViewModelListener;
  Timer? _syncDebounceTimer;
  bool _isSyncing = false;
  bool _listenersInitialized = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    // Cancel debounce timer
    _syncDebounceTimer?.cancel();

    // Dispose scroll controller
    _scrollController.dispose();

    // Remove address sync listeners
    if (_addressSyncListener != null || _mapSearchViewModelListener != null) {
      try {
        final mapsProvider = context.read<MapSearchViewModel>();
        if (_addressSyncListener != null) {
          mapsProvider.districtController.removeListener(_addressSyncListener!);
          mapsProvider.areaController.removeListener(_addressSyncListener!);
          mapsProvider.stateController.removeListener(_addressSyncListener!);
          mapsProvider.pincodeController.removeListener(_addressSyncListener!);
        }
        if (_mapSearchViewModelListener != null) {
          mapsProvider.removeListener(_mapSearchViewModelListener!);
        }
      } catch (e) {
        // Ignore errors if context is not available
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cache localization at the top of build to avoid multiple lookups
    // This significantly improves performance, especially for Hindi locale
    final localization = context.localizations;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CreateNotifyRepresentativeViewModel(),
        ),
      ],
      builder: (context, _) {
        final provider = context.read<CreateNotifyRepresentativeViewModel>();

        // Set up listeners after provider is available (only once)
        if (!_listenersInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _initializeListeners(context, provider);
            _listenersInitialized = true;
          });
        }

        // Check if Hindi keyboard might be shown (Hindi language)
        final isHindiLanguage =
            GeneralStream.instance.locale.languageCode == 'hi';
        // Hindi keyboard height is approximately 300px
        const hindiKeyboardHeight = 300.0;

        return Scaffold(
          appBar: commonAppBar(title: localization.notify_representative),
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              left: Dimens.horizontalspacing,
              right: Dimens.horizontalspacing,
              // Only add extra padding for Hindi locale, not for English
              bottom: isHindiLanguage
                  ? hindiKeyboardHeight +
                        MediaQuery.of(context).viewInsets.bottom +
                        Dimens.verticalspacing
                  : MediaQuery.of(context).viewInsets.bottom +
                        Dimens.verticalspacing,
            ),
            child: Consumer<CreateNotifyRepresentativeViewModel>(
              builder: (contextP, value, _) {
                return Form(
                  key: provider.formKey,
                  autovalidateMode: value.autoValidateMode,
                  child: Column(
                    spacing: Dimens.textFromSpacing,
                    children: [
                      FormTextFormField(
                        isRequired: true,
                        headingText: localization.event_type,
                        hintText: localization.title,
                        controller: provider.eventTypeController,
                        textCapitalization: TextCapitalization.sentences,
                        enforceFirstLetterUppercase: true,
                        maxLength: 50,
                        enableSpeechInput: true,
                        validator: (text) => text?.validate(
                          argument: localization.event_title_validatore,
                        ),
                      ),
                      Column(
                        spacing: Dimens.gapX2,
                        children: [
                          Row(
                            children: [
                              TranslatedText(
                                text: localization
                                    .address_details, // Use "Address Details" which is already localized
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ],
                          ),
                          // Address Fields using MapSearchLocation
                          Consumer<MapSearchViewModel>(
                            builder: (context, mapsValue, _) {
                              return MapSearchLocation(
                                hideHouseNumber: true,
                                hideUseMyLocation: true,
                                hideFindButton: true,
                                areaAndPincodeInRow: true,
                                findPincode: (pincode) async {
                                  // Sync all address fields from MapSearchViewModel to provider

                                  // This ensures district, area, and other fields are synced when location is used

                                  debugPrint(
                                    "📌 findPincode callback called with pincode: $pincode",
                                  );
                                  debugPrint(
                                    "   MapSearch - District: '${mapsValue.districtController.text}', Area: '${mapsValue.areaController.text}'",
                                  );
                                  debugPrint(
                                    "   MapSearch - Address model - District: '${mapsValue.address?.district}', Area: '${mapsValue.address?.area}'",
                                  );

                                  provider.districtController.text =
                                      mapsValue.districtController.text;
                                  provider.areaController.text =
                                      mapsValue.areaController.text;
                                  provider.stateController.text =
                                      mapsValue.stateController.text;
                                  provider.pincodeController.text =
                                      mapsValue.pincodeController.text;
                                  provider.mandalController.text =
                                      mapsValue.tehsilController.text;
                                  provider.streetController.text =
                                      mapsValue.areaController.text;
                                  provider.villageController.text =
                                      mapsValue.cityController.text.isNotEmpty
                                      ? mapsValue.cityController.text
                                      : (mapsValue.address?.subLocality ?? "");

                                  debugPrint(
                                    "   ✅ Synced to provider - District: '${provider.districtController.text}', Area: '${provider.areaController.text}'",
                                  );

                                  // Store location coordinates
                                  if (mapsValue.currentPosition != null) {
                                    provider.locationCoordinates =
                                        LocationCoordinates(
                                          lat: mapsValue
                                              .currentPosition!
                                              .latitude,
                                          lng: mapsValue
                                              .currentPosition!
                                              .longitude,
                                        );
                                  } else if (mapsValue.address?.latitude !=
                                          null &&
                                      mapsValue.address?.longitude != null) {
                                    provider.locationCoordinates =
                                        LocationCoordinates(
                                          lat: mapsValue.address!.latitude!,
                                          lng: mapsValue.address!.longitude!,
                                        );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),

                      FormTextFormField(
                        isRequired: true,
                        headingText: localization.event_date,
                        keyboardType: TextInputType.none,
                        hintText: localization.dd_mm_yyyy,
                        controller: provider.dateController,
                        suffixIcon: AppImages.calenderIcon,
                        showCursor: false,
                        onTap: () async {
                          final date = await customDatePicker(
                            startDate: DateTime.now(),
                            endDate: DateTime(
                              DateTime.now().year,
                              DateTime.now().month + 2,
                            ),
                          );
                          if (date != null) {
                            provider.companyDateFormat = date
                                .toString()
                                .toYyyyMmDd();
                            provider.dateController.text =
                                provider.companyDateFormat?.toDdMmYyyy() ?? "";
                          }
                        },
                        validator: (text) => text?.validate(
                          argument: localization.event_date_validatore,
                        ),
                      ),
                      FormTextFormField(
                        isRequired: true,
                        suffixIcon: AppImages.clockIcon,
                        headingText: localization.event_time,
                        hintText: localization.select_time,
                        keyboardType: TextInputType.none,
                        showCursor: false,
                        controller: provider.eventTimeController,
                        onTap: () async {
                          final time = await custom24HrsTimePicker();
                          // Convert 24-hour format to 12-hour format with AM/PM
                          if (time != null && time.isNotEmpty) {
                            provider.eventTimeController.text = time
                                .to12HourTimeFormat();
                          } else {
                            provider.eventTimeController.text = "";
                          }
                        },
                        validator: (text) => text?.validate(
                          argument: localization.event_time_validatore,
                        ),
                      ),
                      FormTextFormField(
                        isRequired: true,
                        headingText: localization.description,
                        hintText: localization
                            .enter_detail_description, // Use localized hint text for description
                        controller: provider.descriptionController,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        enforceFirstLetterUppercase: true,
                        enableSpeechInput: true,
                        validator: (text) => text?.validate(
                          argument: localization.notify_description_validatore,
                        ),
                      ),
                      // MLA Dropdown
                      Consumer<CreateNotifyRepresentativeViewModel>(
                        builder: (contextP, value, _) {
                          if (value.filtersData?.mlas != null &&
                              value.filtersData!.mlas!.isNotEmpty) {
                            return FormCommonDropDown<MlaFilter>(
                              isRequired: false,
                              heading: localization.select_mla,
                              hintText: localization.select_mla,
                              controller: value.mlaController,
                              items: value.filtersData!.mlas,
                              listItemBuilder: (context, mla, _, __) {
                                return TranslatedText(
                                  text: mla.user?.name ?? '',
                                  style: context.textTheme.bodySmall,
                                  disableTranslation: false,
                                );
                              },
                              headerBuilder: (context, mla, _) {
                                return TranslatedText(
                                  text: mla.user?.name ?? '',
                                  style: context.textTheme.bodySmall,
                                  disableTranslation: false,
                                );
                              },
                              validator: (MlaFilter? mla) {
                                // MLA is optional, no validation needed
                                return null;
                              },
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                      Consumer<CreateNotifyRepresentativeViewModel>(
                        builder: (contextP, value, _) {
                          return UploadMultiFilesWidget(
                            onTap: () {
                              // 🔥 Use plain bottom sheet for camera (DraggableSheet causes crashes on low-RAM)
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: false,
                                useRootNavigator: false,
                                builder: (bottomSheetContext) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(
                                      bottomSheetContext,
                                    ).viewInsets.bottom,
                                  ),
                                  child: selectMultipleFiles(
                                    onTap: value.addFiles,
                                    context: bottomSheetContext,
                                  ),
                                ),
                              );
                            },
                            onRemove: (int index) => value.removeImage(index),
                            multipleFiles: value.multipleFiles,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: Dimens.horizontalspacing,
                right: Dimens.horizontalspacing,
                top: Dimens.textFromSpacing,
                bottom: Dimens.verticalspacing,
              ),
              child:
                  Consumer2<
                    CreateNotifyRepresentativeViewModel,
                    NotifyRepresentativeViewModel
                  >(
                    builder: (contextP, value, notify, _) {
                      return CommonButton(
                        isEnable: !value.isLoading,
                        isLoading: value.isLoading,
                        onTap: () {
                          // Get MapSearchViewModel and pass it to ensure address fields are synced
                          final mapSearchViewModel = context
                              .read<MapSearchViewModel>();

                          provider.requestNotify(
                            onCompleted: notify.onRecentRefresh,
                            mapSearchViewModel: mapSearchViewModel,
                          );
                        },
                        text: localization.notify,
                      );
                    },
                  ),
            ),
          ),
        );
      },
    );
  }

  void _initializeListeners(
    BuildContext context,
    CreateNotifyRepresentativeViewModel notifyProvider,
  ) {
    if (!mounted) return;

    // Set up listeners for MapSearchViewModel controllers to sync address fields
    final mapsProvider = context.read<MapSearchViewModel>();

    void syncAddressFields({bool immediate = false}) {
      if (!mounted || _isSyncing) return;

      // Cancel previous debounce timer
      _syncDebounceTimer?.cancel();

      // If immediate sync is requested (e.g., when address is loaded), skip debounce
      if (immediate) {
        if (_isSyncing) return;
        _isSyncing = true;

        Future.microtask(() {
          if (!mounted) {
            _isSyncing = false;
            return;
          }

          try {
            // Debug: Log what we're syncing
            debugPrint("🔄 Immediate sync triggered");
            debugPrint(
              "   MapSearch - District: '${mapsProvider.districtController.text}', Area: '${mapsProvider.areaController.text}'",
            );
            debugPrint(
              "   MapSearch - City: '${mapsProvider.cityController.text}', Tehsil: '${mapsProvider.tehsilController.text}'",
            );
            debugPrint(
              "   MapSearch - Address model - District: '${mapsProvider.address?.district}', Area: '${mapsProvider.address?.area}'",
            );

            // Sync district and other fields from MapSearchViewModel
            // Batch updates to reduce rebuilds
            notifyProvider.districtController.text =
                mapsProvider.districtController.text;
            notifyProvider.areaController.text =
                mapsProvider.areaController.text;
            notifyProvider.stateController.text =
                mapsProvider.stateController.text;
            notifyProvider.pincodeController.text =
                mapsProvider.pincodeController.text;
            notifyProvider.mandalController.text =
                mapsProvider.tehsilController.text;
            notifyProvider.streetController.text =
                mapsProvider.areaController.text;
            notifyProvider.villageController.text =
                mapsProvider.cityController.text.isNotEmpty
                ? mapsProvider.cityController.text
                : (mapsProvider.address?.subLocality ?? "");

            // Debug: Log what was synced
            debugPrint(
              "   ✅ Synced - District: '${notifyProvider.districtController.text}', Area: '${notifyProvider.areaController.text}'",
            );

            // Store location coordinates
            if (mapsProvider.currentPosition != null) {
              notifyProvider.locationCoordinates = LocationCoordinates(
                lat: mapsProvider.currentPosition!.latitude,
                lng: mapsProvider.currentPosition!.longitude,
              );
            } else if (mapsProvider.address?.latitude != null &&
                mapsProvider.address?.longitude != null) {
              notifyProvider.locationCoordinates = LocationCoordinates(
                lat: mapsProvider.address!.latitude!,
                lng: mapsProvider.address!.longitude!,
              );
            }
          } catch (e) {
            debugPrint("❌ Error syncing address fields: $e");
          } finally {
            _isSyncing = false;
          }
        });
        return;
      }

      // Debounce sync to prevent multiple rapid calls (especially on older devices)
      _syncDebounceTimer = Timer(const Duration(milliseconds: 300), () async {
        if (!mounted || _isSyncing) return;
        _isSyncing = true;
        // Use microtask to prevent blocking UI thread
        await Future.microtask(() {
          if (!mounted) {
            _isSyncing = false;
            return;
          }

          try {
            // Sync district and other fields from MapSearchViewModel
            // Batch updates to reduce rebuilds
            notifyProvider.districtController.text =
                mapsProvider.districtController.text;
            notifyProvider.areaController.text =
                mapsProvider.areaController.text;
            notifyProvider.stateController.text =
                mapsProvider.stateController.text;
            notifyProvider.pincodeController.text =
                mapsProvider.pincodeController.text;
            notifyProvider.mandalController.text =
                mapsProvider.tehsilController.text;
            notifyProvider.streetController.text =
                mapsProvider.areaController.text;
            notifyProvider.villageController.text =
                mapsProvider.cityController.text.isNotEmpty
                ? mapsProvider.cityController.text
                : (mapsProvider.address?.subLocality ?? "");

            // Store location coordinates
            if (mapsProvider.currentPosition != null) {
              notifyProvider.locationCoordinates = LocationCoordinates(
                lat: mapsProvider.currentPosition!.latitude,
                lng: mapsProvider.currentPosition!.longitude,
              );
            } else if (mapsProvider.address?.latitude != null &&
                mapsProvider.address?.longitude != null) {
              notifyProvider.locationCoordinates = LocationCoordinates(
                lat: mapsProvider.address!.latitude!,
                lng: mapsProvider.address!.longitude!,
              );
            }
          } catch (e) {
            debugPrint("Error syncing address fields: $e");
          } finally {
            _isSyncing = false;
          }
        });
      });
    }

    // Store listener reference for cleanup
    _addressSyncListener = syncAddressFields;

    // Add listeners to key controllers
    mapsProvider.districtController.addListener(_addressSyncListener!);
    mapsProvider.areaController.addListener(_addressSyncListener!);
    mapsProvider.stateController.addListener(_addressSyncListener!);
    mapsProvider.pincodeController.addListener(_addressSyncListener!);

    // Also listen to address changes to trigger immediate sync when location is loaded
    _mapSearchViewModelListener = () {
      // When address is loaded, trigger immediate sync (bypass debounce)
      // Sync whenever address exists, regardless of field values
      // This ensures district and area are synced even if they're empty initially
      if (mapsProvider.address != null) {
        debugPrint("🔔 MapSearchViewModel listener fired - Address exists");
        debugPrint(
          "   Address District: '${mapsProvider.address?.district}', Area: '${mapsProvider.address?.area}'",
        );
        debugPrint(
          "   Controllers District: '${mapsProvider.districtController.text}', Area: '${mapsProvider.areaController.text}'",
        );

        // Cancel any pending debounced sync
        _syncDebounceTimer?.cancel();
        // Add a small delay to ensure loadAddress has finished updating controllers
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            // Trigger immediate sync to ensure fields are populated right away
            syncAddressFields(immediate: true);
          }
        });
      }
    };
    mapsProvider.addListener(_mapSearchViewModelListener!);
  }
}
