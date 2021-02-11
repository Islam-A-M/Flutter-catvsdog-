import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  File _image;
  List _output;
  final picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _output = output;
      _loading = false;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  pickImage() async {
    try {
      var image = await picker.getImage(source: ImageSource.camera);
      assert(image != null);
      setState(() {
        _image = File(image.path);
      });
      classifyImage(_image);
    } catch (e) {
      print('errrrr');
      print(e);
      return null;
    }
  }

  pickGalleryImage() async {
    try {
      var image = await picker.getImage(source: ImageSource.gallery);
      assert(image != null);
      setState(() {
        _image = File(image.path);
      });
      classifyImage(_image);
    } catch (e) {
      print('errrrr');
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFF101010),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 85,
            ),
            Text(
              'TeachableMachine.com CNN',
              style: TextStyle(
                color: Color(0xFFEEDA28),
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              'Detect Dogs and cats',
              style: TextStyle(
                  color: Color(0xFFE99600),
                  fontWeight: FontWeight.w500,
                  fontSize: 28),
            ),
            SizedBox(
              height: 40,
            ),
            Center(
              child: _loading
                  ? loadingWidget()
                  : contentWidget(image: _image, output: _output),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: _deviceWidth,
              child: Column(
                children: [
                  actionButtonWidget(
                    _deviceWidth,
                    'Take a photo',
                    pickImage,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  actionButtonWidget(
                      _deviceWidth, 'Camera Roll', pickGalleryImage),
                ],
              ),
            )
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 24),
      ),
    );
  }
}

Widget contentWidget({File image, List output}) {
  return Container(
    child: Column(
      children: [
        Container(
          height: 250,
          child: Image.file(image),
        ),
        SizedBox(
          height: 20,
        ),
        output != null
            ? Text(
                '${output[0]['label']}'
                    .trim()
                    .replaceFirst(new RegExp(r'0|1'), ''),
                style: TextStyle(color: Colors.white, fontSize: 20),
              )
            : Container()
      ],
    ),
  );
}

Widget loadingWidget() {
  return Container(
    width: 280,
    child: Column(
      children: [
        Image.asset('assets/cat.png'),
        SizedBox(
          height: 50,
        )
      ],
    ),
  );
}

Widget actionButtonWidget(num _deviceWidth, String title, Function function) {
  return GestureDetector(
    onTap: function,
    child: Container(
      width: _deviceWidth - 150,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 17),
      decoration: BoxDecoration(
        color: Color(0xFFE99600),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
    ),
  );
}
