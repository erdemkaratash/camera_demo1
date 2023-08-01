import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'error_notifier.dart';

class CameraManager with ChangeNotifier {
  late CameraController cameraController;
  ErrorNotifier errorNotifier = ErrorNotifier();
  Future<void>? initializeControllerFuture;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;
  bool isControllerDisposed = false;

  Future<bool> initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras[selectedCameraIndex],
          ResolutionPreset.high,
        );
        initializeControllerFuture =
            _initializeCameraController(cameras[selectedCameraIndex]);
        return true;
      } else {
        errorNotifier.setError("No camera available");
        return false;
      }
    } on CameraException catch (e) {
      errorNotifier.setError('Failed to initialize camera: ${e.description}');
      return false;
    } catch (e) {
      errorNotifier.setError('An unexpected error occurred: $e');
      return false;
    }
  }

  Future<bool> _initializeCameraController(
      CameraDescription cameraDescription) async {
    if (cameraController.value.isInitialized) {
      await cameraController.dispose();
    }

    cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
    );

    isControllerDisposed = false;

    cameraController.addListener(() {
      if (cameraController.value.hasError) {
        errorNotifier.setError(
            'Camera Error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      return true; // Returns true if initialization is successful
    } on CameraException catch (e) {
      errorNotifier.setError('Failed to initialize camera: ${e.description}');
      return false; // Returns false if any exception occurs
    } catch (e) {
      errorNotifier.setError('An unexpected error occurred: $e');
      return false;
    }
  }

  Future<void> switchCamera() async {
    if (cameras.isEmpty || isControllerDisposed) {
      return;
    }
    isControllerDisposed = true;
    selectedCameraIndex = (selectedCameraIndex + 1) % cameras.length;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    await _initializeCameraController(selectedCamera);
  }

  Future<void> startCamera() async {
    if (!cameraController.value.isInitialized) {
      return;
    }
    try {
      await cameraController.startImageStream((CameraImage availableImage) {});
    } on CameraException catch (e) {
      errorNotifier.setError('Failed to start camera: ${e.description}');
    }
  }

  Future<void> stopCamera() async {
    if (!cameraController.value.isInitialized ||
        !cameraController.value.isStreamingImages) {
      return;
    }
    try {
      await cameraController.stopImageStream();
    } on CameraException catch (e) {
      errorNotifier.setError('Failed to stop camera: ${e.description}');
    }
  }

  Future<bool> requestCameraPermission() async {
    try {
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        var result = await Permission.camera.request();
        return result.isGranted;
      }
      return true;
    } on PlatformException catch (e) {
      errorNotifier
          .setError('Failed to request camera permission: ${e.message}');
      return false;
    } catch (e) {
      errorNotifier.setError(
          'An unexpected error occurred while requesting camera permission: $e');
      return false;
    }
  }
}
