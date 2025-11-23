import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';

mixin HandleMultipleFilesSheet {
  Widget selectMultipleFiles({required Function(Future<dynamic>) onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.camera),
          title: TranslatedText(text: 'Take a Picture'),
          onTap: () => onTap(createImage()),
        ),
        ListTile(
          leading: Icon(Icons.photo_library),
          title: TranslatedText(text: 'Choose from Gallery'),
          onTap: () => onTap(pickMultipleImages()),
        ),
        ListTile(
          leading: Icon(Icons.file_open),
          title: TranslatedText(text: 'Choose from Files'),
          onTap: () => onTap(pickFiles()),
        ),
      ],
    );
  }
}
