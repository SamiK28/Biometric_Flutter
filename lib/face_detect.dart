import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:mlkit/mlkit.dart';

class FaceDetector extends StatefulWidget {
  final File file;
  final List<VisionFace> labels;
  FaceDetector({@required this.file, @required this.labels});
  @override
  _FaceDetectorState createState() => _FaceDetectorState();
}

class _FaceDetectorState extends State<FaceDetector> {
  File cropImage() {
    int x, y, w, h;
    Rect rect = widget.labels[0].rect;

    x = rect.right.toInt();
    y = rect.bottom.toInt();
    w = x-rect.left.toInt() ;
    h = y- rect.top.toInt() ;

    img.Image src = img.decodeImage(widget.file.readAsBytesSync());
    img.Image image = img.copyCrop(src, x, y, w, h);

    String fname =
        "${widget.file.parent.path}/biometric_${DateTime.now().millisecondsSinceEpoch}.png";
    File(fname)..writeAsBytesSync(img.encodePng(image));
    File file = File(fname);
    return file;
  }

  Future<Size> _getImageSize(Image image) {
    Completer<Size> completer = new Completer<Size>();
    image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener(
        (ImageInfo info, bool _) => completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble()))));
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Size>(
        future: _getImageSize(Image.file(widget.file, fit: BoxFit.fitWidth)),
        builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: ListView(
                children: [
                  // Container(
                  //     child: Image.file(
                  //   cropImage(),
                  // )),
                  Container(
                      foregroundDecoration:
                          FaceDetectDecoration(widget.labels, snapshot.data),
                      child: Image.file(
                        widget.file,
                      )),
                ],
              ),
            );
          } else {
            return Center(child: Text('Detecting...'));
          }
        },
      ),
    );
  }
}

class FaceDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List<VisionFace> _faces;
  FaceDetectDecoration(List<VisionFace> texts, Size originalImageSize)
      : _faces = texts,
        _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return new _FaceDetectPainter(_faces, _originalImageSize);
  }
}

class _FaceDetectPainter extends BoxPainter {
  final List<VisionFace> _faces;
  final Size _originalImageSize;
  _FaceDetectPainter(texts, originalImageSize)
      : _faces = texts,
        _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;
    print("original Image Size : $_originalImageSize");

    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;

    for (var text in _faces) {
      print("rect : ${text.rect}");

      final _rect = Rect.fromLTRB(
          offset.dx + text.rect.left / _widthRatio,
          offset.dy + text.rect.top / _heightRatio,
          offset.dx + text.rect.right / _widthRatio,
          offset.dy + text.rect.bottom / _heightRatio);
      //final _rect = Rect.fromLTRB(24.0, 115.0, 75.0, 131.2);
      print("_rect : $_rect");
      canvas.drawRect(_rect, paint);
      canvas.clipRect(_rect);
    }

    print("offset : $offset");
    print("configuration : $configuration");

    final rect = offset & configuration.size;

    print("rect container : $rect");

    //canvas.drawRect(rect, paint);
    canvas.restore();
  }
}
