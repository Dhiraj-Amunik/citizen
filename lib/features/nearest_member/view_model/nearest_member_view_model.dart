import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/common_fields/model/address_model.dart';
import 'package:inldsevak/features/common_fields/model/geocoding_model.dart';
import 'package:inldsevak/features/common_fields/services/search_repository.dart';
import 'package:inldsevak/features/nearest_member/model/my_location_request_model.dart';
import 'package:inldsevak/features/nearest_member/model/nearest_members_model.dart';
import 'package:inldsevak/features/nearest_member/services/nearest_member_repository.dart';
import 'package:inldsevak/features/home/services/dashboard_repository.dart';
import 'package:inldsevak/features/home/models/request/dashboard_request_model.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:ui' as ui;

class NearestMemberViewModel extends BaseViewModel with CupertinoDialogMixin {
  bool _isLoadingMembers = false; // Flag to prevent concurrent loads
  bool _isLoadingChats = false; // Flag to prevent concurrent chat loads
  bool _hasInitialized = false; // Flag to prevent duplicate initialization
  bool _isUpdatingSearchController = false; // Flag to prevent onChanged loop when programmatically updating search controller
  String? _currentProcessingPlaceID; // Track which placeID is currently being processed
  bool _isDisposed = false; // Flag to track if view model is disposed
  
  @override
  Future<void> onInit() {
    if (!_hasInitialized) {
      _hasInitialized = true;
      sequenceTasks();
    }
    return super.onInit();
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Cancel any pending post-frame callbacks by clearing the search controller safely
    try {
      _isUpdatingSearchController = true;
      // Don't set value in dispose, just mark as disposed
    } catch (e) {
      // Ignore any errors during dispose
    }
    _isUpdatingSearchController = false;
    super.dispose();
  }

  void sequenceTasks() async {
    // Ensure we're not already loading before starting
    if (_isLoadingMembers) {
      debugPrint("⚠️ sequenceTasks() - getMembers already in progress, skipping");
      return;
    }
    searchplaces.clear();
    // Only call getMembers once - it will handle location fetching internally
    // If we already have location cached, use it immediately
    // Otherwise, getMembers will fetch location using fallback chain
    getMembers();
    // Fetch chats to get unread count
    getUnreadChatCount();
  }
  
  /// Fetch chats and calculate total unread count
  /// This is called when landing on the nearest member view to show green dot on inbox icon
  Future<void> getUnreadChatCount() async {
    // Prevent concurrent loads - if already loading, return early
    if (_isLoadingChats) {
      debugPrint("⚠️ getUnreadChatCount() already in progress, skipping duplicate call");
      return;
    }
    
    _isLoadingChats = true;
    try {
      debugPrint("📬 Fetching unread chat count...");
      final response = await _chatRepository.getMyChats(token: token);
      
      if (response.data?.responseCode == 200) {
        final chatsList = response.data?.data;
        if (chatsList != null && chatsList.isNotEmpty) {
          // Calculate total unread count from parsed model
          totalUnreadCount = chatsList.fold<int>(
            0,
            (sum, chat) {
              final unread = chat.unreadMessages ?? 0;
              debugPrint("📬 Chat ${chat.chatId}: unreadMessages = $unread");
              return sum + unread;
            },
          );
          debugPrint("📬 Total unread messages: $totalUnreadCount");
          notifyListeners();
        } else {
          debugPrint("📬 No chats found or empty list");
          totalUnreadCount = 0;
          notifyListeners();
        }
      } else {
        debugPrint("⚠️ Failed to fetch unread chat count: ${response.data?.responseCode}");
        totalUnreadCount = 0;
        notifyListeners();
      }
    } catch (err) {
      debugPrint("❌ Error fetching unread chat count: $err");
      totalUnreadCount = 0;
      notifyListeners();
    } finally {
      _isLoadingChats = false; // Reset flag to allow future calls
    }
  }

  Position? currentPosition;
  Position? searchedPosition;
  
  AddressModel? currentAddress;
  AddressModel? searchedAddress; // Store the searched location address
  String? searchedLocationName; // Store readable name of searched location
  
  // Get current location coordinates as string
  String? get currentLocationCoordinates {
    if (currentPosition != null) {
      return "Latitude: ${currentPosition!.latitude.toStringAsFixed(6)}, Longitude: ${currentPosition!.longitude.toStringAsFixed(6)}";
    }
    return null;
  }
  
  // Get current location coordinates in array format [lat, lng]
  List<double>? get currentLocationCoordinatesArray {
    if (currentPosition != null) {
      return [currentPosition!.latitude, currentPosition!.longitude];
    }
    return null;
  }

  List<PartyMember> membersList = [];
  Set<Marker> markers = {};

  // Chat-related properties
  int totalUnreadCount = 0;
  final NearestMemberRepository _chatRepository = NearestMemberRepository();

  final SingleSelectController<Predictions?> searchController =
      SingleSelectController(null);

  // Distance filter - slider value (1-100 km)
  double _radiusValue = 50.0; // Default to 50 km
  double get radiusValue => _radiusValue;
  
  setRadius(double value) {
    // Ensure minimum radius of 1 km
    _radiusValue = value < 1.0 ? 1.0 : value;
    notifyListeners();
  }

