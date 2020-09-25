// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'dart:io';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Make your photo cartoon',
      home: MyHomePage(title: 'Cartoon magic'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PickedFile _imageFile;
  dynamic _pickImageError;
  String _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    try {
      final pickedFile = await _picker.getImage(
        source: source,
        maxWidth: null,
        maxHeight: null,
        imageQuality: 100,
      );
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Widget _previewButtons(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width:120,
          child: RaisedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add_a_photo, color: Colors.white),
              label: Text('Save', style: TextStyle(color: Colors.white)),
              color: Colors.blue
          ),
        ),
        SizedBox(width: 80),
        SizedBox(
          width:120,
          child: RaisedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.backup, color: Colors.white),
              label: Text('Share', style: TextStyle(color: Colors.white)),
              color: Colors.blue
          ),
        ),
      ],
    );
  }


  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      if (kIsWeb) {
        return Column(
          children: [
            Image.network(_imageFile.path),
            _previewButtons()
          ],
        );
      } else {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child:
                ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(File(_imageFile.path), height: 450)
                ),
            ),
            Divider(),
            _previewButtons(),
            Divider()
          ],
        );
      }
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return Center(
        child: SizedBox(
          height: 550,
          child: Center(
            child: const Text(
              'You have not yet picked an image.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: Icon(Icons.wb_cloudy_rounded), onPressed: () {}),
        ],
      ),
      backgroundColor: CupertinoColors.inactiveGray,
      body: Column(
        children: [
          _previewImage(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width:120,
                child: RaisedButton.icon(
                    onPressed: () {
                      _onImageButtonPressed(ImageSource.gallery, context: context);
                    },
                    icon: Icon(Icons.photo_library, color: Colors.white),
                    label: Text('Gallery', style: TextStyle(color: Colors.white)),
                    color: Colors.blue
                ),
              ),
              SizedBox(width: 80),
              SizedBox(
                width: 120,
                child: RaisedButton.icon(
                    onPressed: () {
                      _onImageButtonPressed(ImageSource.camera, context: context);
                    },
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    label: Text('Camera', style: TextStyle(color: Colors.white)),
                    color: Colors.blue
                ),
              )
            ],
          ),
          Divider(),
          Column(
            children: [
              RaisedButton.icon(
                  onPressed: () {
                    _onImageButtonPressed(ImageSource.camera, context: context);
                  },
                  icon: Icon(Icons.auto_awesome, color: Colors.black),
                  label: Text('Make magic', style: TextStyle(color: Colors.black)),
                  color: Colors.amber
              ),
            ],
          )
        ],
      ),
    );
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> retrieveLostData() async {

    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file;
      });
    } else {
      _retrieveDataError = response.exception.code;
    }
  }
}

typedef void OnPickImageCallback(double maxWidth, double maxHeight, int quality);