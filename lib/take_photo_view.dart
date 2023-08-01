import 'dart:ui';
import 'package:camera_demo/debug_camera.dart';
import 'package:camera_demo/post_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timer_count_down/timer_count_down.dart';
import '../camera.dart';

class TakePhotoView extends StatefulWidget {
  final Map<String, String> locationDetails;

  TakePhotoView({required this.locationDetails});

  @override
  _TakePhotoViewState createState() => _TakePhotoViewState();
}

class _TakePhotoViewState extends State<TakePhotoView>
    with WidgetsBindingObserver {
  late CameraManager _cameraManager;
  bool _isTimerRunning = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _cameraManager = CameraManager();
    _cameraManager.errorNotifier.addListener(() {
      if (_cameraManager.errorNotifier.hasError) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Error'),
                  content: Text(_cameraManager.errorNotifier.errorMessage ??
                      'Could not retrieve error'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cameraManager.requestCameraPermission().then((permissionStatus) {
      if (permissionStatus.isGranted || permissionStatus.isLimited) {
        _cameraManager.initializeCamera().then((_) {
          if (mounted) {
            setState(() {});
          }
        });
      } else {
        String errorMessage;
        switch (permissionStatus) {
          case PermissionStatus.denied:
            errorMessage = "Camera permission was denied";
            break;
          case PermissionStatus.restricted:
            errorMessage = "Camera permission is restricted";
            break;
          case PermissionStatus.permanentlyDenied:
            errorMessage = "Camera permission is permanently denied";
            break;
          default:
            errorMessage = "Unknown camera permission status";
        }
        _cameraManager.errorNotifier.setError(errorMessage);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _cameraManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _cameraManager.requestCameraPermission().then((permissionStatus) {
        if (permissionStatus.isGranted || permissionStatus.isLimited) {
          _cameraManager.initializeCamera().then((_) {
            if (mounted) {
              setState(() {});
            }
          });
        } else {
          String errorMessage;
          switch (permissionStatus) {
            case PermissionStatus.denied:
              errorMessage = "Camera permission was denied";
              break;
            case PermissionStatus.restricted:
              errorMessage = "Camera permission is restricted";
              break;
            case PermissionStatus.permanentlyDenied:
              errorMessage = "Camera permission is permanently denied";
              break;
            default:
              errorMessage = "Unknown camera permission status";
          }
          _cameraManager.errorNotifier.setError(errorMessage);
        }
      });
    }
  }

  void onSwitchCamera() async {
    await _cameraManager.switchCamera();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;
      if (screenWidth == 0 || screenHeight == 0) {
        throw Exception("Screen width or height can't be zero.");
      }
      final topBottomBoxHeight = ((screenHeight - screenWidth) / 2);
      if (topBottomBoxHeight == 0) {
        throw Exception("Top and bottom box height can't be zero.");
      }

      return Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: FutureBuilder<void>(
                future: _cameraManager.initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('An error occurred: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    final cameraValue = _cameraManager.cameraController.value;
                    final size = MediaQuery.of(context).size;
                    final deviceRatio = size.width / size.height;
                    if (cameraValue.aspectRatio == null) {
                      throw Exception("Camera aspect ratio is null.");
                    }
                    double height = (cameraValue.aspectRatio! > deviceRatio)
                        ? size.width * cameraValue.aspectRatio!
                        : size.height;
                    if (height == 0) {
                      throw Exception("Height can't be zero.");
                    }

                    try {
                      return Center(
                        child: AspectRatio(
                          aspectRatio: deviceRatio,
                          child: OverflowBox(
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: (cameraValue.aspectRatio! > deviceRatio)
                                  ? BoxFit.fitWidth
                                  : BoxFit.fitHeight,
                              child: Container(
                                width: size.width,
                                height: height,
                                child: CameraPreview(
                                    _cameraManager.cameraController),
                              ),
                            ),
                          ),
                        ),
                      );
                    } catch (e) {
                      return Center(
                          child: Text("An error occurred: ${e.toString()}"));
                    }
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Positioned(
              top: 0,
              height: topBottomBoxHeight,
              width: screenWidth,
              child: Container(color: Colors.black.withOpacity(1)),
            ),
            Positioned(
              bottom: 0,
              height: topBottomBoxHeight,
              width: screenWidth,
              child: Container(color: Colors.black.withOpacity(1)),
            ),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DebugCameraView(),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: screenWidth * 0.1,
              right: screenWidth * 0.1,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    buildSwitchCameraButton(context),
                    buildTimerButton(context),
                    buildTakePhotoButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return Scaffold(
        body: Center(
          child: Text("An error occurred: ${e.toString()}"),
        ),
      );
    }
  }

  Widget buildSwitchCameraButton(BuildContext context) {
    return Opacity(
      opacity: _isProcessing ? 0.5 : 1,
      child: CupertinoButton(
        onPressed: _isProcessing ? null : onSwitchCamera,
        child: Container(
          width: 80,
          height: 50,
          decoration: BoxDecoration(
            color: _isProcessing ? Color(0xFFFFFFFF) : Color(0xFF161E44),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Icon(Icons.switch_camera, color: Colors.white),
        ),
      ),
    );
  }

  Widget buildTimerButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 50,
          width: 70,
          color: Colors.grey.shade200.withOpacity(0.5),
          child: Center(
            child: _isTimerRunning // if the timer is running
                ? Countdown(
                    seconds: 180,
                    build: (_, double time) => Text(
                      time.floor().toString(),
                      style: TextStyle(fontSize: 18),
                    ),
                    interval: Duration(milliseconds: 100),
                    onFinished: () {},
                  )
                : CircularProgressIndicator(
                    color: Color(0xFF161E44),
                  ),
          ),
        ),
      ),
    );
  }

  Widget buildTakePhotoButton(BuildContext context) {
    return Opacity(
      opacity: _isProcessing ? 0.5 : 1,
      child: CupertinoButton(
        onPressed: _isProcessing
            ? null
            : () async {
                setState(() {
                  _isTimerRunning = false; // Stop the timer
                  _isProcessing = true; // Start the loading indicator
                });

                final imageFilee =
                    await takePhoto(context, _cameraManager.cameraController);

                // Check if the widget is still in the tree before calling setState
                if (mounted) {
                  setState(() {
                    _isProcessing = false; // Stop the loading indicator
                  });
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostView(
                      xFile: imageFilee,
                    ),
                  ),
                );
              },
        child: Container(
          width: 80,
          height: 50,
          decoration: BoxDecoration(
            color: _isProcessing ? Color(0xFF161E44) : Color(0xFF161E44),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Icon(Icons.photo_camera, color: Colors.white),
        ),
      ),
    );
  }

  Future<XFile> takePhoto(
      BuildContext context, CameraController cameraController) async {
    try {
      if (!cameraController.value.isInitialized) {
        _cameraManager.errorNotifier.setError('Controller is not initialized');
        return Future.error('Controller is not initialized');
      }
      final image = await cameraController.takePicture();
      return image;
    } catch (e) {
      _cameraManager.errorNotifier.setError(e.toString());
      return Future.error(e);
    }
  }
}
