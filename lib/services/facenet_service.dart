import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as img;

class FaceNetService {
  late tfl.Interpreter _interpreter;

  FaceNetService() {
    loadModel();
  }

  Future<void> loadModel() async {
    _interpreter = await tfl.Interpreter.fromAsset('assets/facenet.tflite');
    print("✅ FaceNet model loaded successfully!");
  }

  Future<List<double>> extractFaceEmbedding(File faceImage) async {
    // Decode image
    img.Image? image = img.decodeImage(await faceImage.readAsBytes());
    if (image == null) return [];

    // Resize image to 160x160
    img.Image resizedImage = img.copyResize(image, width: 160, height: 160);

    // Convert image to Float32List
    Float32List input = preprocessImage(resizedImage);

    // ✅ Ensure input shape is `[1, 160, 160, 3]`
    var reshapedInput = input.reshape([1, 160, 160, 3]);

    // Output array (FaceNet outputs 128 values)
    List<List<double>> output = List.generate(1, (_) => List.filled(512, 0));

    print(
        "✅ Model Expected Input Shape: ${_interpreter.getInputTensor(0).shape}");
    print(
        "✅ Model Expected Input Type: ${_interpreter.getInputTensor(0).type}");
    print("🔍 Input Shape Before Running: ${reshapedInput.length}");

    // Run inference
    _interpreter.run(reshapedInput, output);

    print("✅ Face Embedding: ${output.first}");
    return output.first;
  }

  List<List<List<List<double>>>> imageToFloatArray(img.Image image) {
    List<List<List<List<double>>>> result = List.generate(
      1, // Batch size = 1
      (_) => List.generate(
        160, // Height = 160
        (y) => List.generate(
          160, // Width = 160
          (x) {
            img.Pixel pixel = image.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0
            ]; // 3 channels (RGB)
          },
        ),
      ),
    );
    return result;
  }

  Float32List preprocessImage(img.Image image) {
    // Resize to 160x160
    img.Image resized = img.copyResize(image, width: 160, height: 160);

    // Convert image to a Float32List (1, 160, 160, 3)
    List<double> imageData = [];

    for (int y = 0; y < 160; y++) {
      for (int x = 0; x < 160; x++) {
        img.Pixel pixel = resized.getPixel(x, y);
        imageData.add(pixel.r / 255.0); // Red
        imageData.add(pixel.g / 255.0); // Green
        imageData.add(pixel.b / 255.0); // Blue
      }
    }

    return Float32List.fromList(imageData);
  }

  Future<List<double>> runFaceNetModel(Float32List input) async {
    var output = List.filled(512, 0).reshape([1, 512]); // FaceNet output shape

    print("🚀 Running FaceNet Model...");

    try {
      _interpreter.run(input.reshape([1, 160, 160, 3]), output);
      print("✅ Face embedding generated successfully!");
      return output.first;
    } catch (e) {
      print("❌ Error running FaceNet model: $e");
      return [];
    }
  }

  static double compareFaces(List<double> face1, List<double> face2) {
    double sum = 0.0;
    for (int i = 0; i < face1.length; i++) {
      sum += pow((face1[i] - face2[i]), 2);
    }
    return sqrt(sum); // Euclidean distance
  }

  static bool isFaceMatch(List<double> detectedFace, List<double> storedFace, {double threshold = 1.0}) {
    double distance = compareFaces(detectedFace, storedFace);
    print("Face distance: $distance");
    return distance < threshold; // Match if below threshold
  }
}
