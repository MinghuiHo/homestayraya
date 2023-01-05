import 'dart:convert';
import 'dart:io';
import 'package:homestayraya/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../config.dart';

class NewProdScreen extends StatefulWidget {
  final User user;
  final Position position;
  final List<Placemark> placemarks;
  const NewProdScreen(
      {super.key,
      required this.user,
      required this.position,
      required this.placemarks});

  @override
  State<NewProdScreen> createState() => _NewProdScreenState();
}

class _NewProdScreenState extends State<NewProdScreen> {
  final TextEditingController _houseNameEdC = TextEditingController();
  final TextEditingController _houseDescEdC = TextEditingController();
  final TextEditingController _housePriceEdC = TextEditingController();
  final TextEditingController _houseSlotEdC = TextEditingController();
  final TextEditingController _houseStateEdC = TextEditingController();
  final TextEditingController _houseLocalEdC = TextEditingController();
  final TextEditingController _houseDelvEdC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var lat, lon;

  @override
  void initState() {
    super.initState();
    //checkLocation();
    lat = widget.position.latitude.toString();
    lon = widget.position.longitude.toString();
    // getAdd();
    _houseStateEdC.text = widget.placemarks[0].administrativeArea.toString();
    _houseLocalEdC.text = widget.placemarks[0].locality.toString();
  }

  File? img;
  var pathAsset = "asset/img/snap.png";
  bool _isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("New Product/Service")),
        body: SingleChildScrollView(
          child: Column(children: [
            GestureDetector(
              onTap: selectImgDialog,
              child: Card(
                elevation: 8,
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: img == null
                        ? AssetImage(pathAsset)
                        : FileImage(img!) as ImageProvider,
                    fit: BoxFit.cover,
                  )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Add New Product",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _houseNameEdC,
                      validator: (val) =>
                          val!.isEmpty ? "House name cannot be empty!" : null,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Type of House',
                          labelStyle: TextStyle(),
                          icon: Icon(Icons.person),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _houseDescEdC,
                      validator: (val) => val!.isEmpty || (val.length < 10)
                          ? "Room description must be longer than 10!"
                          : null,
                      maxLines: 4,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Room Description',
                          alignLabelWithHint: true,
                          labelStyle: TextStyle(),
                          icon: Icon(
                            Icons.person,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  Row(
                    children: [
                      Flexible(
                        flex: 5,
                        child: TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: _housePriceEdC,
                            validator: (val) => val!.isEmpty
                                ? "House price must contain value!"
                                : null,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'House Price',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.money),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                ))),
                      ),
                      Flexible(
                        flex: 5,
                        child: TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: _houseSlotEdC,
                            validator: (val) => val!.isEmpty
                                ? "Slot should be more than 0!"
                                : null,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'House Slot',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.ad_units),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                ))),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                          flex: 5,
                          child: TextFormField(
                              textInputAction: TextInputAction.next,
                              validator: (val) =>
                                  val!.isEmpty ? "Current House State" : null,
                              enabled: false,
                              controller: _houseStateEdC,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                  labelText: 'Current House States',
                                  labelStyle: TextStyle(),
                                  icon: Icon(Icons.flag),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0),
                                  )))),
                      Flexible(
                        flex: 5,
                        child: TextFormField(
                            textInputAction: TextInputAction.next,
                            enabled: false,
                            validator: (val) =>
                                val!.isEmpty ? "Current Locality" : null,
                            controller: _houseLocalEdC,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                labelText: 'Current Locality',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.map),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                ))),
                      )
                    ],
                  ),
                  Row(children: [
                    Flexible(
                      flex: 5,
                      child: TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: _houseDelvEdC,
                          validator: (val) =>
                              val!.isEmpty ? "Must be more than zero" : null,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Service Charge for the Homestay',
                              labelStyle: TextStyle(),
                              icon: Icon(Icons.delivery_dining),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 2.0),
                              ))),
                    ),
                    Flexible(
                        flex: 5,
                        child: CheckboxListTile(
                          title: const Text("Confirmation"), //    <-- label
                          value: _isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked = value!;
                            });
                          },
                        )),
                  ]),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      child: const Text('Add Room'),
                      onPressed: () => {
                        _newRoomDialog(),
                      },
                    ),
                  ),
                ]),
              ),
            )
          ]),
        ));
  }

  _newRoomDialog() {
    if (img == null) {
      Fluttertoast.showToast(
          msg: "Please take picture of your room",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please complete the form first",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
      return;
    }
    if (!_isChecked) {
      Fluttertoast.showToast(
          msg: "Please tick the agreement box!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Insert this room?",
            style: TextStyle(),
          ),
          content: const Text("Are you confirm?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                insertProduct();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void selectImgDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text(
              "Select picture from:",
              style: TextStyle(),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    iconSize: 64,
                    onPressed: onCam,
                    icon: const Icon(Icons.camera)),
                IconButton(
                    iconSize: 64,
                    onPressed: onGall,
                    icon: const Icon(Icons.browse_gallery)),
              ],
            ));
      },
    );
  }

  Future<void> onCam() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 850,
      maxWidth: 850,
    );
    if (pickedFile != null) {
      img = File(pickedFile.path);
      cropImage();
      setState(() {});
    } else {
      print('No image selected.');
    }
  }

  Future<void> onGall() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 850,
      maxWidth: 850,
    );
    if (pickedFile != null) {
      img = File(pickedFile.path);
      cropImage();
    } else {
      print('No image selected.');
    }
  }

  Future<void> cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: img!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        // CropAspectRatioPreset.ratio3x2,
        // CropAspectRatioPreset.original,
        // CropAspectRatioPreset.ratio4x3,
        // CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Image Cropper',
            toolbarColor: Colors.pinkAccent,
            toolbarWidgetColor: Colors.grey,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
      ],
    );
    if (croppedFile != null) {
      File imageFile = File(croppedFile.path);
      img = imageFile;
      setState(() {});
    }
  }

  getAdd() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.position.latitude, widget.position.longitude);
    setState(() {
      _houseStateEdC.text = placemarks[0].administrativeArea.toString();
      _houseLocalEdC.text = placemarks[0].locality.toString();
    });
  }

  void insertProduct() {
    String prname = _houseNameEdC.text;
    String prdesc = _houseDescEdC.text;
    String prprice = _housePriceEdC.text;
    String delivery = _houseDelvEdC.text;
    String qty = _houseSlotEdC.text;
    String state = _houseStateEdC.text;
    String local = _houseLocalEdC.text;
    String base64Image = base64Encode(img!.readAsBytesSync());

    http.post(Uri.parse("${Config.server}/php/insert_product.php"), body: {
      //"userid": widget.user.id,
      "prname": prname,
      "prdesc": prdesc,
      "prprice": prprice,
      "delivery": delivery,
      "qty": qty,
      "state": state,
      "local": local,
      "lat": lat,
      "lon": lon,
      "image": base64Image
    }).then((response) {
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == "success") {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        Navigator.of(context).pop();
        return;
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        return;
      }
    });
  }
}