  clearDistance() {
    _radiusValue = 50.0; // Reset to default
    notifyListeners();
  }

  // Clear searched position to go back to using live GPS location
  clearSearchedLocation() {
    searchedPosition = null;
    searchedAddress = null;
    searchedLocationName = null;
    _currentProcessingPlaceID = null; // Reset processing flag
    _isUpdatingSearchController = true; // Prevent onChanged from triggering
    try {
      if (!_isDisposed) {
        searchController.value = null; // Clear the search controller
      }
    } catch (e) {
      // Ignore setState after dispose errors
      debugPrint("⚠️ Could not clear search controller: $e");
    }
    _isUpdatingSearchController = false;
    notifyListeners();
    getMembers(); // Refresh with live location - this will update search bar with current location
  }

  Future<void> getMembers() async {
    // Prevent concurrent loads - if already loading, return early
    if (_isLoadingMembers) {
      debugPrint("⚠️ getMembers() already in progress, skipping duplicate call");
      return;
    }
    
    _isLoadingMembers = true;
    markers = {};
    isLoading = true;
    try {
      // Get location coordinates (prioritize searched location over live GPS)
      double? latitude;
      double? longitude;
      
      // Priority 1: Use searched position if user explicitly searched for a location
      if (searchedPosition != null) {
        // Note: searchedPosition has swapped coordinates (lng stored as latitude, lat stored as longitude)
        // for backend API compatibility. We need to swap them back for the API request.
        // The API expects [latitude, longitude], so we use longitude as latitude and latitude as longitude
        latitude = searchedPosition!.longitude; // This is actually the lat from Google API
        longitude = searchedPosition!.latitude; // This is actually the lng from Google API
        debugPrint("📍 Using searched position (swapped back): $latitude, $longitude");
      } else {
        // Priority 2: Try last known position first (fastest, no waiting)
        try {
          final lastKnownPosition = await Geolocator.getLastKnownPosition();
          if (lastKnownPosition != null) {
            latitude = lastKnownPosition.latitude;
            longitude = lastKnownPosition.longitude;
            currentPosition = lastKnownPosition; // Cache it
            debugPrint("📍 Using last known position: $latitude, $longitude");
            // Update search bar with last known location (non-blocking)
            unawaited(_updateSearchBarWithCurrentLocation());
          }
        } catch (e) {
          debugPrint("⚠️ Error getting last known position: $e");
          // Check if error is due to permission
          if (e.toString().contains('permission') || e.toString().contains('denied')) {
            // Check and request permission if needed
            LocationPermission permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
              // If still denied, checkPermission() will handle it below
            }
          }
        }
        
        // Priority 3: If no last known position, try to get fresh GPS (with timeout)
        if (latitude == null || longitude == null) {
          await checkPermission();
          
          // If we got a fresh position, use it
          if (currentPosition != null) {
            latitude = currentPosition!.latitude;
            longitude = currentPosition!.longitude;
            debugPrint("📍 Using fresh live GPS location: $latitude, $longitude");
            
            // Update search bar with current location address (non-blocking)
            unawaited(_updateSearchBarWithCurrentLocation());
            
            // Update user-dashboard API with live coordinates (non-blocking, runs in background)
            // This is done asynchronously to not block the main request
            unawaited(
              Future.microtask(() async {
                try {
                  final dashboardRequestModel = DashboardRequestModel(
                    latitude: currentPosition!.latitude,
                    longitude: currentPosition!.longitude,
                  );
                  
                  debugPrint("📤 Updating user-dashboard with live coordinates: ${currentPosition!.latitude}, ${currentPosition!.longitude}");
                  debugPrint("📤 Dashboard POST payload coordinates: ${dashboardRequestModel.toJson()['coordinates']}");
                  
                  // Call user-dashboard API to update server (fire and forget, don't wait for response)
                  final dashboardResponse = await DashboardRepository().fetchUserDashboard(
                    token: token,
                    model: dashboardRequestModel,
                  );
                  
                  if (dashboardResponse.data?.responseCode == 200) {
                    debugPrint("✅ User-dashboard updated successfully with live coordinates");
                    // Optionally extract and log the returned coordinates for verification
                    final returnedUserData = dashboardResponse.data?.data?.user ?? 
                                           dashboardResponse.data?.data?.userDetails;
                    final returnedLocation = returnedUserData?.location;
                    if (returnedLocation?.coordinates != null && returnedLocation!.coordinates!.length >= 2) {
                      debugPrint("📍 Dashboard returned coordinates (raw): ${returnedLocation.coordinates} [lng, lat]");
                    }
                  } else {
                    debugPrint("⚠️ Dashboard update failed with response code: ${dashboardResponse.data?.responseCode}");
                  }
                } catch (e) {
                  debugPrint("⚠️ Error updating user-dashboard (non-critical): $e");
                }
              }),
            );
          }
        }
        
        // Priority 4: Try dashboard API only if we still don't have coordinates (with shorter timeout)
        if (latitude == null || longitude == null) {
          try {
            final token = await SessionController.instance.getToken();
            
            // Try GET dashboard API with shorter 3 second timeout for faster fallback
            final dashboardResponse = await DashboardRepository()
                .fetchDashboard(token: token)
                .timeout(
                  const Duration(seconds: 3), // Reduced from 5 to 3 seconds
                  onTimeout: () {
                    debugPrint("⚠️ Dashboard API timeout - skipping fallback");
                    throw TimeoutException("Dashboard API timeout");
                  },
                );
            
            if (dashboardResponse.data?.responseCode == 200) {
              final userData = dashboardResponse.data?.data?.user ?? 
                             dashboardResponse.data?.data?.userDetails;
              final userLocation = userData?.location;
              
              if (userLocation?.coordinates != null && userLocation!.coordinates!.length >= 2) {
                // Dashboard API stores coordinates in GeoJSON format: [longitude, latitude]
                // Swap them before using anywhere else in the app
                final rawLng = userLocation.coordinates![0];
                final rawLat = userLocation.coordinates![1];
                latitude = rawLat;
                longitude = rawLng;
                debugPrint("📍 Dashboard response coordinates array (raw GeoJSON): ${userLocation.coordinates}");
                debugPrint("📍 Swapped dashboard coordinates -> Latitude: $latitude, Longitude: $longitude");
                
                // Create a Position object from dashboard coordinates
                currentPosition = Position(
                  latitude: latitude,
                  longitude: longitude,
                  timestamp: DateTime.now(),
                  accuracy: 0,
                  altitude: 0,
                  altitudeAccuracy: 0,
                  heading: 0,
                  headingAccuracy: 0,
                  speed: 0,
                  speedAccuracy: 0,
                );
                // Update search bar with dashboard location
                unawaited(_updateSearchBarWithCurrentLocation());
              } else {
                debugPrint("⚠️ Dashboard API response missing or invalid coordinates");
              }
            }
          } catch (e) {
            debugPrint("Error fetching dashboard coordinates: $e");
            // Continue to next fallback if dashboard API fails
          }
        }
        
        // Priority 5: Final fallback - show error if we still don't have coordinates
        if (latitude == null || longitude == null) {
          // Final fallback - show error
          _isLoadingMembers = false; // Reset flag
          isLoading = false;
          notifyListeners();
          RouteManager.pop();
          CommonSnackbar(
            text: "Location Permission required!",
          ).showAnimatedDialog(type: QuickAlertType.error);
          return;
        }
      }
      
      // Convert radius value to integer for API (round to nearest integer, minimum 1 km)
      int? radiusInKm = (_radiusValue < 1.0 ? 1.0 : _radiusValue).round();
      
      // Ensure radius is at least 1 km for API
      if (radiusInKm < 1) {
        radiusInKm = 1;
      }
      
      // Create request model with coordinates in format [latitude, longitude]
      final model = MyCurrentLocationRequestModel(
        latitude: latitude,
        longitude: longitude,
        page: 1,
        pageSize: 100,
        radius: radiusInKm,
      );
      
      debugPrint("═══════════════════════════════════════");
      debugPrint("📤 Nearest Member API Request:");
      debugPrint("   Coordinates: [$latitude, $longitude] (format: [latitude, longitude])");
      debugPrint("   Radius: $radiusInKm km");
      debugPrint("   Request payload: ${model.toJson()}");
      debugPrint("═══════════════════════════════════════");
      
      final response = await NearestMemberRepository().getNearestMember(
        token,
        model: model,
      );

      if (response.error != null) {
        debugPrint("API Error: ${response.error}");
        membersList = [];
        _isLoadingMembers = false; // Reset flag
        isLoading = false;
        notifyListeners();
        return;
      }

      if (response.data?.responseCode == 200) {
        debugPrint("API Response - responseCode: ${response.data?.responseCode}");
        debugPrint("API Response - message: ${response.data?.message}");
        debugPrint("API Response - data object: ${response.data?.data}");
        debugPrint("API Response - data is null: ${response.data?.data == null}");
        debugPrint("API Response - totalPartyMember: ${response.data?.data?.totalPartyMember}");
        
        final data = response.data?.data?.partyMember;
        debugPrint("API Response - partyMember data: $data");
        debugPrint("API Response - partyMember is null: ${data == null}");
        debugPrint("API Response - partyMember is List: ${data is List}");
        debugPrint("API Response - partyMember length: ${data?.length ?? 0}");
        
        if (data != null && data.isNotEmpty) {
          membersList = data;
          debugPrint("✓ Members list updated with ${membersList.length} members");
          
          // Show UI immediately with member list, then load markers asynchronously
          _isLoadingMembers = false;
          isLoading = false;
          notifyListeners(); // Notify to show member list immediately
          
          // Load markers asynchronously in background (non-blocking)
          unawaited(
            Future.microtask(() async {
              try {
                await _addUsersToMap();
                debugPrint("✓ Markers added to map: ${markers.length} markers");
                if (!_isDisposed) {
                  notifyListeners(); // Update UI with markers when ready
                }
              } catch (e, stackTrace) {
                debugPrint("❌ Error adding markers to map: $e");
                debugPrint("Stack trace: $stackTrace");
                // Don't clear membersList if marker creation fails
              }
            }),
          );
        } else {
          membersList = [];
          debugPrint("✗ No party members in response or list is empty");
          if (data == null) {
            debugPrint("✗ partyMember is null");
          } else if (data.isEmpty) {
            debugPrint("✗ partyMember list is empty");
          }
          _isLoadingMembers = false;
          isLoading = false;
          notifyListeners();
        }
      } else {
        debugPrint("✗ Response code is not 200: ${response.data?.responseCode}");
        debugPrint("Response message: ${response.data?.message}");
        membersList = [];
        _isLoadingMembers = false;
        isLoading = false;
        notifyListeners();
      }
      
      // Move camera asynchronously (non-blocking)
      unawaited(shiftCameraPositions());
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
      _isLoadingMembers = false;
      isLoading = false;
      notifyListeners();
    }
  }

  final Completer<GoogleMapController> mapController = Completer();
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(20.5937, 78.9629),
  );

  getCurrentLocation() async {
    try {
      // Check permission first before getting location
      await checkPermission();
      
      // If we still don't have position after checkPermission, try to get it
      if (currentPosition == null) {
        try {
          currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 5),
          );
        } catch (e) {
          debugPrint("⚠️ Error getting current position in getCurrentLocation: $e");
          // Check if error is due to permission
          if (e.toString().contains('permission') || e.toString().contains('denied')) {
            // Re-check and request permission again
            LocationPermission permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
              if (permission == LocationPermission.whileInUse ||
                  permission == LocationPermission.always) {
                try {
                  currentPosition = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.low,
                    timeLimit: const Duration(seconds: 5),
                  );
                } catch (e2) {
                  debugPrint("⚠️ Error getting position after permission retry: $e2");
                }
              } else if (permission == LocationPermission.deniedForever) {
                await customRightCupertinoDialog(
                  content:
                      "Location permission is denied permanently. Please enable it in settings.",
                  rightButton: "Open Settings",
                  onTap: () async {
                    RouteManager.pop();
                    await Geolocator.openAppSettings();
                  },
                );
                return;
              }
            }
          }
          // Try last known position as fallback
          if (currentPosition == null) {
            try {
              currentPosition = await Geolocator.getLastKnownPosition();
            } catch (e2) {
              debugPrint("⚠️ Error getting last known position: $e2");
            }
          }
        }
      }
      
      Position? position = currentPosition;
      
      // Log current location coordinates
      if (position != null) {
        debugPrint("═══════════════════════════════════════");
        debugPrint("📍 YOUR CURRENT LOCATION COORDINATES:");
        debugPrint("Latitude: ${position.latitude.toStringAsFixed(6)}");
        debugPrint("Longitude: ${position.longitude.toStringAsFixed(6)}");
        debugPrint("Coordinates Array: [${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}]");
        debugPrint("Accuracy: ${position.accuracy.toStringAsFixed(2)} meters");
        debugPrint("═══════════════════════════════════════");
      }
      
      cameraPosition = CameraPosition(
        target: LatLng(
          position?.latitude ?? 20.5937,
          position?.longitude ?? 78.9629,
        ),
        zoom: position?.latitude != null && position?.longitude != null ? 18 : 3,
      );

      final GoogleMapController cont = await mapController.future;
      cont.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Error in getCurrentLocation: $e");
      // Check if error is due to permission
      if (e.toString().contains('permission') || e.toString().contains('denied')) {
        await checkPermission();
      }
    }
  }

  checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Use faster location options - don't wait for high accuracy if not needed
      try {
        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low, // Use low accuracy for faster response
          timeLimit: const Duration(seconds: 5), // Reduced from 10 to 5 seconds
        );
        // Log coordinates when permission is granted
        if (currentPosition != null) {
          debugPrint("📍 Current Location: ${currentPosition!.latitude.toStringAsFixed(6)}, ${currentPosition!.longitude.toStringAsFixed(6)}");
        }
      } catch (e) {
        debugPrint("⚠️ Error getting current position: $e");
        // Check if error is due to permission
        if (e.toString().contains('permission') || e.toString().contains('denied')) {
          // Re-check permission and retry
          permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.whileInUse ||
                permission == LocationPermission.always) {
              try {
                currentPosition = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.low,
                  timeLimit: const Duration(seconds: 5),
                );
                if (currentPosition != null) {
                  debugPrint("📍 Current Location (retry): ${currentPosition!.latitude.toStringAsFixed(6)}, ${currentPosition!.longitude.toStringAsFixed(6)}");
                }
                return;
              } catch (e2) {
                debugPrint("⚠️ Error getting position after retry: $e2");
              }
            }
          }
        }
        // Try with last known position as fallback
        try {
          currentPosition = await Geolocator.getLastKnownPosition();
          if (currentPosition != null) {
            debugPrint("📍 Using last known position: ${currentPosition!.latitude.toStringAsFixed(6)}, ${currentPosition!.longitude.toStringAsFixed(6)}");
          }
        } catch (e2) {
          debugPrint("⚠️ Error getting last known position: $e2");
        }
      }
      return; // Exit early if we got permission
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      // If still denied after request, ask again
      if (permission == LocationPermission.denied) {
        // Show dialog to inform user and ask again
        await customRightCupertinoDialog(
          content: "Location permission is required to fetch your location. Please grant permission.",
          rightButton: "Grant Permission",
          onTap: () async {
            RouteManager.pop();
            // Request permission again
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.whileInUse ||
                permission == LocationPermission.always) {
              try {
                currentPosition = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.low,
                  timeLimit: const Duration(seconds: 5),
                );
                if (currentPosition != null) {
                  debugPrint("📍 Current Location (after retry): ${currentPosition!.latitude.toStringAsFixed(6)}, ${currentPosition!.longitude.toStringAsFixed(6)}");
                }
              } catch (e) {
                debugPrint("⚠️ Error getting position after permission granted: $e");
                try {
                  currentPosition = await Geolocator.getLastKnownPosition();
                } catch (e2) {
                  debugPrint("⚠️ Error getting last known position: $e2");
                }
              }
            } else if (permission == LocationPermission.deniedForever) {
              await customRightCupertinoDialog(
                content:
                    "Location permission is denied permanently. Please enable it in settings.",
                rightButton: "Open Settings",
                onTap: () async {
                  RouteManager.pop();
                  await Geolocator.openAppSettings();
                },
              );
            }
          },
        );
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        try {
          currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low, // Use low accuracy for faster response
            timeLimit: const Duration(seconds: 5), // Reduced from 10 to 5 seconds
          );
        } catch (e) {
          debugPrint("⚠️ Error getting position after permission granted: $e");
          // Check if error is due to permission
          if (e.toString().contains('permission') || e.toString().contains('denied')) {
            // Re-check permission
            permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
            }
          }
          try {
            currentPosition = await Geolocator.getLastKnownPosition();
          } catch (e2) {
            debugPrint("⚠️ Error getting last known position: $e2");
          }
        }
      }
      return; // Exit early
    }

    if (permission == LocationPermission.deniedForever) {
      await customRightCupertinoDialog(
        content:
            "Location permission is denied permanently. Please enable it in settings.",
        rightButton: "Open Settings",
        onTap: () async {
          RouteManager.pop();
          await Geolocator.openAppSettings();
        },
      );
      return; // Exit early
    }
    
    // Final attempt if we still don't have position
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      try {
        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low, // Use low accuracy for faster response
          timeLimit: const Duration(seconds: 5), // Reduced from 10 to 5 seconds
        );
      } catch (e) {
        debugPrint("⚠️ Error in final position attempt: $e");
        try {
          currentPosition = await Geolocator.getLastKnownPosition();
        } catch (e2) {
          debugPrint("⚠️ Error getting last known position: $e2");
        }
      }
    }
  }

  Future<void> getCoordinatesPlace() async {
    if (currentPosition == null) {
      checkPermission();
    }

    isLoading = true;
    List<Results> currentLocationList = [];

    try {
      final response = await GoogleRepository().placeFromCoordinates(
        lat: currentPosition!.latitude,
        lng: currentPosition!.longitude,
      );

      if (response.data?.status == "OK") {
        currentLocationList.addAll(List.from(response.data?.results as List));
        currentAddress = AddressModel.fromGeocodingModel(response.data!);
        notifyListeners();
      }
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      isLoading = false;
    }
  }

  // Update search bar with current live location address
  Future<void> _updateSearchBarWithCurrentLocation() async {
    if (currentPosition == null || searchedPosition != null || _isDisposed) {
      // Don't update if no position, if user has searched for a location, or if disposed
      return;
    }

    try {
      final response = await GoogleRepository().placeFromCoordinates(
        lat: currentPosition!.latitude,
        lng: currentPosition!.longitude,
      );

      // Check again after async operation - widget might be disposed
      if (_isDisposed) {
        return;
      }

      if (response.data?.status == "OK" && response.data?.results != null && response.data!.results!.isNotEmpty) {
        final firstResult = response.data!.results!.first;
        final placeId = firstResult.placeId ?? "";
        
        // Build readable address from address components (exclude Plus Codes)
        String readableAddress = _buildReadableAddress(firstResult);
        
        // If readable address is empty, fallback to formatted address but remove Plus Code
        if (readableAddress.isEmpty) {
          readableAddress = _removePlusCodeFromAddress(firstResult.formattedAddress ?? "");
        }

        // Create a Predictions object from the reverse geocoding result
        final prediction = Predictions(
          description: readableAddress,
          placeId: placeId,
          structuredFormatting: StructuredFormatting(
            mainText: readableAddress.split(',').first.trim(),
            secondaryText: readableAddress.split(',').skip(1).join(',').trim(),
          ),
        );

        // Update search controller with current location
        if (!_isDisposed) {
          _isUpdatingSearchController = true;
          try {
            searchController.value = prediction;
            currentAddress = AddressModel.fromGeocodingModel(response.data!);
            if (!_isDisposed) {
              notifyListeners();
            }
            debugPrint("✅ Search bar updated with current location: $readableAddress");
          } catch (e) {
            final errorString = e.toString();
            final isDisposeError = errorString.contains('setState') &&
                (errorString.contains('dispose') ||
                    errorString.contains('defunct') ||
                    errorString.contains('not mounted') ||
                    errorString.contains('lifecycle state'));
            if (!isDisposeError) {
              debugPrint("⚠️ Could not update search controller: $e");
            }
          } finally {
            _isUpdatingSearchController = false;
          }
        }
      }
    } catch (err) {
      debugPrint("⚠️ Error updating search bar with current location: $err");
    }
  }

  // Build readable address from address components, excluding Plus Codes
  String _buildReadableAddress(Results result) {
    if (result.addressComponents == null || result.addressComponents!.isEmpty) {
      return "";
    }

    final components = result.addressComponents!;
    final parts = <String>[];

    // Extract relevant address components in order
    String? streetNumber;
    String? route;
    String? sublocality;
    String? locality;
    String? administrativeAreaLevel2; // District
    String? administrativeAreaLevel1; // State
    String? postalCode;

    for (var component in components) {
      final types = component.types ?? [];
      final longName = component.longName ?? "";
      
      if (types.contains("street_number") && longName.isNotEmpty) {
        streetNumber = longName;
      } else if (types.contains("route") && longName.isNotEmpty) {
        route = longName;
      } else if (types.contains("sublocality") || types.contains("sublocality_level_1") || types.contains("sublocality_level_2")) {
        if (sublocality == null || sublocality.isEmpty) {
          sublocality = longName;
        }
      } else if (types.contains("locality") && longName.isNotEmpty) {
        locality = longName;
      } else if (types.contains("administrative_area_level_2") && longName.isNotEmpty) {
        administrativeAreaLevel2 = longName;
      } else if (types.contains("administrative_area_level_1") && longName.isNotEmpty) {
        administrativeAreaLevel1 = longName;
      } else if (types.contains("postal_code") && longName.isNotEmpty) {
        postalCode = longName;
      }
    }

    // Build address in readable format
    if (streetNumber != null && route != null) {
      parts.add("$streetNumber $route");
    } else if (route != null) {
      parts.add(route);
    } else if (streetNumber != null) {
      parts.add(streetNumber);
    }

    if (sublocality != null && sublocality.isNotEmpty) {
      parts.add(sublocality);
    }

    if (locality != null && locality.isNotEmpty) {
      parts.add(locality);
    } else if (administrativeAreaLevel2 != null && administrativeAreaLevel2.isNotEmpty) {
      parts.add(administrativeAreaLevel2);
    }

    if (administrativeAreaLevel1 != null && administrativeAreaLevel1.isNotEmpty) {
      parts.add(administrativeAreaLevel1);
    }

    if (postalCode != null && postalCode.isNotEmpty) {
      parts.add(postalCode);
    }

    return parts.join(", ");
  }

  // Remove Plus Code from formatted address (e.g., "mxgw+mxv sarada colony" -> "sarada colony")
  String _removePlusCodeFromAddress(String formattedAddress) {
    if (formattedAddress.isEmpty) return "";
    
    // Plus Code pattern: typically looks like "XXXX+XX" or "XXXX+XX Location Name"
    // Remove Plus Code pattern (alphanumeric + alphanumeric pattern)
    final plusCodePattern = RegExp(r'[A-Z0-9]{4}\+[A-Z0-9]{2,4}\s*', caseSensitive: false);
    String cleaned = formattedAddress.replaceAll(plusCodePattern, '').trim();
    
    // Also remove standalone Plus Codes at the end
    cleaned = cleaned.replaceAll(RegExp(r',\s*[A-Z0-9]{4}\+[A-Z0-9]{2,4}$', caseSensitive: false), '');
    
    return cleaned.isEmpty ? formattedAddress : cleaned;
  }

  //
  List<Predictions> searchplaces = [];

  Future<List<Predictions>> getSearchPlaces(String placeName) async {
    searchplaces.clear();
    try {
      final response = await GoogleRepository().searchLocation(
        placeName: placeName,
      );
      if (response.data?.status == "OK") {
        searchplaces.addAll(List.from(response.data?.predictions as List));
        return searchplaces;
      }
    } catch (err) {
      debugPrint("--------->${err.toString()}");
    }
    return [];
  }

  Future<void> getLocationByPlaceID(String placeID) async {
    // Prevent infinite loop: don't process if we're updating controller programmatically or already processing this placeID
    if (_isUpdatingSearchController || _currentProcessingPlaceID == placeID) {
      debugPrint("⚠️ Skipping getLocationByPlaceID - already processing or updating controller");
      return;
    }
    
    if (placeID.isEmpty) {
      debugPrint("⚠️ Empty placeID provided");
      return;
    }
    
    _currentProcessingPlaceID = placeID;
    try {
      final response = await GoogleRepository().getLocationByPlaceID(
        placeID: placeID,
      );
      if (response.data?.status == "OK") {
        final location = response.data?.result?.geometry?.location;
        final formattedAddress = response.data?.result?.formattedAddress;
        final placeName = response.data?.result?.name;
        
        // Set searchedPosition FIRST, then call getMembers() so it uses the searched location
        // Note: Backend API expects coordinates in swapped order (lng, lat) for member fetching,
        // but Google Maps expects standard order (lat, lng) for display
        // So we swap them here for the backend API, and will swap back for map display
        searchedPosition = Position(
          latitude: location?.lng ?? 78.9629,  // Swapped: use lng as latitude for backend
          longitude: location?.lat ?? 20.5937, // Swapped: use lat as longitude for backend
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        
        // Store the searched location name/address for display
        searchedLocationName = formattedAddress ?? placeName ?? null;
        
        // Update search controller with the selected location's readable address
        // Build readable address from the place details
        String readableAddress = formattedAddress ?? placeName ?? "";
        if (readableAddress.isNotEmpty) {
          // Remove Plus Code if present
          readableAddress = _removePlusCodeFromAddress(readableAddress);
          
          // Create/update prediction for search controller
          final prediction = Predictions(
            description: readableAddress,
            placeId: placeID,
            structuredFormatting: StructuredFormatting(
              mainText: readableAddress.split(',').first.trim(),
              secondaryText: readableAddress.split(',').skip(1).join(',').trim(),
            ),
          );
          // Set flag to prevent onChanged callback from triggering
          if (!_isDisposed) {
            _isUpdatingSearchController = true;
            try {
              // Try to update the search controller
              // This might fail if widget is disposed, so we catch and ignore that specific error
              searchController.value = prediction;
              debugPrint("✅ Search bar updated with searched location: $readableAddress");
            } catch (e) {
              // Silently ignore setState after dispose errors - they're expected when widget is disposed
              final errorString = e.toString();
              final isDisposeError = errorString.contains('setState') && 
                  (errorString.contains('dispose') || 
                   errorString.contains('defunct') || 
                   errorString.contains('not mounted') ||
                   errorString.contains('lifecycle state'));
              
              if (!isDisposeError) {
                // Only log non-dispose errors
                debugPrint("⚠️ Could not update search controller: $e");
              }
              // Silently continue - don't return here as we need to reset the flag
            } finally {
              _isUpdatingSearchController = false;
            }
          }
        }
        
        // Also get reverse geocoding to store full address model
        // Use original coordinates from Google Places API (not swapped searchedPosition)
        // Google's reverse geocoding API expects standard format: lat, lng
        try {
          final geocodeResponse = await GoogleRepository().placeFromCoordinates(
            lat: location?.lat ?? 20.5937,  // Use original lat from API response
            lng: location?.lng ?? 78.9629,   // Use original lng from API response
          );
          if (geocodeResponse.data?.status == "OK" && geocodeResponse.data?.results != null && geocodeResponse.data!.results!.isNotEmpty) {
            searchedAddress = AddressModel.fromGeocodingModel(geocodeResponse.data!);
            // Update readable address if reverse geocoding provides better result
            final reverseAddress = _buildReadableAddress(geocodeResponse.data!.results!.first);
            if (reverseAddress.isNotEmpty && reverseAddress.length > readableAddress.length) {
              readableAddress = reverseAddress;
              searchedLocationName = reverseAddress;
              // Update search controller with better address
              final prediction = Predictions(
                description: readableAddress,
                placeId: placeID,
                structuredFormatting: StructuredFormatting(
                  mainText: readableAddress.split(',').first.trim(),
                  secondaryText: readableAddress.split(',').skip(1).join(',').trim(),
                ),
              );
              // Set flag to prevent onChanged callback from triggering
              if (!_isDisposed) {
                _isUpdatingSearchController = true;
                try {
                  // Try to update the search controller
                  // This might fail if widget is disposed, so we catch and ignore that specific error
                  searchController.value = prediction;
                } catch (e) {
                  // Silently ignore setState after dispose errors - they're expected when widget is disposed
                  final errorString = e.toString();
                  final isDisposeError = errorString.contains('setState') && 
                      (errorString.contains('dispose') || 
                       errorString.contains('defunct') || 
                       errorString.contains('not mounted') ||
                       errorString.contains('lifecycle state'));
                  
                  if (!isDisposeError) {
                    // Only log non-dispose errors
                    debugPrint("⚠️ Could not update search controller: $e");
                  }
                  // Silently continue - don't return here as we need to reset the flag
                } finally {
                  _isUpdatingSearchController = false;
                }
              }
            }
            debugPrint("✅ Stored searched location address: ${searchedAddress?.formattedAddress ?? searchedLocationName}");
          }
        } catch (e) {
          debugPrint("⚠️ Could not get reverse geocoding for searched location: $e");
        }
        
        debugPrint("📍 Location searched: ${searchedPosition!.latitude}, ${searchedPosition!.longitude}");
        debugPrint("📍 Searched location name: $searchedLocationName");
        notifyListeners(); // Notify to update UI
        // Now call getMembers() which will use the searchedPosition
        getMembers();
      }
    } catch (err) {
      debugPrint("❌ Error in getLocationByPlaceID: $err");
    } finally {
      _currentProcessingPlaceID = null; // Reset after processing
    }
  }

  shiftCameraPositions() async {
    // Prioritize searched position over current position
    Position? position = searchedPosition ?? currentPosition;
    final hasValidPosition = position?.latitude != null && position?.longitude != null;
    
    // If using searched position, coordinates are swapped for backend API, so swap back for map display
    // Google Maps expects standard format: LatLng(latitude, longitude)
    double latitude;
    double longitude;
    
    if (searchedPosition != null && position == searchedPosition) {
      // Searched position has swapped coordinates, swap them back for map
      latitude = position!.longitude;  // Swap back: longitude becomes latitude
      longitude = position.latitude;    // Swap back: latitude becomes longitude
    } else {
      // Current position (GPS) has correct coordinates
      latitude = position?.latitude ?? 20.5937;
      longitude = position?.longitude ?? 78.9629;
    }
    
    cameraPosition = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: hasValidPosition ? 10 : 4,
    );

    try {
      final GoogleMapController cont = await mapController.future;
      await cont.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      debugPrint("📍 Camera moved to: ${position?.latitude}, ${position?.longitude} (zoom: ${hasValidPosition ? 10 : 4})");
    } catch (e) {
      debugPrint("⚠️ Error animating camera: $e");
    }
    notifyListeners();
  }

  Future<void> _addUsersToMap() async {
    markers.clear(); // Clear existing markers first
    debugPrint("🗺️ Starting to add ${membersList.length} markers to map");
    
    for (var user in membersList) {
      try {
        // API returns coordinates in GeoJSON format: [latitude, longitude]
        final coordinates = user.location?.coordinates;
        if (coordinates != null && coordinates.length >= 2) {
          final latitude = coordinates[0]; // First element is latitude
          final longitude = coordinates[1]; // Second element is longitude
          
          // Validate coordinates are within valid range
          if (latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180) {
            debugPrint("📍 Adding marker for ${user.name}: lat=$latitude, lng=$longitude");
            
            // Create custom marker icon with fallback
            BitmapDescriptor markerIcon;
            try {
              final markerIconBytes = await customMarker(user.avatar);
              markerIcon = BitmapDescriptor.bytes(markerIconBytes);
            } catch (e) {
              debugPrint("⚠️ Failed to create custom marker for ${user.name}, using default: $e");
              // Use default marker icon as fallback
              markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
            }
            
            markers.add(
              Marker(
                icon: markerIcon,
                markerId: MarkerId(user.sId ?? user.name ?? "${latitude}_${longitude}"),
                position: LatLng(latitude, longitude),
                draggable: false, // Changed to false as dragging might cause issues
                infoWindow: InfoWindow(
                  title: user.name ?? "Member",
                  snippet: user.address ?? "",
                ),
              ),
            );
            debugPrint("✅ Marker added successfully for ${user.name}");
          } else {
            debugPrint("⚠️ Invalid coordinates for ${user.name}: lat=$latitude, lng=$longitude");
          }
        } else {
          debugPrint("⚠️ Missing coordinates for ${user.name}");
        }
      } catch (e, stackTrace) {
        debugPrint("❌ Error creating marker for ${user.name}: $e");
        debugPrint("Stack trace: $stackTrace");
        // Continue with next user even if one fails
      }
    }
    
    debugPrint("🗺️ Finished adding markers. Total markers: ${markers.length}");
  }

  Future<Uint8List> customMarker(String? url) async {
    const double size = 60.0;
    const double borderWidth = 1.5;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint();

    // Draw white background circle
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    // Draw border circle
    paint.color = AppPalettes.primaryColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = borderWidth;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      (size / 2) - (borderWidth / 2),
      paint,
    );

    // Load and draw the profile image
    try {
      final Uint8List? imageBytes = await _loadNetworkImage(url);
      if (imageBytes != null) {
        final ui.Codec codec = await ui.instantiateImageCodec(
          imageBytes,
          targetWidth: (size - (borderWidth * 2)).toInt(),
          targetHeight: (size - (borderWidth * 2)).toInt(),
        );
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        final ui.Image image = frameInfo.image;

        // Draw the image in a circle (clipped)
        final Path clipPath = Path()
          ..addOval(
            Rect.fromCircle(
              center: Offset(size / 2, size / 2),
              radius: (size / 2) - borderWidth,
            ),
          );

        canvas.save();
        canvas.clipPath(clipPath);
        canvas.drawImage(image, Offset(borderWidth, borderWidth), Paint());
        canvas.restore();
      }
    } catch (e) {
      // If image loading fails, just show the circle with border
      print('Failed to load marker image: $e');
    }

    // Convert to byte data
    try {
      final ui.Image img = await pictureRecorder.endRecording().toImage(
        size.toInt(),
        size.toInt(),
      );
      final ByteData? byteData = await img.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        return byteData.buffer.asUint8List();
      } else {
        throw Exception("Failed to convert image to byte data");
      }
    } catch (e) {
      debugPrint("❌ Error in customMarker conversion: $e");
      // Return a simple default marker as last resort
      // This should not happen, but if it does, the fallback in _addUsersToMap will handle it
      rethrow;
    }
  }

  Future<Uint8List?> _loadNetworkImage(String? path) async {
    try {
      if (path == null || path.isEmpty) {
        throw Exception("Empty path");
      }

      final completer = Completer<ImageInfo>();
      final img = NetworkImage(path);

      img
          .resolve(const ImageConfiguration())
          .addListener(
            ImageStreamListener((info, _) => completer.complete(info)),
          );

      final imageInfo = await completer.future;
      final byteData = await imageInfo.image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (err) {
      // Load default image
      try {
        final completer = Completer<ImageInfo>();
        final img = NetworkImage(
          'https://images.bitmoji.com/3d/avatar/201714142-99447061956_1-s5-v1.webp',
        );

        img
            .resolve(const ImageConfiguration())
            .addListener(
              ImageStreamListener((info, _) => completer.complete(info)),
            );

        final imageInfo = await completer.future;
        final byteData = await imageInfo.image.toByteData(
          format: ui.ImageByteFormat.png,
        );

        return byteData?.buffer.asUint8List();
      } catch (e) {
        return null;
      }
    }
  }
}
