// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:convert' show base64Decode, json, utf8;
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Make your photo cartoon',
      home: MyHomePage(title: 'Cartoon photo app'),
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
  bool isLoading = false;
  String _imageFilePath;
  dynamic _pickImageError;
  String _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    try {
      PickedFile pickedFile = await _picker.getImage(
        source: source,
        maxWidth: null,
        maxHeight: null,
        imageQuality: 100,
      );
      setState(() {
        _imageFilePath = pickedFile.path;
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }


  Future<String> uploadImage(filepath, url) async {

    var request = http.MultipartRequest(
        "POST", Uri.parse(url));
    var multipartFile = await http.MultipartFile.fromPath("image", filepath);
    request.files.add(multipartFile);
    http.StreamedResponse response = await request.send();
    var responseByteArray = await response.stream.toBytes();
    var jsonResponse =  json.decode(utf8.decode(responseByteArray));

    var bytes = base64Decode(jsonResponse['image']);
    String dir = (await getApplicationDocumentsDirectory()).path;

    var uuid = Uuid();

    var uuidImgName = uuid.v1();

    String fullPath = '$dir/$uuidImgName.png';
    File file = File(fullPath);
    await file.writeAsBytes(bytes);
    print(file.path);

    await ImageGallerySaver.saveImage(bytes);

    return file.path;
  }

  void _onMakeAnimeButtonPressed(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      String imagePath = await uploadImage(_imageFilePath, 'http://192.168.0.100:8080/cartoonize');
      setState(() {
        _imageFilePath = imagePath;
      });
      isLoading = false;
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Widget _previewButtons({BuildContext context}){
    return Row(
      children: [
        SizedBox(
          height: 100,
          width:140,
          child: RaisedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add_a_photo, color: Colors.white),
              label: Text('Save', style: TextStyle(color: Colors.white)),
              color: Colors.blue
          ),
        ),
        SizedBox(width: 500),
        SizedBox(
          height: 100,
          width:140,
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

  Future<Widget> _getImageSize(imgPath) async {
    File image = new File(_imageFilePath); // Or any other way to get a File instance.
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    print(decodedImage.width);
    print(decodedImage.height);
    print(decodedImage.height / decodedImage.width);
    var screen_width = (MediaQuery.of(context).size.width);
    var screen_height = (MediaQuery.of(context).size.height - 245);
    print(screen_height / screen_width);
  }


  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFilePath != null) {
        _getImageSize(_imageFilePath);
        return Container(
          margin:EdgeInsets.all(8.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: InkWell(
              onTap: () => print("ciao"),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,  // add this
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    child: Image.file(
                        File(_imageFilePath),
                        // height: (MediaQuery.of(context).size.height) - 245,
                        height: (MediaQuery.of(context).size.height) - 245,
                        fit:BoxFit.fill

                    ),
                  ),
                  // SizedBox(height: 150),
                ],
              ),
            ),
          ),
        );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: FittedBox(
            fit: BoxFit.contain, // otherwise the logo will be tiny
            child: Center(
              child: const Text(
                'You have not yet picked an image.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
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
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: Icon(Icons.wb_cloudy_rounded, color: Colors.white), onPressed: () {}),
        ],
      ),
      backgroundColor: CupertinoColors.inactiveGray,
      body: Column(
        children: [
          isLoading ? SizedBox(
            height: (MediaQuery.of(context).size.height - 221),
            child: SpinKitFadingCircle(
              color: Colors.deepPurpleAccent,
              size: 100.0,
            ),
          ) : _previewImage(),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                child: RaisedButton.icon(
                    onPressed: () {
                      _onImageButtonPressed(ImageSource.gallery, context: context);
                    },
                    icon: Icon(Icons.photo_library, color: Colors.white),
                    label: Text('Gallery', style: TextStyle(color: Colors.white)),
                    color: Colors.blue
                ),
              ),
              SizedBox(width: (MediaQuery.of(context).size.width) - 235),
              SizedBox(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Column(
              children: [
                SizedBox(
                  child: RaisedButton.icon(
                      onPressed: () {
                        _onMakeAnimeButtonPressed(context);
                      },
                      icon: Icon(Icons.auto_awesome, color: Colors.black),
                      label: Text('Make anime', style: TextStyle(color: Colors.black)),
                      color: Colors.amber
                  ),
                ),
              ],
            ),
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
}

typedef void OnPickImageCallback(double maxWidth, double maxHeight, int quality);