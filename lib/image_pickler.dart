// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:convert' show base64, base64Decode, base64Encode, json, utf8;
import 'dart:async';
import 'package:flutter/services.dart';
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
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as p;
import 'package:wc_flutter_share/wc_flutter_share.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Make your photo cartoon',
      home: MyHomePage(
          title: 'Funk'
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

final List<String> imgList = [
  'images/cartoon_samples/sample_1.jpg',
  'images/cartoon_samples/sample_2.jpg',
  'images/cartoon_samples/sample_3.jpg',
  'images/cartoon_samples/sample_4.jpg',
  'images/cartoon_samples/sample_5.jpg',
  'images/cartoon_samples/sample_6.jpg',
  'images/cartoon_samples/sample_7.jpg',
  'images/cartoon_samples/sample_8.jpg',
  'images/cartoon_samples/sample_9.jpg',
  'images/cartoon_samples/sample_10.jpg'
];


class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  String _imageFilePath;
  dynamic _pickImageError;
  String _retrieveDataError;
  int _current = 0;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    try {
      PickedFile pickedFile = await _picker.getImage(
        source: source,
        maxWidth: null,
        maxHeight: null,
        imageQuality: 20,
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

  Future<String> postRequest(filepath, url) async {

    final bytesImg = File(filepath).readAsBytesSync();
    String base64Encode = base64.encode(bytesImg);
    var body = json.encode({
      'image': base64Encode,
    });
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Simple simx6EUjtNIjwjhMtYn8iau01Cw1'
      },
      body: body,
    );

    var bytes = base64Decode(json.decode(response.body)['result']['image']);
    String dir = (await getApplicationDocumentsDirectory()).path;
    var uuid = Uuid();
    var uuidImgName = uuid.v1();
    String fullPath = '$dir/$uuidImgName.png';
    File file = File(fullPath);
    await file.writeAsBytes(bytes);

    return file.path;
  }

  void _onMakeAnimeButtonPressed(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      String imagePath = await postRequest(_imageFilePath, 'https://api.algorithmia.com/v1/algo/ayatafoy/cartoon_magic/0.1.17?timeout=10');
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

  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFilePath != null) {
        return Container(
          margin:EdgeInsets.all(8.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: InkWell(
              onTap: () => print("ciao"),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                child: Image.file(
                    File(_imageFilePath),
                    height: (MediaQuery.of(context).size.height) / 1.45,
                    fit:BoxFit.cover
                ),
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
      return Container(
        margin:EdgeInsets.all(8.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: InkWell(
            onTap: () => {
              print(MediaQuery.of(context).size.height / 1.57)
            },
            child: CarouselSlider(
              items: imgList.map((item) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: ClipRRect(
                      child: Image.asset(
                          item,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover
                      ),
                    ),
                  ),
                ],
              )).toList(),
              options: CarouselOptions(
                  autoPlay: true,
                  viewportFraction: 1,
                  // enlargeCenterPage: true,
                  pauseAutoPlayOnManualNavigate: true,
                  // aspectRatio: 0.65,
                  aspectRatio: 0.89,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }
              ),
            ),
          ),
        ),
      );
    }
  }

  _toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }

  void _saveImage(String path) async {
    try {
      final ByteData bytes= File(path).readAsBytesSync().buffer.asByteData();
      final result = await ImageGallerySaver.saveImage(bytes.buffer.asUint8List());
      _toastInfo("$result");
    } catch (e) {
      print('error: $e');
    }
  }

  void _shareImage(String path) async {
    try {
      String extension = p.extension(path);
      String fileName = p.basename(path);
      String mimeType = 'image/png';
      if (extension == '.jpg'){
        mimeType = 'image/jpg';
      }
      final ByteData bytes= File(path).readAsBytesSync().buffer.asByteData();

      await WcFlutterShare.share(
          sharePopupTitle: 'share',
          fileName: fileName,
          mimeType: mimeType,
          bytesOfFile: bytes.buffer.asUint8List());
    } catch (e) {
      print('error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Text(widget.title, style: TextStyle(
              color: Colors.white,
              fontFamily: 'Courgette',
              fontSize: 33
          )),
        ),
        actions: <Widget>[
          FlatButton(

            child: Icon(Icons.save_alt, color: Colors.white),
            onPressed: () async {
              _saveImage(_imageFilePath);
            },
          ),
          FlatButton(
            child: Icon(Icons.share, color: Colors.white),
            onPressed: () async {
              _shareImage(_imageFilePath);
            },
          ),
        ],
      ),
      backgroundColor: CupertinoColors.black,
      body: Column(
        children: [
          isLoading ? SizedBox(
            height: (MediaQuery.of(context).size.height / 1.388),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(10,10,25,10),
                child: RaisedButton.icon(
                    onPressed: () {
                      _onImageButtonPressed(ImageSource.gallery, context: context);
                    },
                    icon: Icon(Icons.photo_library, color: Colors.white, size: 30),
                    label: Text('', style: TextStyle(color: Colors.white)),
                    color: Colors.black
                ),
              ),
              // SizedBox(width: MediaQuery.of(context).size.width / 10),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Material(
                      elevation: 1.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      color: Colors.transparent,
                      child: Ink.image(
                        image: AssetImage('images/anime_2.png'),
                        fit: BoxFit.cover,
                        width:  MediaQuery.of(context).size.width / 5,
                        height:  MediaQuery.of(context).size.width / 5,
                        child: InkWell(
                          onTap: () {
                            _onMakeAnimeButtonPressed(context);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5,0,0),
                      child: Text('Cartoon', style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Courgette',
                          fontSize: 15
                      )),
                    ),
                  ],
                ),
              ),
              // SizedBox(width:  MediaQuery.of(context).size.width / 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(25,10,10,10),
                child: RaisedButton.icon(
                    onPressed: () {
                      _onImageButtonPressed(ImageSource.camera, context: context);
                    },
                    icon: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                    label: Text('', style: TextStyle(color: Colors.white)),
                    color: Colors.black
                ),
              )
            ],
          ),
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