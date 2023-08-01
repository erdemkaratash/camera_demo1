import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PostView extends StatelessWidget {
  final XFile xFile;

  PostView({required this.xFile});

  @override
  Widget build(BuildContext context) {
    File imageFile = File(xFile.path);
    return Scaffold(
      appBar: AppBar(
        title: Text('Post View'),
      ),
      body: Center(
        child: Container(
          child: Image.file(
            imageFile,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
