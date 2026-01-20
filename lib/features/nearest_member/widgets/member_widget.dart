import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
import 'package:inldsevak/features/party_member/services/party_member_repository.dart';
import 'package:inldsevak/features/party_member/model/request/request_member_details.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';

class MemberWidget extends StatefulWidget {
  final PartyMember member;
  final bool showIcon;
  final Function() onTap;
  final bool isUsingSearchedLocation; // true if user searched for location, false if using live GPS
  const MemberWidget({
    super.key,
    required this.member,
    required this.onTap,
    required this.showIcon,
    this.isUsingSearchedLocation = false, // Default to live location
  });

  @override
  State<MemberWidget> createState() => _MemberWidgetState();
}

class _MemberWidgetState extends State<MemberWidget> {
  late PartyMember _member;
  bool _isFetchingDetails = false;

  @override
  void initState() {
    super.initState();
    _member = widget.member;
    // Fetch user details if location data is missing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserDetailsIfNeeded();
    });
  }

  @override
  void didUpdateWidget(MemberWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.member.sId != widget.member.sId) {
      _member = widget.member;
      _fetchUserDetailsIfNeeded();
    }
  }

  Future<void> _fetchUserDetailsIfNeeded() async {
    // Check if we have location data
    final hasAddressFields = (_member.flatNumber != null && _member.flatNumber!.trim().isNotEmpty) ||
        (_member.area != null && _member.area!.trim().isNotEmpty) ||
        (_member.city != null && _member.city!.trim().isNotEmpty);
    final hasAddress = _member.address != null && _member.address!.trim().isNotEmpty;
    final hasCoordinates = _member.location?.coordinates != null && 
        _member.location!.coordinates!.length >= 2;

    // Only fetch if all location data is missing and we have a phone number
    if (!hasAddressFields && !hasAddress && !hasCoordinates && 
        _member.phone != null && _member.phone!.isNotEmpty && 
        !_isFetchingDetails && mounted) {
      _isFetchingDetails = true;
      try {
        final token = await SessionController.instance.getToken();
        if (token == null || token.isEmpty) {
          return;
        }
        
        final request = RequestMemberDetails(phoneNumber: _member.phone!);
        final response = await PartyMemberRepository().getUserDetails(
          data: request,
          token: token,
        );

        if (response.data?.responseCode == 200 && mounted) {
          final user = response.data?.data?.user;
          
          if (user != null) {
            // Check if we got better location data
            final hasBetterAddressFields = (user.flatNumber != null && user.flatNumber!.trim().isNotEmpty) ||
                (user.area != null && user.area!.trim().isNotEmpty) ||
                (user.city != null && user.city!.trim().isNotEmpty);
            final hasBetterAddress = user.address != null && user.address!.trim().isNotEmpty;
            final hasBetterLocation = user.location?.coordinates != null && 
                user.location!.coordinates!.length >= 2;
            
            if (hasBetterAddressFields || hasBetterAddress || hasBetterLocation) {
              setState(() {
                _member = PartyMember(
                  sId: _member.sId ?? user.sId,
                  name: _member.name ?? user.name,
                  email: _member.email ?? user.email,
                  phone: _member.phone ?? user.phone,
                  address: _member.address ?? user.address,
                  flatNumber: _member.flatNumber ?? user.flatNumber,
                  area: _member.area ?? user.area,
                  city: _member.city ?? user.city,
                  district: _member.district ?? user.district,
                  state: _member.state ?? user.state,
                  avatar: _member.avatar ?? user.avatar,
                  location: _member.location ?? user.location,
                  distance: _member.distance,
                  partyMemberDetails: _member.partyMemberDetails,
                );
              });
            }
          }
        }
      } catch (e) {
        // Silently handle errors
      } finally {
        if (mounted) {
          _isFetchingDetails = false;
        }
      }
    }
  }

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

  // Build readable address from address fields
  String? _buildAddressFromFields(PartyMember member) {
    final parts = <String>[];
    
    // Add flat number if available
    if (member.flatNumber != null && member.flatNumber!.trim().isNotEmpty) {
      parts.add(member.flatNumber!.trim());
    }
    
    // Add area if available
    if (member.area != null && member.area!.trim().isNotEmpty) {
      parts.add(member.area!.trim());
    }
    
    // Add city if available
    if (member.city != null && member.city!.trim().isNotEmpty) {
      parts.add(member.city!.trim());
    }
    
    // Add district if available (and different from city)
    if (member.district != null && 
        member.district!.trim().isNotEmpty && 
        member.district!.trim().toLowerCase() != member.city?.trim().toLowerCase()) {
      parts.add(member.district!.trim());
    }
    
    // Add state if available
    if (member.state != null && member.state!.trim().isNotEmpty) {
      parts.add(member.state!.trim());
    }
    
    if (parts.isNotEmpty) {
      return parts.join(', ');
    }
    
    return null;
  }

  Future<String> _getLocationText(PartyMember member, dynamic localization) async {
    // Use the updated member from state
    final currentMember = _member;
    
    // First priority: Use address fields (flatNumber, area, city, district, state)
    final addressFromFields = _buildAddressFromFields(currentMember);
    if (addressFromFields != null && addressFromFields.isNotEmpty) {
      return addressFromFields;
    }
    
    // Second priority: If address field is available and not empty, use it
    if (currentMember.address != null && currentMember.address!.trim().isNotEmpty) {
      return currentMember.address!;
    }
    
    // If address is empty but coordinates are available
    if (currentMember.location?.coordinates != null && 
        currentMember.location!.coordinates!.length >= 2) {
      
      // Note: API returns coordinates as [latitude, longitude] (not GeoJSON standard [longitude, latitude])
      // Based on API response: [28.4523037, 77.0909801] where 28 is latitude and 77 is longitude
      final lat = currentMember.location!.coordinates![0]; // First element is latitude
      final lng = currentMember.location!.coordinates![1]; // Second element is longitude
      
      // If using live location (not searched), show coordinates directly
      if (!widget.isUsingSearchedLocation) {
        // Display as: latitude, longitude
        return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
      }
      
      // If using searched location, try geocoding to get address
      try {
        // API returns [latitude, longitude], Google Geocoding API expects: latlng=latitude,longitude
        // So we use coordinates[0] as latitude and coordinates[1] as longitude directly
        final response = await GoogleRepository().placeFromCoordinates(
          lat: lat,  // coordinates[0] is latitude
          lng: lng,  // coordinates[1] is longitude
        );
        
        // Check for API errors first
        if (response.error != null) {
          // Fall through to coordinates fallback
        } else if (response.data != null && response.data!.status == "OK" && response.data!.results != null && response.data!.results!.isNotEmpty) {
          // Try to find the best result - look through results to find one with locality or administrative_area
          AddressModel? bestAddressModel;
          
          // First, try the default parsing
          bestAddressModel = AddressModel.fromGeocodingModel(response.data!);
          
          // If first result doesn't have good data, try other results
          if ((bestAddressModel.city == null || bestAddressModel.city!.isEmpty) &&
              (bestAddressModel.district == null || bestAddressModel.district!.isEmpty)) {
            
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
                
                if ((testModel.city != null && testModel.city!.isNotEmpty) ||
                    (testModel.district != null && testModel.district!.isNotEmpty)) {
                  bestAddressModel = testModel;
                  break;
                }
              }
            }
          }
          
          if (bestAddressModel != null) {
            final locationText = _extractReadableLocation(bestAddressModel);
            
            if (locationText != null && locationText.isNotEmpty) {
              return locationText;
            } else {
              // Last resort: try to use formattedAddress if it exists and is reasonable
              final formattedAddr = bestAddressModel.formattedAddress;
              if (formattedAddr != null && 
                  formattedAddr.isNotEmpty && 
                  !_isPlusCode(formattedAddr) &&
                  formattedAddr.length > 10) {
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
        }
      } catch (e) {
        // Silently handle errors
      }
      
      // If geocoding fails or no readable location found, show coordinates as fallback
      // This only happens when using searched location (for live location, we already returned coordinates above)
      // Use the lat and lng variables already defined above
      return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
    }
    
    // If no address and no coordinates, return "not found"
    return localization.not_found;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;
    return GestureDetector(
      onTap: widget.onTap,
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
                    child: CommonHelpers.getCacheNetworkImage(_member.avatar),
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: Dimens.gapX,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _member.name.isNull(localization.not_found),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                       
                      ),
                      // if (_member.phone?.isNotEmpty == true)
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
                      //           _member.phone ?? "",
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
                              _member.email.isNull(localization.not_found),
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
                              key: ValueKey('location_${_member.sId}_${_member.flatNumber}_${_member.city}_${_member.location?.coordinates}'), // Force rebuild when member data changes
                              future: _getLocationText(_member, localization),
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
                if (widget.showIcon)
                  Icon(
                    CupertinoIcons.captions_bubble,
                    size: Dimens.scaleX2,
                    color: AppPalettes.transparentColor,
                  ).allPadding(Dimens.paddingX2),
              ],
            ),
            if (widget.showIcon)
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
