import 'package:flutter/material.dart';
import 'take_photo_view.dart';

class DebugCameraView extends StatefulWidget {
  DebugCameraView({Key? key}) : super(key: key);

  @override
  _DebugCameraViewState createState() => _DebugCameraViewState();
}

class _DebugCameraViewState extends State<DebugCameraView> {
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _nameController;
  late TextEditingController _placeIdController;

  @override
  void initState() {
    super.initState();
    _latController = TextEditingController(text: '41.4322816');
    _lngController = TextEditingController(text: '36.1626459');
    _nameController = TextEditingController(text: 'Flora Sitesi');
    _placeIdController = TextEditingController(text: 'DEBUGMODE');
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _nameController.dispose();
    _placeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Camera View'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(controller: _latController),
            TextField(controller: _lngController),
            TextField(controller: _nameController),
            TextField(
              controller: _placeIdController,
              readOnly: true,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TakePhotoView(
                      locationDetails: {
                        'lat': _latController.text,
                        'lng': _lngController.text,
                        'name': _nameController.text,
                        'place_id': _placeIdController.text,
                      },
                    ),
                  ),
                );
              },
              child: Text('Continue to Camera'),
            ),
            Spacer(),
            Text(
              'This screen was made to debug the take photo view without Google Maps API requests.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
