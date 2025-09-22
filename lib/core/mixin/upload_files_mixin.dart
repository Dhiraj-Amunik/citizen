import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/auth/services/upload_files_repository.dart';

mixin UploadFilesMixin {
  Future<String> uploadImage(
    String path, {
    String? filename,
    String? name,
    required String token,
  }) async {
    try {
      final FormData data = FormData.fromMap({
        'file': await MultipartFile.fromFile(path, filename: filename),
      });

      final response = await UploadFilesRepository().uploadImage(
        data: data,
        token: token,
      );
      if (response.data?.responseCode == 200) {
        CommonSnackbar(
          text: "${name?.capitalize() ?? "Image"} updated successfully",
        ).showSnackbar();
        return response.data?.imagePath1 ?? "";
      } else {
        CommonSnackbar(text: "Something went wrong.").showSnackbar();
      }
    } catch (err, stackTrace) {
      CommonSnackbar(text: "Something went wrong.").showSnackbar();

      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
    return "";
  }

  Future<String> uploadMultipleImage(List<File> files) async {
    try {
      List<MultipartFile> multipartFiles = [];

      for (File imagePath in files) {
        MultipartFile file = await MultipartFile.fromFile(imagePath.path);
        multipartFiles.add(file);
      }
      final FormData data = FormData.fromMap({'files': multipartFiles});

      final response = await UploadFilesRepository().uploadMultipleImage(
        data: data,
      );
      if (response.data?.responseCode == 200) {
        CommonSnackbar(text: "Images updated successfully").showSnackbar();
        return response.data?.imagePath1 ?? "";
      } else {
        CommonSnackbar(text: "Something went wrong.").showSnackbar();
      }
    } catch (err, stackTrace) {
      CommonSnackbar(text: "Something went wrong.").showSnackbar();

      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    }
    return "";
  }
}
