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
import 'package:inldsevak/features/auth/models/response/geocoding_search_modal.dart';
import 'package:inldsevak/features/common_fields/model/address_model.dart';
import 'package:inldsevak/features/common_fields/model/geocoding_model.dart';
import 'package:inldsevak/features/common_fields/services/search_repository.dart';
import 'package:inldsevak/features/nearest_member/model/my_location_request_model.dart';
import 'package:inldsevak/features/nearest_member/model/nearest_members_model.dart';
import 'package:inldsevak/features/nearest_member/services/nearest_member_repository.dart';
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

  List<PartyMember> membersList = [];
  Set<Marker> markers = {};

  final SingleSelectController<Predictions?> searchController =
      SingleSelectController(null);

  Future<void> getMembers() async {
    if (currentPosition == null) {
      RouteManager.pop();
      CommonSnackbar(
        text: "Location Permission requried !",
      ).showAnimatedDialog(type: QuickAlertType.error);
      return;
    }
    markers = {};
    isLoading = true;
    try {
      final model = MyCurrentLocationRequestModel(
        longitude:
            searchedPosition?.longitude ??
            currentPosition?.longitude ??
            78.9629,
        latitude:
            searchedPosition?.latitude ?? currentPosition?.latitude ?? 20.5937,

        page: 1,
        pageSize: 10,
      );
      final response = await NearestMemberRepository().getNearestMember(
        token,
        model: model,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data?.partyMember;
        membersList = List<PartyMember>.from(data as List);
        notifyListeners();
        await _addUsersToMap();
      }
      shiftCameraPositions();
    } catch (err, stackTrace) {
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
    }
  }

  final Completer<GoogleMapController> mapController = Completer();
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(20.5937, 78.9629),
  );

  getCurrentLocation() async {
    currentPosition = await Geolocator.getCurrentPosition();
    Position? position = currentPosition;
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
        getMembers();
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
