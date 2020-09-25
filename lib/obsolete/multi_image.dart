import 'package:flutter/material.dart';
import 'dart:async';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  get galleryItems => null;

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';

  @override
  void initState() {
    super.initState();
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: AssetImage('images/lake.jpg'),
              initialScale: PhotoViewComputedScale.contained * 0.8,
              // heroAttributes: HeroAttributes(tag: galleryItems[index].id),
            );
          },
          itemCount: 1,
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes,
              ),
            ),
          ),
          // backgroundDecoration: widget.backgroundDecoration,
          // pageController: widget.pageController,
          // onPageChanged: onPageChanged,
        )
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return new MaterialApp(
  //     home: new Scaffold(
  //       appBar: new AppBar(
  //         title: const Text('Plugin example app'),
  //       ),
  //       body: Column(
  //         children: <Widget>[
  //           Center(child: Text('Error: $_error')),
  //           RaisedButton(
  //             child: Text("Pick images"),
  //             onPressed: loadAssets,
  //           ),
  //           Expanded(
  //             child: buildGridView(),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
}