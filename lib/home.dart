import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  late File _image;
  late List _output;
  final picker = ImagePicker();

  selectPhotoFromGallery() async {
    var pickedFile = await picker.pickImage(source: ImageSource.gallery);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
    });
    dectectImage(_image);
  }

  capturePhotoFromcamere() async {
    var pickedFile = await picker.pickImage(source: ImageSource.camera);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
    });
    dectectImage(_image);
  }

  loadDataModelFiles() async {
    String? output = await Tflite.loadModel(
        model: 'assets/model_unquant.tflite',
        labels: 'assets/labels.txt',
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false);
    print(output);
  }

  @override
  void initState() {
    super.initState();

    loadDataModelFiles();
  }

  dectectImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 1,
      threshold: 0.6,
    );
    setState(() {
      _output = output!;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            const Center(
              child: Text("hayvan algılama uygulaması"),
            ),
            const SizedBox(height: 10),
            Center(
              child: _loading
                  ? SizedBox(
                      width: 350,
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            "assets/unicorn.svg",
                            height: 200,
                          )
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: Image.file(_image),
                        ),
                        const SizedBox(height: 20),
                        _output != null
                            ? Text("${_output[0]['label']}")
                            : const Text("Biz Tanıyamadık")
                      ],
                    ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => capturePhotoFromcamere(),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 250,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: const Text("Kamera"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => selectPhotoFromGallery(),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 250,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: const Text("Galeriden Seç"),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
