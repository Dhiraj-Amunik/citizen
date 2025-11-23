import 'dart:async';
import 'dart:typed_data';

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
  @override
  Future<void> onInit() {
    sequenceTasks();
    return super.onInit();
  }

  void sequenceTasks() async {
    searchplaces.clear();
    isLoading = true;
    await checkPermission();
    getMembers();
  }

  Position? currentPosition;
  Position? searchedPosition;

  AddressModel? currentAddress;
  
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

  final SingleSelectController<Predictions?> searchController =
      SingleSelectController(null);

  // Distance filter - slider value (0-100 km)
  double _radiusValue = 50.0; // Default to 50 km
  double get radiusValue => _radiusValue;
  
  setRadius(double value) {
    _radiusValue = value;
    notifyListeners();
  }

  clearDistance() {
    _radiusValue = 50.0; // Reset to default
    notifyListeners();
  }

  // Clear searched position to go back to using live GPS location
  clearSearchedLocation() {
    searchedPosition = null;
    notifyListeners();
    getMembers(); // Refresh with live location
  }

  Future<void> getMembers() async {
    markers = {};
    isLoading = true;
    try {
      // Get location coordinates (prioritize searched location over live GPS)
      double? latitude;
      double? longitude;
      
      // Priority 1: Use searched position if user explicitly searched for a location
      if (searchedPosition != null) {
        latitude = searchedPosition!.latitude;
        longitude = searchedPosition!.longitude;
        debugPrint("📍 Using searched position: $latitude, $longitude");
      } else if (currentPosition != null) {
        // Priority 2: Use live GPS location if available (and no search performed)
        latitude = currentPosition!.latitude;
        longitude = currentPosition!.longitude;
        debugPrint("📍 Using live GPS location: $latitude, $longitude");
        
        // Update user-dashboard API with live coordinates (optional, for server sync)
        try {
          final dashboardRequestModel = DashboardRequestModel(
            latitude: currentPosition!.latitude,
            longitude: currentPosition!.longitude,
          );
          
          debugPrint("📤 Updating user-dashboard with live coordinates: ${currentPosition!.latitude}, ${currentPosition!.longitude}");
          
          // Call user-dashboard API to update server (fire and forget, don't wait for response)
          DashboardRepository().fetchUserDashboard(
            token: token,
            model: dashboardRequestModel,
          ).then((dashboardResponse) {
            if (dashboardResponse.data?.responseCode == 200) {
              debugPrint("✅ User-dashboard updated successfully with live coordinates");
            }
          }).catchError((e) {
            debugPrint("⚠️ Error updating user-dashboard (non-critical): $e");
          });
        } catch (e) {
          debugPrint("Error calling user-dashboard API: $e");
        }
      } else {
        // Priority 3: Try to get coordinates from dashboard API
        try {
          final token = await SessionController.instance.getToken();
          
          // Try GET dashboard API to get stored coordinates
          final dashboardResponse = await DashboardRepository().fetchDashboard(token: token);
          
          if (dashboardResponse.data?.responseCode == 200) {
            final userData = dashboardResponse.data?.data?.user ?? 
                           dashboardResponse.data?.data?.userDetails;
            final userLocation = userData?.location;
            
            if (userLocation?.coordinates != null && userLocation!.coordinates!.length >= 2) {
              // Dashboard returns coordinates as [latitude, longitude]
              latitude = userLocation.coordinates![0];
              longitude = userLocation.coordinates![1];
              debugPrint("📍 Using coordinates from dashboard GET API: $latitude, $longitude");
            }
          }
        } catch (e) {
          debugPrint("Error fetching dashboard coordinates: $e");
        }
        
        // Priority 4: Request location permission if we still don't have coordinates
        if (latitude == null || longitude == null) {
          await checkPermission();
          if (currentPosition != null) {
            latitude = currentPosition!.latitude;
            longitude = currentPosition!.longitude;
            debugPrint("📍 Got location after permission check: $latitude, $longitude");
          } else {
            // Final fallback to default coordinates
            RouteManager.pop();
            CommonSnackbar(
              text: "Location Permission required!",
            ).showAnimatedDialog(type: QuickAlertType.error);
            return;
          }
        }
      }
      
      // Convert radius value to integer for API (round to nearest integer)
      int? radiusInKm = _radiusValue.round();
      
      // Create request model with coordinates in format [latitude, longitude]
      final model = MyCurrentLocationRequestModel(
        latitude: latitude,
        longitude: longitude,
        page: 1,
        pageSize: 10,
        radius: radiusInKm,
      );
      
      debugPrint("📤 Sending request with coordinates: [$latitude, $longitude], radius: $radiusInKm");
      
      final response = await NearestMemberRepository().getNearestMember(
        token,
        model: model,
      );

      if (response.error != null) {
        debugPrint("API Error: ${response.error}");
        membersList = [];
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
          notifyListeners();
          
          // Add markers to map (wrapped in try-catch to prevent marker errors from affecting list display)
          try {
            await _addUsersToMap();
          } catch (e, stackTrace) {
            debugPrint("Error adding markers to map: $e");
            debugPrint("Stack trace: $stackTrace");
            // Don't clear membersList if marker creation fails
          }
        } else {
          membersList = [];
          debugPrint("✗ No party members in response or list is empty");
          if (data == null) {
            debugPrint("✗ partyMember is null");
          } else if (data.isEmpty) {
            debugPrint("✗ partyMember list is empty");
          }
          notifyListeners();
        }
      } else {
        debugPrint("✗ Response code is not 200: ${response.data?.responseCode}");
        debugPrint("Response message: ${response.data?.message}");
        membersList = [];
        notifyListeners();
      }
      shiftCameraPositions();
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  final Completer<GoogleMapController> mapController = Completer();
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(20.5937, 78.9629),
  );

  getCurrentLocation() async {
    currentPosition = await Geolocator.getCurrentPosition();
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
  }

  checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      currentPosition = await Geolocator.getCurrentPosition();
      // Log coordinates when permission is granted
      if (currentPosition != null) {
        debugPrint("📍 Current Location: ${currentPosition!.latitude.toStringAsFixed(6)}, ${currentPosition!.longitude.toStringAsFixed(6)}");
      }
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        currentPosition = await Geolocator.getCurrentPosition();
      }
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
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      currentPosition = await Geolocator.getCurrentPosition();
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
    try {
      final response = await GoogleRepository().getLocationByPlaceID(
        placeID: placeID,
      );
      if (response.data?.status == "OK") {
        // Set searchedPosition FIRST, then call getMembers() so it uses the searched location
        searchedPosition = Position(
          longitude: response.data?.result?.geometry?.location?.lng ?? 78.9629,
          latitude: response.data?.result?.geometry?.location?.lat ?? 20.5937,
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        debugPrint("📍 Location searched: ${searchedPosition!.latitude}, ${searchedPosition!.longitude}");
        // Now call getMembers() which will use the searchedPosition
        getMembers();
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  shiftCameraPositions() async {
    Position? position = currentPosition;
    cameraPosition = CameraPosition(
      target: LatLng(
        searchedPosition?.latitude ?? position?.latitude ?? 20.5937,
        searchedPosition?.longitude ?? position?.longitude ?? 78.9629,
      ),
      zoom: position?.latitude != null && position?.longitude != null ? 10 : 4,
    );

    final GoogleMapController cont = await mapController.future;
    cont.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    notifyListeners();
  }

  Future<void> _addUsersToMap() async {
    for (var user in membersList) {
      markers.add(
        Marker(
          icon: BitmapDescriptor.bytes(await customMarker(user.avatar)),
          markerId: MarkerId(user.name ?? ""),
          position: LatLng(
            user.location?.coordinates?.last ?? 0,
            user.location?.coordinates?.first ?? 0,
          ),
          draggable: true,
          infoWindow: InfoWindow(title: user.name),
        ),
      );
    }
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
    final ui.Image img = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final ByteData? byteData = await img.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return byteData!.buffer.asUint8List();
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
