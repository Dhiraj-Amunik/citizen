import 'package:flutter/cupertino.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/string_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/nearest_member/model/nearest_members_model.dart';
import 'package:inldsevak/features/common_fields/services/search_repository.dart';
import 'package:inldsevak/features/common_fields/model/address_model.dart';
import 'package:inldsevak/features/common_fields/model/geocoding_model.dart';

class MemberWidget extends StatelessWidget {
  final PartyMember member;
  final bool showIcon;
  final Function() onTap;
  const MemberWidget({
    super.key,
    required this.member,
    required this.onTap,
    required this.showIcon,
  });

  // Helper to check if a string looks like a Plus Code
  bool _isPlusCode(String text) {
    // Plus codes typically match pattern: 2-4 letters, 2 numbers, +, 2-3 characters
    final plusCodePattern = RegExp(r'^[A-Z0-9]{6,}\+[A-Z0-9]{2,}$', caseSensitive: false);
    return plusCodePattern.hasMatch(text.trim());
  }

  // Extract readable location from geocoding results
  String? _extractReadableLocation(AddressModel addressModel) {
    // Priority: City + District > City > District > SubLocality > State > Area
    final city = addressModel.city;
    final district = addressModel.district;
    final subLocality = addressModel.subLocality;
    final state = addressModel.state;
    final area = addressModel.area;
    
    // Try combinations
    if (city != null && city.isNotEmpty && district != null && district.isNotEmpty) {
      return "$city, $district";
    } else if (city != null && city.isNotEmpty) {
      // If district is not available, try to add state or sublocality
      if (district != null && district.isNotEmpty) {
        return "$city, $district";
      } else if (subLocality != null && subLocality.isNotEmpty && subLocality != city) {
        return "$city, $subLocality";
      } else if (state != null && state.isNotEmpty) {
        return "$city, $state";
      }
      return city;
    } else if (district != null && district.isNotEmpty) {
      // If city not available, show district with state
      if (state != null && state.isNotEmpty) {
        return "$district, $state";
      }
      return district;
    } else if (subLocality != null && subLocality.isNotEmpty) {
      if (state != null && state.isNotEmpty) {
        return "$subLocality, $state";
      }
      return subLocality;
    } else if (area != null && area.isNotEmpty) {
      if (state != null && state.isNotEmpty) {
        return "$area, $state";
      }
      return area;
    } else if (state != null && state.isNotEmpty) {
      return state;
    }
    
    // Last resort: check formattedAddress but skip Plus Codes
    final formattedAddr = addressModel.formattedAddress;
    if (formattedAddr != null && formattedAddr.isNotEmpty) {
      // Don't use Plus Code
      if (!_isPlusCode(formattedAddr)) {
        // Try to extract city/district from formatted address
        // Split by comma and take meaningful parts (skip street numbers, etc.)
        final parts = formattedAddr.split(',').map((p) => p.trim()).where((p) => 
          p.isNotEmpty && 
          !_isPlusCode(p) &&
          !RegExp(r'^\d+(-\d+)?$').hasMatch(p) && // Skip pure numbers and zip codes
          p.length > 2 && // Skip very short parts
          !RegExp(r'^\d+[A-Za-z]?$').hasMatch(p) // Skip house numbers
        ).toList();
        
        debugPrint("Formatted address parts: $parts");
        
        if (parts.isNotEmpty) {
          // Try to find city/district/state from parts
          // Usually format is: Street, City, State, Country
          // Or: Street, Area, City, State, Country
          
          // If we have at least 2 parts, take the last 2 (city, state)
          // If we have more, try to find meaningful city/state combination
          if (parts.length >= 2) {
            // Last part is usually state/country, second last is usually city
            final cityPart = parts[parts.length - 2];
            final statePart = parts[parts.length - 1];
            
            // Filter out country names (common countries)
            final countries = ['India', 'USA', 'United States', 'UK', 'United Kingdom'];
            if (countries.any((country) => statePart.toLowerCase().contains(country.toLowerCase()))) {
              // If last part is country, take second last and third last
              if (parts.length >= 3) {
                return "${parts[parts.length - 3]}, ${parts[parts.length - 2]}";
              }
            }
            
            return "$cityPart, $statePart";
          } else {
            return parts.last;
          }
        }
        
        // If parts parsing failed, just return formatted address if it's reasonable
        if (formattedAddr.length > 10 && formattedAddr.length < 200) {
          return formattedAddr;
        }
      }
    }
    
    return null;
  }

