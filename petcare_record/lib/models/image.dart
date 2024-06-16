// image.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImage(ImageSource source) async {
  try {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);

    if (file != null) {
      return await file.readAsBytes();
    } else {
      print("No Image Selected");
      return null;
    }
  } catch (e) {
    print("Error picking image: $e");
    return null;
  }
}

class ImageEditor extends StatefulWidget {
  final Uint8List image;
  final Function(Uint8List) onCropped;

  ImageEditor({required this.image, required this.onCropped});

  @override
  _ImageEditorState createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  // 编辑器状态和方法
}
