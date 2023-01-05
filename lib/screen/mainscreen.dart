import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homestayraya/screen/loginscreen.dart';
import 'package:homestayraya/screen/newhouse.dart';
import 'package:homestayraya/screen/regscreen.dart';
import 'package:flutter/material.dart';
import '../../model/user.dart';
import '../config.dart';
import '../model/product.dart';
import '../shared/mainmenu.dart';
import 'package:intl/intl.dart';
import 'package:ndialog/ndialog.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  final User user;

  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var lat, long;
  late Position position;
  List<House> houseList = <House>[];
  String titlecenter = "Loading...";
  var placemarks;
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  late double screenHeight, screenWidth, resWidth;
  int rowcount = 2;

  @override
  void initState() {
    super.initState();
    // checkLocation();
    loadHouse();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(title: const Text("View Home"), actions: [
            IconButton(
                onPressed: _registrationForm,
                icon: const Icon(Icons.app_registration)),
            IconButton(onPressed: _loginForm, icon: const Icon(Icons.login)),
            PopupMenuButton(itemBuilder: (context) {
              return [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text("New Product"),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text("My Order"),
                ),
              ];
            }, onSelected: (value) {
              if (value == 0) {
                _gotoNewProduct();
                print("My account menu is selected.");
              } else if (value == 1) {
                print("Settings menu is selected.");
              } else if (value == 2) {
                print("Logout menu is selected.");
              }
            })
          ]),
          body: houseList.isEmpty
              ? Center(
                  child: Text(titlecenter,
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold)))
              : Column(
                  children: [
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        children: List.generate(houseList.length, (index) {
                          return Card(
                            child: Column(children: [
                              Flexible(
                                flex: 6,
                                child: CachedNetworkImage(
                                  width: 200,
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      "${Config.server}/asset/roomimages/${houseList[index].productId}.png",
                                  placeholder: (context, url) =>
                                      const LinearProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                              Text(houseList[index].productName.toString()),
                              Text("RM ${houseList[index].productPrice}"),
                            ]),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
          drawer: MainMenuWidget(user: widget.user)),
    );
  }

  String truncateString(String str, int size) {
    if (str.length > size) {
      str = str.substring(0, size);
      return "$str...";
    } else {
      return str;
    }
  }

  void _registrationForm() {
    Navigator.push(context,
        MaterialPageRoute(builder: (content) => const RegistrationScreen()));
  }

  void _loginForm() {
    Navigator.push(
        context, MaterialPageRoute(builder: (content) => const LoginScreen()));
  }

  Future<void> _gotoNewProduct() async {
    if (widget.user.id == "0") {
      Fluttertoast.showToast(
          msg: "Please login/register",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          fontSize: 18.0);
      return;
    }
    ProgressDialog progressDialog = ProgressDialog(
      context,
      blur: 10,
      message: const Text("Searching your current location"),
      title: null,
    );
    progressDialog.show();
    if (await checkLocation()) {
      progressDialog.dismiss();
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (content) => NewProdScreen(
                  position: position,
                  user: widget.user,
                  placemarks: placemarks)));
      loadHouse();
    } else {
      Fluttertoast.showToast(
          msg: "Please allow the app to access the location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    }
  }

  Future<bool> checkLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg: "Please allow the app to access the location",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        Geolocator.openLocationSettings();
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: "Please allow the app to access the location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
      Geolocator.openLocationSettings();
      return false;
    }
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    try {
      placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      Fluttertoast.showToast(
          msg:
              "Error in fixing your location. Make sure internet connection is available and try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
      return false;
    }
    return true;
  }

  void loadHouse() {
    if (widget.user.id == "0") {
      Fluttertoast.showToast(
          msg: "Please register an account first",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    http
        .get(
      Uri.parse("${Config.server}/php/load_house.php?userid=${widget.user.id}"),
    )
        .then((response) {
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          var extractdata = jsondata['data'];
          if (extractdata['products'] != null) {
            houseList = <House>[];
            extractdata['products'].forEach((v) {
              houseList.add(House.fromJson(v));
            });
            titlecenter = "Found";
          } else {
            titlecenter = "No Product Available";
            houseList.clear();
          }
        } else {
          titlecenter = "No Product Available";
        }
      } else {
        titlecenter = "No Product Available";
        houseList.clear();
      }
      setState(() {});
    });
  }

  Future<void> _showDetails(int index) async {
    House house = House.fromJson(houseList[index].toJson());

    // await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (content) => DetailsScreen(
    //               product: product,
    //               user: widget.user,
    //             )));
    loadHouse();
  }
}
