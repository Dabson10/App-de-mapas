import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CamaraController {
  CameraController? _controller;
  List<CameraDescription>? _camaras;

  Future<void> initCamara() async {
    _camaras = await availableCameras();
    _controller = CameraController(
      _camaras!.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
  }

  // Void para tomar la foto
  Future<void> tomarFoto() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        await initCamara();
      }

      // Ruta temporal para guardar la foto
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Tomar la foto
      final XFile picture = await _controller!.takePicture();
      await picture.saveTo(path);

      print("Foto guardada en: $path");
    } catch (e) {
      print("Error al tomar la foto: $e");
    }
  }

  void dispose() {
    _controller?.dispose();
  }
}