  Future<String> _getLocationText(PartyMember member, dynamic localization) async {
    debugPrint("Getting location for member: ${member.sId}, name: ${member.name}");
    debugPrint("Member address: ${member.address}");
    debugPrint("Member location: ${member.location?.coordinates}");
    
    // If address is available and not empty, use it
    if (member.address != null && member.address!.trim().isNotEmpty) {
      debugPrint("Using member address: ${member.address}");
      return member.address!;
    }
    
    // If address is empty but coordinates are available, convert coordinates to location name
    if (member.location?.coordinates != null && 
        member.location!.coordinates!.length >= 2) {
      debugPrint("Member has coordinates, attempting geocoding...");
      try {
        // Note: API returns coordinates as [latitude, longitude], not GeoJSON [longitude, latitude]
        // So coordinates[0] = latitude, coordinates[1] = longitude
        final lat = member.location!.coordinates![0];
        final lng = member.location!.coordinates![1];
        
        debugPrint("Geocoding request - lat: $lat, lng: $lng");
        
        final response = await GoogleRepository().placeFromCoordinates(
          lat: lat,
          lng: lng,
        );
        
        debugPrint("Geocoding response status: ${response.data?.status}");
        debugPrint("Geocoding response error: ${response.error}");
        debugPrint("Geocoding results count: ${response.data?.results?.length ?? 0}");
        
        // Check for API errors first
        if (response.error != null) {
          debugPrint("Geocoding API error: ${response.error}");
          debugPrint("Geocoding error message: ${response.error?.message}");
          // Fall through to coordinates fallback
        } else if (response.data != null && response.data!.status == "OK" && response.data!.results != null && response.data!.results!.isNotEmpty) {
          debugPrint("Geocoding successful, processing results...");
          // Try to find the best result - look through results to find one with locality or administrative_area
          AddressModel? bestAddressModel;
          
          // First, try the default parsing
          bestAddressModel = AddressModel.fromGeocodingModel(response.data!);
          
          debugPrint("Parsed address - city: ${bestAddressModel.city}, district: ${bestAddressModel.district}");
          debugPrint("Parsed address - subLocality: ${bestAddressModel.subLocality}, state: ${bestAddressModel.state}");
          
          // If first result doesn't have good data, try other results
          if ((bestAddressModel.city == null || bestAddressModel.city!.isEmpty) &&
              (bestAddressModel.district == null || bestAddressModel.district!.isEmpty)) {
            debugPrint("First result doesn't have city/district, trying other results...");
            
            for (var result in response.data!.results!) {
              // Look for results that have locality or administrative_area types
              final hasLocality = result.types?.any((type) => 
                type.contains('locality') || 
                type.contains('administrative_area') ||
                type.contains('sublocality')
              ) ?? false;
              
              if (hasLocality) {
                final testModel = AddressModel.fromGeocodingModel(
                  GeocodingModel(results: [result], status: "OK", plusCode: null)
                );
                debugPrint("Test model - city: ${testModel.city}, district: ${testModel.district}");
                
                if ((testModel.city != null && testModel.city!.isNotEmpty) ||
                    (testModel.district != null && testModel.district!.isNotEmpty)) {
                  bestAddressModel = testModel;
                  debugPrint("Found better result with city/district");
                  break;
                }
              }
            }
          }
          
          if (bestAddressModel != null) {
            final locationText = _extractReadableLocation(bestAddressModel);
            debugPrint("Extracted location text: $locationText");
            
            if (locationText != null && locationText.isNotEmpty) {
              return locationText;
            } else {
              debugPrint("No readable location extracted from address model");
              // Last resort: try to use formattedAddress if it exists and is reasonable
              final formattedAddr = bestAddressModel.formattedAddress;
              if (formattedAddr != null && 
                  formattedAddr.isNotEmpty && 
                  !_isPlusCode(formattedAddr) &&
                  formattedAddr.length > 10) {
                debugPrint("Using formatted address as fallback: $formattedAddr");
                // Extract just city/state from formatted address
                final parts = formattedAddr.split(',').map((p) => p.trim()).toList();
                if (parts.length >= 2) {
                  // Return last 2 parts (usually city, state)
                  return "${parts[parts.length - 2]}, ${parts[parts.length - 1]}";
                }
                return formattedAddr;
              }
            }
          }
        } else {
          debugPrint("Geocoding response not OK or empty results. Status: ${response.data?.status}");
        }
      } catch (e, stackTrace) {
        debugPrint("Error converting coordinates to location: $e");
        debugPrint("Stack trace: $stackTrace");
      }
      
      // If geocoding fails or no readable location found, show coordinates as fallback
      debugPrint("Falling back to coordinates display");
      // API format: [latitude, longitude]
      final lat = member.location!.coordinates![0];
      final lng = member.location!.coordinates![1];
      return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
    }
    
    // If no address and no coordinates, check if we have member ID to potentially fetch details
    debugPrint("No address or coordinates found for member ${member.sId}");
    debugPrint("Member partyMemberDetails: ${member.partyMemberDetails?.sId}");
    debugPrint("Member phone: ${member.phone}");
    debugPrint("Member address value: '${member.address}'");
    debugPrint("Member address is null: ${member.address == null}");
    debugPrint("Member address isEmpty: ${member.address?.isEmpty ?? true}");
    
    // Fallback to "not found" - but log why
    debugPrint("Returning 'not found' - member has no address or location data");
    return localization.not_found;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.paddingX3,
          vertical: Dimens.paddingX3,
        ),
        decoration: boxDecorationRoundedWithShadow(
          Dimens.radiusX4,
          border: Border.all(color: AppPalettes.primaryColor, width: 1),
        ),
        child: Stack(
          alignment: AlignmentGeometry.centerRight,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimens.gapX2,
              children: [
                SizedBox(
                  height: Dimens.scaleX6,
                  width: Dimens.scaleX6,
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(
                      Dimens.radius100,
                    ),
                    child: CommonHelpers.getCacheNetworkImage(member.avatar),
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: Dimens.gapX,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TranslatedText(
                        text: member.name.isNull(localization.not_found),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // if (member.phone?.isNotEmpty == true)
                      //   Row(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //         "${localization.phone_no} : ",
                      //         style: textTheme.bodySmall?.copyWith(
                      //           color: AppPalettes.lightTextColor,
                      //         ),
                      //       ),
                      //       Expanded(
                      //         child: Text(
                      //           member.phone ?? "",
                      //           style: textTheme.bodySmall,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${localization.email} : ",
                            style: textTheme.bodySmall?.copyWith(
                              color: AppPalettes.lightTextColor,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              member.email.isNull(localization.not_found),
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Dimens.gapX1,
                        children: [
                          CommonHelpers.buildIcons(
                            path: AppImages.locationIcon,
                            iconSize: Dimens.scaleX2,
                            iconColor: AppPalettes.blackColor,
                          ),
                          Expanded(
                            child: FutureBuilder<String>(
                              key: ValueKey('location_${member.sId}_${member.address}'), // Force rebuild when member or address changes
                              future: _getLocationText(member, localization),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Text(
                                    "Loading location...",
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppPalettes.lightTextColor,
                                    ),
                                    maxLines: 2,
                                  );
                                }
                                
                                if (snapshot.hasError) {
                                  return Text(
                                    localization.not_found,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppPalettes.lightTextColor,
                                    ),
                                    maxLines: 2,
                                  );
                                }
                                
                                return TranslatedText(
                                  text: snapshot.data ?? localization.not_found,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppPalettes.lightTextColor,
                                  ),
                                  maxLines: 2,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (showIcon)
                  Icon(
                    CupertinoIcons.captions_bubble,
                    size: Dimens.scaleX2,
                    color: AppPalettes.transparentColor,
                  ).allPadding(Dimens.paddingX2),
              ],
            ),
            if (showIcon)
              Container(
                decoration: boxDecorationRoundedWithShadow(
                  Dimens.radius100,
                  backgroundColor: AppPalettes.liteGreenColor,
                ),
                padding: EdgeInsets.all(Dimens.paddingX2),
                child: Icon(
                  CupertinoIcons.captions_bubble,
                  size: Dimens.scaleX2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
