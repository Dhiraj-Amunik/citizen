import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';

mixin HandleMultipleFilesSheet {
  Widget selectMultipleFiles({required Function(Future<dynamic>) onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.camera),
          title: Text('Take a Picture'),
          onTap: () => onTap(createImage()),
        ),
        ListTile(
          leading: Icon(Icons.photo_library),
          title: Text('Choose from Gallery'),
          onTap: () => onTap(pickMultipleImages()),
        ),
        ListTile(
          leading: Icon(Icons.file_open),
          title: Text('Choose from Files'),
          onTap: () => onTap(pickFiles()),
        ),
      ],
    );
  }
}
