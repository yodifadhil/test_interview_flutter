import 'package:flutter/material.dart';
import 'package:test_interview_8/input.dart';
import 'api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: const FormPage(),
  ));
}

class FormPage extends StatefulWidget {
  const FormPage({Key? key}) : super(key: key);

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  int currentStep = 0;
  List<dynamic> listProvinsi = [];
  List<dynamic> listKota = [
    {"id": "", 'name': "Pilih Kota"}
  ];
  List<dynamic> listKecamatan = [
    {"id": "", 'name': "Pilih Kecamatan"}
  ];
  List<dynamic> listKelurahan = [
    {"id": "", 'name': "Pilih Kelurahan"}
  ];

  dynamic provinsi = "";
  dynamic kota = "";
  dynamic kecamatan = "";
  dynamic kelurahan = "";

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController biodataController = TextEditingController();

  File? _image1;
  File? _image2;
  File? _image3;

  Map<String, dynamic> json = {};

  Future<void> _pickImage(int id) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        if (id == 1)
          _image1 = File(image.path);
        else if (id == 2)
          _image2 = File(image.path);
        else if (id == 3) _image3 = File(image.path);
      });
    }
  }

  String getContentType(File? image) {
    if (image != null) {
      if (image.path.toLowerCase().endsWith('.jpg') ||
          image.path.toLowerCase().endsWith('.jpeg')) {
        return 'image/jpeg';
      } else if (image.path.toLowerCase().endsWith('.png')) {
        return 'image/png';
      } else {
        return 'application/octet-stream';
      }
    }
    return '';
  }

  bool checkStep() {
    if (currentStep == 0) {
      if (firstNameController.text.isEmpty ||
          lastNameController.text.isEmpty ||
          biodataController.text.isEmpty ||
          provinsi.isEmpty == 0 ||
          kota.isEmpty == 0 ||
          kecamatan.isEmpty ||
          kelurahan.isEmpty) {
        return false;
      }
    } else if (currentStep == 1) {
      if (_image1 == null || _image2 == null || _image3 == null) {
        return false;
      }
    }

    return true;
  }

  void _showImagePreview(File image, BuildContext context, id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Creating a controller for PhotoView to control zoom
        final controller = PhotoViewController();

        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              Expanded(
                child: PhotoView(
                  imageProvider: FileImage(image),
                  controller: controller,
                  backgroundDecoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.zoom_in),
                    onPressed: () {
                      controller?.scale = (controller?.scale ?? 1) +
                          0.05; // Increase scale by 0.5 if controller is not null
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.zoom_out),
                    onPressed: () {
                      controller?.scale = (controller?.scale ?? 1) -
                          0.05; // Decrease scale by 0.5 if controller is not null
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        if (id == 1) {
                          _image1 = null;
                        } else if (id == 2) {
                          _image2 = null;
                        } else if (id == 3) {
                          _image3 = null;
                        }

                        Navigator.of(context).pop();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    getInit();
    super.initState();
  }

  getInit() async {
    List<dynamic> data = await ApiService().fetchProvinsi();

    data.add({"id": "", 'name': "Pilih Provinsi"});

    setState(() {
      listProvinsi = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Color(0xffe6e7e8),
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: currentStep,
            onStepCancel: () => currentStep == 0
                ? null
                : setState(() {
                    currentStep -= 1;
                  }),
            onStepContinue: () {
              bool isLastStep = (currentStep == getSteps().length - 1);

              if (currentStep == 1) {
                List<int>? image1 = _image1?.readAsBytesSync();
                List<int>? image2 = _image2?.readAsBytesSync();
                List<int>? image3 = _image3?.readAsBytesSync();

                setState(() {
                  json = {
                    'noKTP': "01679765443368",
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'biodata': biodataController.text,
                    'provinsi': provinsi,
                    'kota': kota,
                    'kecamatan': kecamatan,
                    'kelurahan': kelurahan,
                    'imageSelfie': _image1 != null
                        ? {
                            'filename': _image1?.path.split("/").last,
                            'contentType': getContentType(_image1),
                            // 'base64': base64Encode(image1 ?? [])
                          }
                        : {},
                    'imageKTP': _image2 != null
                        ? {
                            'filename': _image2?.path.split("/").last,
                            'contentType': getContentType(_image2),
                            // 'base64': base64Encode(image2 ?? [])
                          }
                        : {},
                    'imageFree': _image3 != null
                        ? {
                            'filename': _image3?.path.split("/").last,
                            'contentType': getContentType(_image3),
                            // 'base64': base64Encode(image3 ?? [])
                          }
                        : {}
                  };

                });
              } 
              
              if(!isLastStep) {
                setState(() {
                  currentStep += 1;
                });
              }
            },
            onStepTapped: (step) => setState(() {
              currentStep = step;
            }),
            steps: getSteps(),
            controlsBuilder: (context, details) {
              return Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    currentStep < 2
                        ? ElevatedButton(
                            onPressed:
                                checkStep() ? details.onStepContinue : null,
                            child: const Text(
                              'NEXT',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : SizedBox(),
                    currentStep > 0
                        ? TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text(
                              'BACK',
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                        : SizedBox()
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Step> getSteps() {
    return <Step>[
      Step(
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 0,
        title: const Text("Basic Info"),
        content: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  CustomInput(
                    hint: "First Name",
                    inputBorder: OutlineInputBorder(),
                    controller: firstNameController,
                  ),
                  const SizedBox(height: 10),
                  CustomInput(
                    hint: "Last Name",
                    inputBorder: OutlineInputBorder(),
                    controller: lastNameController,
                  ),
                  const SizedBox(height: 10),
                  CustomInput(
                    hint: "Biodata",
                    maxLine: 8,
                    inputBorder: OutlineInputBorder(),
                    controller: biodataController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // PROVINSI
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Provinsi"),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        width: double.infinity,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                              iconEnabledColor: Color(0xff2a78be),
                              value: provinsi,
                              onChanged: (dynamic newValue) async {
                                if (newValue.length > 0) {
                                  List<dynamic> data =
                                      await ApiService().fetchKota(newValue);

                                  data.add({"id": "", 'name': "Pilih Kota"});

                                  setState(() {
                                    listKota = data;
                                    listKecamatan = [
                                      {"id": "", 'name': "Pilih Kecamatan"}
                                    ];
                                    listKelurahan = [
                                      {"id": "", 'name': "Pilih Kelurahan"}
                                    ];
                                    provinsi = newValue!;
                                    kota = "";
                                    kecamatan = "";
                                    kelurahan = "";
                                  });
                                }
                              },
                              items: listProvinsi
                                  .map((item) => DropdownMenuItem(
                                      value: item["id"],
                                      child: Text(item["name"],
                                          style:
                                              TextStyle(color: Colors.black))))
                                  .toList()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // KOTA
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Kabupaten / Kota"),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        width: double.infinity,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                              iconEnabledColor: Color(0xff2a78be),
                              value: kota,
                              onChanged: listKota.length == 1 &&
                                      listKota[0]["id"] == ""
                                  ? null
                                  : (dynamic newValue) async {
                                      if (newValue.length > 0) {
                                        List<dynamic> data = await ApiService()
                                            .fetchKecamatan(newValue);

                                        data.add({
                                          "id": "",
                                          'name': "Pilih Kecamatan"
                                        });

                                        setState(() {
                                          kota = newValue!;
                                          listKecamatan = data;
                                          listKelurahan = [
                                            {
                                              "id": "",
                                              'name': "Pilih Kelurahan"
                                            }
                                          ];
                                          kecamatan = "";
                                          kelurahan = "";
                                        });
                                      }
                                    },
                              items: listKota
                                  .map((item) => DropdownMenuItem(
                                      value: item["id"],
                                      child: Text(item["name"],
                                          style:
                                              TextStyle(color: Colors.black))))
                                  .toList()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // KECAMATAN
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Kecamatan"),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        width: double.infinity,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                              iconEnabledColor: Color(0xff2a78be),
                              value: kecamatan,
                              onChanged: listKecamatan.length == 1 &&
                                      listKecamatan[0]["id"] == ""
                                  ? null
                                  : (dynamic newValue) async {
                                      if (newValue.length > 0) {
                                        List<dynamic> data = await ApiService()
                                            .fetchKelurahan(newValue);

                                        data.add({
                                          "id": "",
                                          'name': "Pilih Kelurahan"
                                        });

                                        setState(() {
                                          kecamatan = newValue!;
                                          listKelurahan = data;
                                          kelurahan = "";
                                        });
                                      }
                                    },
                              items: listKecamatan
                                  .map((item) => DropdownMenuItem(
                                      value: item["id"],
                                      child: Text(item["name"],
                                          style:
                                              TextStyle(color: Colors.black))))
                                  .toList()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // KELURAHAN
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Kelurahan"),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        width: double.infinity,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                              iconEnabledColor: Color(0xff2a78be),
                              value: kelurahan,
                              onChanged: listKelurahan.length == 1 &&
                                      listKelurahan[0]["id"] == ""
                                  ? null
                                  : (dynamic newValue) async {
                                      if (newValue.length > 0) {
                                        setState(() {
                                          kelurahan = newValue!;
                                        });
                                      }
                                    },
                              items: listKelurahan
                                  .map((item) => DropdownMenuItem(
                                      value: item["id"],
                                      child: Text(item["name"],
                                          style:
                                              TextStyle(color: Colors.black))))
                                  .toList()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: const Text("Upload File"),
        content: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Selfie Photo"),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: _image1 == null ? 100 : 200,
                    width: double.infinity,
                    child: _image1 != null
                        ? GestureDetector(
                            onTap: () {
                              _showImagePreview(_image1!, context, 1);
                            },
                            child: FittedBox(
                              child: Image.file(_image1!),
                              fit: BoxFit.fill,
                            ))
                        : DottedBorder(
                            color: Colors.grey,
                            strokeWidth: 1,
                            child: GestureDetector(
                              onTap: () {
                                _pickImage(1);
                              },
                              child: Align(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.blue,
                                      size: 36.0,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Upload Selfie Photo",
                                      style: TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("KTP Photo"),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: _image2 == null ? 100 : 200,
                    width: double.infinity,
                    child: _image2 != null
                        ? GestureDetector(
                            onTap: () {
                              _showImagePreview(_image2!, context, 2);
                            },
                            child: FittedBox(
                              child: Image.file(_image2!),
                              fit: BoxFit.fill,
                            ),
                          )
                        : DottedBorder(
                            color: Colors.grey,
                            strokeWidth: 1,
                            child: GestureDetector(
                              onTap: () {
                                _pickImage(2);
                              },
                              child: Align(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.blue,
                                      size: 36.0,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Upload KTP Photo",
                                      style: TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Free Photo"),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: _image3 == null ? 100 : 200,
                    width: double.infinity,
                    child: _image3 != null
                        ? GestureDetector(
                            onTap: () {
                              _showImagePreview(_image3!, context, 3);
                            },
                            child: FittedBox(
                              child: Image.file(_image3!),
                              fit: BoxFit.fill,
                            ),
                          )
                        : DottedBorder(
                            color: Colors.grey,
                            strokeWidth: 1,
                            child: GestureDetector(
                              onTap: () {
                                _pickImage(3);
                              },
                              child: Align(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.blue,
                                      size: 36.0,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Upload Free Photo",
                                      style: TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      Step(
        state: currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 2,
        title: const Text("Review"),
        content: Column(
          children: [Text(JsonEncoder.withIndent('  ').convert(json))],
        ),
      ),
    ];
  }
}
