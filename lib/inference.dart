import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' hide Image;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;
import 'package:tflite/tflite.dart';
import 'constants.dart';

class AppBrain {
//Para cargar el modelo
  Future loadModel() async {
    Tflite.close(); //Detenemos el buffer del modelo
    try {
      await Tflite.loadModel(
        model: "assets/converted_mnist_model.tflite",
        labels: "assets/labels.txt",
      );
    } on PlatformException {
      print('Error cargando el modelo');
    }
  }

//Procesar los puntos dibujados
  Future<List> processCanvasPoints(List<Offset> points) async {//Offset Clase para dibujos 2D
// We create an empty canvas 280x280 pixels
    final canvasSizeWithPadding = kCanvasSize + (2 * kCanvasInnerOffset);
    final canvasOffset = Offset(kCanvasInnerOffset, kCanvasInnerOffset);
    final recorder = PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(
        Offset(0.0, 0.0),
        Offset(canvasSizeWithPadding, canvasSizeWithPadding),
      ),
    );

//La imagen debe tener fondo negro y la parte dibujada en color blanco, de forma opuesta a como es ahora
    canvas.drawRect(
        Rect.fromLTWH(0, 0, canvasSizeWithPadding, canvasSizeWithPadding),
        kBackgroundPaint);

// Se dibujan los puntos en color blanco
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i] + canvasOffset, points[i + 1] + canvasOffset,
            kWhitePaint);
      }
    }


    final picture = recorder.endRecording();
    final img = await picture.toImage(
      canvasSizeWithPadding.toInt(),
      canvasSizeWithPadding.toInt(),
    );
    final imgBytes = await img.toByteData(format: ImageByteFormat.png);
    Uint8List pngUint8List = imgBytes.buffer.asUint8List();

//La imagen se convierte para poder ser redimensionada desde el paquete 'im' package:image/image.dart
    im.Image imImage = im.decodeImage(pngUint8List);
    im.Image resizedImage = im.copyResize(
      imImage,
      width: kModelInputSize,
      height: kModelInputSize,
    );

// Se retorna la imagen redimensionada
    return predictImage(resizedImage);
  }
}

//Para predecir la imagen
Future <List>predictImage(im.Image image) async {
  return await Tflite.runModelOnBinary(
    binary: imageToByteListFloat32(image, kModelInputSize),
  );
}

//La imagen esta en color
Uint8List imageToByteListFloat32(im.Image image, int inputSize) {
  var convertedBytes = Float32List(inputSize * inputSize);
  var buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;
  for (var i = 0; i < inputSize; i++) {
    for (var j = 0; j < inputSize; j++) {
      var pixel = image.getPixel(j, i);
      buffer[pixelIndex++] =
          (im.getRed(pixel) + im.getGreen(pixel) + im.getBlue(pixel)) /
              3 /
              255.0;
    }
  }
  return convertedBytes.buffer.asUint8List();
}

//Convertir niveles de gris
//Las imágenes en la red neuronal se representan a 8 bits 256 niveles de gris 0-255
double convertPixel(int color) {
  return (255 -
      (((color >> 16) & 0xFF) * 0.299 +
          ((color >> 8) & 0xFF) * 0.587 +
          (color & 0xFF) * 0.114)) /
      255.0;
}