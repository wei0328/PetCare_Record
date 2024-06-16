import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ImageEditor extends StatefulWidget {
  final Uint8List image;
  final Function(Uint8List) onCropped;

  ImageEditor({required this.image, required this.onCropped});

  @override
  _ImageEditorState createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor> {
  final double _radius = 80.0;
  late Rect cropRect;
  late double imageSize;
  late Offset imageOffset;
  late double scaleFactor;
  late double initialDistance;
  late Offset initialFocalPoint;

  @override
  void initState() {
    super.initState();
    imageSize = _radius * 2;
    cropRect = Rect.fromCenter(
        center: Offset(_radius, _radius), width: imageSize, height: imageSize);
    imageOffset = Offset.zero;
    scaleFactor = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              cropImage().then((croppedImage) {
                if (croppedImage != null) {
                  widget.onCropped(croppedImage);
                  Navigator.pop(context);
                }
              });
            },
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onScaleStart: (details) {
            initialDistance = 0.0;
            initialFocalPoint = details.localFocalPoint;
          },
          onScaleUpdate: (details) {
            if (details.scale != 1.0) {
              if (initialDistance == 0.0) {
                initialDistance = details.scale;
              }
              scaleFactor = details.scale / initialDistance;
            }
            if (scaleFactor != 1.0) {
              setState(() {
                imageSize *= scaleFactor;
                cropRect = Rect.fromCenter(
                    center: cropRect.center,
                    width: imageSize,
                    height: imageSize);
              });
            }
          },
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Center(
                child: Transform.translate(
                  offset: imageOffset,
                  child: Transform.scale(
                    scale: scaleFactor,
                    child: ClipOval(
                      child: Image.memory(
                        widget.image,
                        width: _radius * 2,
                        height: _radius * 2,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              CustomPaint(
                painter: CropPainter(cropRect: cropRect, radius: _radius),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List?> cropImage() async {
    try {
      final imageBytes = widget.image;
      final imageWidth = imageBytes.lengthInBytes;
      final imageHeight = imageBytes.lengthInBytes;

      final double xRatio = imageWidth / _radius / 2;
      final double yRatio = imageHeight / _radius / 2;

      final double x = (cropRect.left - _radius) * xRatio;
      final double y = (cropRect.top - _radius) * yRatio;
      final double width = cropRect.width * xRatio;
      final double height = cropRect.height * yRatio;

      final croppedImage = await cropImageFromOriginal(
        imageBytes,
        x.toInt(),
        y.toInt(),
        width.toInt(),
        height.toInt(),
      );

      return croppedImage;
    } catch (e) {
      print("Error cropping image: $e");
      return null;
    }
  }

  Future<Uint8List?> cropImageFromOriginal(
      Uint8List imageBytes, int x, int y, int width, int height) async {
    final completer = Completer<Uint8List?>();
    final codec = await ui.instantiateImageCodec(imageBytes,
        targetWidth: width, targetHeight: height);
    final frameInfo = await codec.getNextFrame();
    final image = frameInfo.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer;
    final croppedBytes = buffer.asUint8List();
    completer.complete(croppedBytes);
    return completer.future;
  }
}

class CropPainter extends CustomPainter {
  final Rect cropRect;
  final double radius;

  CropPainter({required this.cropRect, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addOval(Rect.fromCircle(center: cropRect.center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
