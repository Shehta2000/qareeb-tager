
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkInfo {
  final Connectivity connectivity;
  NetworkInfo(this.connectivity);

  Future<bool> get isConnected async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  static void checkConnectivity(BuildContext context) {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(Get.find<SplashController>().firstTimeConnectionCheck) {
        Get.find<SplashController>().setFirstTimeConnectionCheck(false);
      }else {
        bool isNotConnected = result == ConnectivityResult.none;
        isNotConnected ? const SizedBox() : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? 'no_connection' : 'connected',
            textAlign: TextAlign.center,
          ),
        ));
      }
    });
  }

  static Future<Uint8List?> compressImage(XFile file) async {
  final rawBytes = await file.readAsBytes();
  final sizeInMB = rawBytes.lengthInBytes / 1048576;

  int quality;
  if (sizeInMB < 2) {
    quality = 90;
  } else if (sizeInMB < 5) {
    quality = 50;
  } else if (sizeInMB < 10) {
    quality = 10;
  } else {
    quality = 1;
  }

  // جرب WebP أولاً
  Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
    file.path,
    quality: quality,
    format: CompressFormat.webp,
  );

  // لو فشل، جرب PNG كخطة بديلة
  compressedBytes ??= await FlutterImageCompress.compressWithFile(
      file.path,
      quality: quality,
      format: CompressFormat.png,
    );

  if (kDebugMode) {
    print('Input size : $sizeInMB');
    print('Output size : ${compressedBytes != null ? compressedBytes.lengthInBytes / 1048576 : 0}');
  }

  return compressedBytes;
}

}
