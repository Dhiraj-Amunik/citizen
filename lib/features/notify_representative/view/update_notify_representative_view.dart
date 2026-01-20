import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/extensions/validation_extension.dart';
import 'package:inldsevak/core/mixin/dateTime_mixin.dart';
import 'package:inldsevak/core/mixin/handle_multiple_files_sheet.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/draggable_sheet_widget.dart';
import 'package:inldsevak/core/widgets/form_text_form_field.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/core/widgets/upload_multi_files.dart';
import 'package:inldsevak/features/common_fields/view_model/map_search_view_model.dart';
import 'package:inldsevak/features/common_fields/widget/map_search_location.dart';
import 'package:inldsevak/features/notify_representative/model/request/request_notify_model.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_lists_model.dart';
import 'package:inldsevak/features/notify_representative/view_model/notify_representative_view_model.dart';
import 'package:inldsevak/features/notify_representative/view_model/update_notify_representative_view_model.dart';
import 'package:provider/provider.dart';

class UpdateNotifyRepresentativeView extends StatefulWidget {
  final NotifyRepresentative model;
  const UpdateNotifyRepresentativeView({super.key, required this.model});

  @override
  State<UpdateNotifyRepresentativeView> createState() => _UpdateNotifyRepresentativeViewState();
}

class _UpdateNotifyRepresentativeViewState extends State<UpdateNotifyRepresentativeView>
    with HandleMultipleFilesSheet, DateAndTimePicker {
  VoidCallback? _addressSyncListener;
  VoidCallback? _mapSearchViewModelListener;
  bool _listenersInitialized = false;
  Timer? _syncDebounceTimer;
  bool _isSyncing = false;

  @override
  void dispose() {
    // Cancel debounce timer
    _syncDebounceTimer?.cancel();
    
    // Remove address sync listeners
    if (_addressSyncListener != null || _mapSearchViewModelListener != null) {
      try {
        final mapsProvider = context.read<MapSearchViewModel>();
        if (_addressSyncListener != null) {
          mapsProvider.districtController.removeListener(_addressSyncListener!);
          mapsProvider.areaController.removeListener(_addressSyncListener!);
          mapsProvider.stateController.removeListener(_addressSyncListener!);
          mapsProvider.pincodeController.removeListener(_addressSyncListener!);
          mapsProvider.tehsilController.removeListener(_addressSyncListener!);
          mapsProvider.cityController.removeListener(_addressSyncListener!);
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
    final localization = context.localizations;

    return ChangeNotifierProvider(
      create: (context) => UpdateNotifyRepresentativeViewModel(widget.model),
      builder: (context, _) {
        final provider = context.read<UpdateNotifyRepresentativeViewModel>();
        
        // Set up listeners after provider is available (only once)
        if (!_listenersInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _initializeListeners(context, provider);
            _listenersInitialized = true;
          });
        }
        
        // Check if Hindi keyboard might be shown (Hindi language)
        final isHindiLanguage = Localizations.localeOf(context).languageCode == 'hi';
        // Hindi keyboard height is approximately 300px
        const hindiKeyboardHeight = 300.0;
        
        return Scaffold(
          appBar: commonAppBar(title: localization.notify_representative),
          body: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: Dimens.horizontalspacing,
              right: Dimens.horizontalspacing,
              // Only add extra padding for Hindi locale, not for English
              bottom: isHindiLanguage
                  ? hindiKeyboardHeight + MediaQuery.of(context).viewInsets.bottom
                  : MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Consumer<UpdateNotifyRepresentativeViewModel>(
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
                        enableSpeechInput: true,
                        validator: (text) => text?.validate(
                          argument: localization.event_title_validatore,
                        ),
                      ),
                      // Address Fields using MapSearchLocation
                      Column(
                         spacing: Dimens.gapX2,
                        children: [
                            Row(
                            children: [
                              TranslatedText(text: 'Event Address',style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400,fontSize: 18.sp),),
                            ],
                          ),
                          Consumer<MapSearchViewModel>(
                            builder: (context, mapsValue, _) {
                              return MapSearchLocation(
                                hideHouseNumber: true,
                                hideUseMyLocation: true,
                                hideFindButton: true,
                                areaAndPincodeInRow: true,
                                findPincode: (pincode) async {
                                  // No constituency-related logic needed
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
                            provider.eventTimeController.text = time.to12HourTimeFormat();
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
                        hintText: localization.description_info,
                        controller: provider.descriptionController,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        enforceFirstLetterUppercase: true,
                        enableSpeechInput: true,
                        validator: (text) => text?.validate(
                          argument: localization.notify_description_validatore,
                        ),
                      ),

                      if (value.existingDocuments.isNotEmpty)
                        _ExistingDocumentsGrid(
                          documents: value.existingDocuments,
                          onRemove: value.removeExistingDocument,
                        ),
                      Consumer<UpdateNotifyRepresentativeViewModel>(
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
                                    bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
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
          bottomNavigationBar:
              Consumer2<
                UpdateNotifyRepresentativeViewModel,
                NotifyRepresentativeViewModel
              >(
                builder: (contextP, value, notify, _) {
                  return CommonButton(
                        isEnable: !value.isLoading,
                        isLoading: value.isLoading,
                        onTap: () {
                          provider.requestNotify(
                            onCompleted: notify.onRecentRefresh,
                          );
                        },
                        text: localization.update,
                      )
                      .symmetricPadding(horizontal: Dimens.horizontalspacing)
                      .onlyPadding(
                        top: Dimens.textFromSpacing,
                        bottom: Dimens.verticalspacing,
                      );
                },
              ),
        );
      },
    );
  }
  
  void _initializeListeners(BuildContext context, UpdateNotifyRepresentativeViewModel notifyProvider) {
    if (!mounted) return;
    
    // Set up listeners for MapSearchViewModel controllers to sync address fields
    final mapsProvider = context.read<MapSearchViewModel>();
    
    void syncAddressFields() {
      if (!mounted || _isSyncing) return;
      
      // Cancel previous debounce timer
      _syncDebounceTimer?.cancel();
      
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
            notifyProvider.districtController.text = mapsProvider.districtController.text;
            notifyProvider.areaController.text = mapsProvider.areaController.text;
            notifyProvider.stateController.text = mapsProvider.stateController.text;
            notifyProvider.pincodeController.text = mapsProvider.pincodeController.text;
            notifyProvider.mandalController.text = mapsProvider.tehsilController.text;
            notifyProvider.streetController.text = mapsProvider.areaController.text;
            notifyProvider.villageController.text = mapsProvider.cityController.text.isNotEmpty
                ? mapsProvider.cityController.text
                : (mapsProvider.address?.subLocality ?? "");
            
            // Store location coordinates
            if (mapsProvider.currentPosition != null) {
              notifyProvider.locationCoordinates = LocationCoordinates(
                lat: mapsProvider.currentPosition!.latitude,
                lng: mapsProvider.currentPosition!.longitude,
              );
            } else if (mapsProvider.address?.latitude != null && mapsProvider.address?.longitude != null) {
              // Fallback to address model coordinates if currentPosition is not available
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
    mapsProvider.tehsilController.addListener(_addressSyncListener!);
    mapsProvider.cityController.addListener(_addressSyncListener!);
    
    // Also listen to address changes to trigger immediate sync when location is loaded
    _mapSearchViewModelListener = () {
      // When address is loaded, trigger immediate sync (bypass debounce)
      if (mapsProvider.address != null && 
          mapsProvider.districtController.text.isNotEmpty) {
        // Cancel any pending debounced sync
        _syncDebounceTimer?.cancel();
        // Trigger immediate sync
        syncAddressFields();
      }
    };
    mapsProvider.addListener(_mapSearchViewModelListener!);
    
    // Load existing data into MapSearchViewModel when editing
    // This populates the fields so "Use my location" can work with existing data
    final existingData = widget.model;
    if (existingData.pincode != null && existingData.pincode!.isNotEmpty) {
      mapsProvider.pincodeController.text = existingData.pincode!;
    }
    if (existingData.district != null && existingData.district!.isNotEmpty) {
      mapsProvider.districtController.text = existingData.district!;
      // Also explicitly sync to notify provider
      notifyProvider.districtController.text = existingData.district!;
    }
    if (existingData.mandal != null && existingData.mandal!.isNotEmpty) {
      mapsProvider.tehsilController.text = existingData.mandal!;
      // Also explicitly sync to notify provider
      notifyProvider.mandalController.text = existingData.mandal!;
    }
    if (existingData.village != null && existingData.village!.isNotEmpty) {
      mapsProvider.cityController.text = existingData.village!;
      // Also explicitly sync to notify provider
      notifyProvider.villageController.text = existingData.village!;
    }
    if (existingData.area != null && existingData.area!.isNotEmpty) {
      mapsProvider.areaController.text = existingData.area!;
    } else if (existingData.street != null && existingData.street!.isNotEmpty) {
      // Fallback to street if area is not available
      mapsProvider.areaController.text = existingData.street!;
    }
    if (existingData.state != null && existingData.state!.isNotEmpty) {
      mapsProvider.stateController.text = existingData.state!;
    }
    
  }
}

class _ExistingDocumentsGrid extends StatelessWidget {
  const _ExistingDocumentsGrid({
    required this.documents,
    required this.onRemove,
  });

  final List<String> documents;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Dimens.gapX,
      children: [
        Text(
          "Uploaded Files",
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppPalettes.lightTextColor,
          ),
        ),
        Wrap(
          spacing: Dimens.gapX1,
          runSpacing: Dimens.gapX1,
          children: List.generate(documents.length, (index) {
            final resolvedUrl = _resolveUrl(documents[index]);
            if (resolvedUrl == null) {
              return const SizedBox.shrink();
            }
            return Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.radiusX2),
                  child: CachedNetworkImage(
                    imageUrl: resolvedUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      color: AppPalettes.liteGreyColor,
                      child: const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      color: AppPalettes.liteGreyColor,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 20,
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: () => onRemove(index),
                    child: CircleAvatar(
                      radius: Dimens.scaleX1B,
                      backgroundColor: AppPalettes.whiteColor,
                      child: Icon(
                        Icons.close,
                        size: Dimens.scaleX1B,
                        color: AppPalettes.redColor,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  String? _resolveUrl(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http')) return trimmed;
    if (trimmed.startsWith('/')) return "${URLs.baseURL}$trimmed";
    return "${URLs.baseURL}/$trimmed";
  }
}
