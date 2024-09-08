import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:animation_wrappers/animations/faded_scale_animation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import '../utils/img.dart';
import '../utils/my_colors.dart';
import '../utils/my_strings.dart';
import '../utils/my_text.dart';
import '../utils/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'dart:io';
import 'package:image/image.dart' as Im;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../utils/utils.dart';


class MyHomePage extends StatefulWidget {

  final int version;
  final bool forUpdate;

  const MyHomePage(this.forUpdate, this.version, {super.key,});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late NavigationService _navigation;
  String image = "Loading...";
  bool empStatus = true;
  bool isLoading = false;
  String workState = "";
  String name = "Loading...";
  String department = "Loading...";
  String iDNumber = "Loading...";
  List wifiMacList = [];
  final TextEditingController commentController = TextEditingController();
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();
  final LocalAuthentication localAuth = LocalAuthentication();
  List<dynamic> wifiList = [];
  String userId = "";

  late  double lat;
  late  double long;
  late String locDisplay = "Sign-in location. >";

  //location info
  bool isInPlace = false;
  String status_ = "";
  int radius_ = 0;
  String placeOfWork = "";

  //image upload
  final ImagePicker _picker = ImagePicker();
  File imageFile = File('');
  bool hasFile = false;


  Future<void> processImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    File file = await Utils.compressImages(File(image!.path));
    setState(() {
      imageFile = file;
      hasFile = true;
    });

   if(hasFile){
     Utils.showToast("Updating image...");
     String url = await uploadAndGetUrl(imageFile);
     await users.doc(userId).update({"image" : url });
     getUserData(userId);
   }
  }

  Future<String> uploadAndGetUrl(File imageFile) async {
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref("profile_pics").child("$time.jpg");
    await ref.putFile(imageFile);
    String image = await ref.getDownloadURL();
    return image;

  }


  Future<Object> _determinePosition()  async {

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();



  }

  @override
  void initState() {
    _determinePosition();
    _navigation = GetIt.instance.get<NavigationService>();
    auth.authStateChanges().listen((user) async {
      final prefs = await SharedPreferences.getInstance();
      final String? id = prefs.getString('id');
      setState(() {
        userId = id!;
      });
      if (user != null) {
        await getUserData(userId);
        await users.doc(id).update({
          "app_version": Utils.appVersion, // This is for future app update TODO always change app version
        });
        if(widget.version > Utils.appVersion){
          init();
        }
      }else{
        if (_navigation.getCurrentRoute() != '/login') {
          _navigation.removeAndNavigateToRoute('/login');
        }
      }
    });
    super.initState();

 
  }

  Future<void> getUserData(String id) async {
    if(mounted){
      setState(() {
        isLoading = true;
      });
    }
    await users.doc(id).get().then((value) {
      if(mounted){
        setState(() {
          name = value.get("name");
          image = value.get("image");
          department = value.get("department");
          iDNumber = value.get("id_number");
          empStatus = value.get("emp_status");
          workState = value.get("work_state");
          isLoading = false;
        });
      }
    }).onError((error, stackTrace) {
      if(mounted){
        setState(() {
          isLoading = false;
        });
      }
      Utils.showToast("There was an issue fetching data");
    });
  }

  init() async {
    if(mounted){
      showDialog<Widget>(
        context: context,
        barrierDismissible: false, 
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Heads up'),
            content: const Text("You are currently running an old version of the app. \n Please update from Google Play Store to get the latest feature"),
            actions: [
              TextButton(
                  onPressed: (){
                    if(widget.forUpdate == true){
                      SystemNavigator.pop();
                    }else{
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(widget.forUpdate == true ? "Update" : "Ok")
              ),
            ],
          );
        },
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    String currentTime = selectedDate.toString().substring(0,10);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: LoadingOverlay(
          isLoading: isLoading,
          child: NestedScrollView(
            physics: const NeverScrollableScrollPhysics(),
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  stretch: true,
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Image.asset(Img.get('logo_black.png'), fit: BoxFit.contain,),
                  ),
                  actions: [

                    Center(child: Text(locDisplay,style: TextStyle(
                    color: Colors.white, // Text color
                    fontSize: 24, // Larger font size for visibility
                    fontWeight: FontWeight.bold, // Bold text
                    letterSpacing: 1.5, // Letter spacing for clearer readability
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.7),
                        offset: Offset(2, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),)),

                    // PopupMenuButton<String>(
                    //       onSelected: (String value) {
                    //         if (value == "central") {
                    //           setState(() {
                    //             lat = 9.048969;
                    //             long = 7.473044; // Central area
                    //             locDisplay = "Abuja";
                    //             placeOfWork = "Abuja";
                    //           });
                    //         } else if (value == "IbadanNigeria") {
                    //           setState(() {
                    //             lat = 7.404107;
                    //             long = 3.931804;
                    //             locDisplay = "Ibadan";
                    //             placeOfWork = "Ibadan";
                    //           });
                    //         } else if (value == "A5Abeokuta") {
                    //           setState(() {
                    //             lat = 7.157794;
                    //             long = 3.349060;
                    //             locDisplay = "Abeokuta";
                    //             placeOfWork = "Abeokuta";
                    //           });
                    //         } else if (value == "Ondo") {
                    //           setState(() {
                    //             lat = 7.256008;
                    //             long = 5.184630;
                    //             locDisplay = "Ondo";
                    //             placeOfWork = "Ondo";
                    //           });
                    //         } else if (value == "IleIfeOsun") {
                    //           setState(() {
                    //             lat = 7.5170654;
                    //             long = 4.5116048;
                    //             locDisplay = "Ile Ife";
                    //             placeOfWork = "Ile Ife";
                    //           });
                    //         } else if (value == "OsogboOsun") {
                    //           setState(() {
                    //             lat = 7.781982;
                    //             long = 4.558735;
                    //             locDisplay = "Osogbo";
                    //             placeOfWork = "Osogbo";
                    //           });
                    //         } else if (value == "IslamabadPakistan") {
                    //            setState(() {
                    //                lat = 33.709392;
                    //                long = 73.075551;
                    //                locDisplay = "Islamabad";
                    //                placeOfWork = "Islamabad";
                    //           });
                    //         }
                    //       },
                    //       itemBuilder: (context) => [
                    //         const PopupMenuItem(
                    //           value: "central",
                    //           child: Text("Central area, Abuja"),
                    //         ),
                    //         const PopupMenuItem(
                    //           value: "IbadanNigeria",
                    //           child: Text("Ibadan, Nigeria"),
                    //         ),
                    //         const PopupMenuItem(
                    //           value: "A5Abeokuta",
                    //           child: Text("A5, Abeokuta"),
                    //         ),
                    //         const PopupMenuItem(
                    //           value: "Ondo",
                    //           child: Text("Ondo"),
                    //         ),
                    //         const PopupMenuItem(
                    //           value: "IleIfeOsun",
                    //           child: Text("Ile Ife, Osun"),
                    //         ),
                    //         const PopupMenuItem(
                    //           value: "OsogboOsun",
                    //           child: Text("Osogbo, Osun"),
                    //         ),
                    //         const PopupMenuItem(
                    //           value: "IslamabadPakistan",
                    //           child: Text("Islamabad, Pakistan"),
                    //         ),
                    //       ],
                    //     )
                    PopupMenuButton<String>(
                      onSelected: (String value) {
                        if (value == "central") {
                          setState(() {
                            lat = 9.048969;
                            long = 7.473044; // Central area
                            locDisplay = "Abuja";
                            placeOfWork = "Abuja";
                          });
                        } 
                        // else if (value == "IbadanNigeria") {
                        //   setState(() {
                        //     lat = 7.404107;
                        //     long = 3.931804;
                        //     locDisplay = "Ibadan";
                        //     placeOfWork = "Ibadan";
                        //   });
                        // }
                        //  else if (value == "A5Abeokuta") {
                        //   setState(() {
                        //     lat = 7.157794;
                        //     long = 3.349060;
                        //     locDisplay = "Abeokuta";
                        //     placeOfWork = "Abeokuta";
                        //   });
                        // } 
                        else if (value == "Ondo") {
                          setState(() {
                            lat = 7.256008;
                            long = 5.184630;
                            locDisplay = "Ondo";
                            placeOfWork = "Ondo";
                          });
                        } 
                        // else if (value == "IleIfeOsun") {
                        //   setState(() {
                        //     lat = 7.5170654;
                        //     long = 4.5116048;
                        //     locDisplay = "Ile Ife";
                        //     placeOfWork = "Ile Ife";
                        //   });
                        // } 
                        else if (value == "OsogboOsun") {
                          setState(() {
                            lat = 7.781982;
                            long = 4.558735;
                            locDisplay = "Osogbo";
                            placeOfWork = "Osogbo";
                          });
                        } else if (value == "IslamabadPakistan") {
                          setState(() {
                            lat = 33.709392;
                            long = 73.075551;
                            locDisplay = "Islamabad";
                            placeOfWork = "Islamabad";
                          });
                        } else if (value == "KundiDarra") {
                          setState(() {
                            lat = 34.026074;
                            long = 72.699870;
                            locDisplay = "Kundi Darra";
                            placeOfWork = "Haripur";
                          });
                        }else if (value == "NawanShehr") {
                          setState(() {
                            lat = 34.169365;
                            long = 73.270439;
                            locDisplay = "Nawan Shehr Town";
                            placeOfWork = "Abbottabad";
                          });
                        }else if (value == "HavelianAbbottabad") {
                            setState(() {
                              lat = 34.053894;
                              long = 73.151777;
                              locDisplay = "Havelian, Abbottabad";
                              placeOfWork = "Havelian, Abbottabad";
                            });
                          }
                        
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "central",
                          child: Text("Central area, Abuja"),
                        ),
                        // const PopupMenuItem(
                        //   value: "IbadanNigeria",
                        //   child: Text("Ibadan, Nigeria"),
                        // ),
                        // const PopupMenuItem(
                        //   value: "A5Abeokuta",
                        //   child: Text("A5, Abeokuta"),
                        // ),
                        const PopupMenuItem(
                          value: "Ondo",
                          child: Text("Ondo"),
                        ),
                        // const PopupMenuItem(
                        //   value: "IleIfeOsun",
                        //   child: Text("Ile Ife, Osun"),
                        // ),
                        const PopupMenuItem(
                          value: "OsogboOsun",
                          child: Text("Osogbo, Osun"),
                        ),
                        const PopupMenuItem(
                          value: "IslamabadPakistan",
                          child: Text("Islamabad, Pakistan"),
                        ),
                        const PopupMenuItem(
                          value: "KundiDarra",
                          child: Text("Kundi Darra, Haripur, Pakistan"),
                        ),
                        const PopupMenuItem(
                          value: "NawanShehr",
                          child: Text("Nawan Shehr Town, Abbottabad, Pakistan"),
                        ),const PopupMenuItem(
                            value: "HavelianAbbottabad",
                            child: Text("Havelian, Abbottabad, Pakistan"), // New location
                          ),
                      ],
                    )


                  ],
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(50),
                    child: Container(
                      transform: Matrix4.translationValues(0, 50, 0),
                      child: GestureDetector(
                        onTap: () async {
                          processImage();
                        },
                        child: FadedScaleAnimation(
                          child: CircleAvatar(
                              radius: 50,
                              backgroundImage: CachedNetworkImageProvider(image)
                              //backgroundImage: hasFile ? FileImage(imageFile) : CachedNetworkImageProvider(image)
                          ),

                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: empStatus ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(height: 70),
                      Text(name, style: MyText.headlineLarge(context)!.copyWith(
                          color: Colors.grey[900], fontWeight: FontWeight.bold
                      )),
                      Container(height: 10),
                      Text(iDNumber),
                      Container(height: 10),
                      Text(department, textAlign : TextAlign.center, style: MyText.titleLarge(context)!.copyWith(
                          color: Colors.grey[900]
                      )),
                      Container(height: 10),
                      Text(workState != "IN" ? "(You are signed out)" : "(You are signed in)", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      Container(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          backgroundColor: Colors.grey,
                          //primary: MyColors.grey_3
                        ),
                        child: Text(workState == "IN" ? "check Task" : "Sign in", style: const TextStyle(color: Colors.white)),
                        onPressed: () async {
                          // sign out
                          if(workState == "IN"){
                            setState(() {
                              isLoading = true;
                            });
                            // check if user as submitted report first before signing out
                            String status = await users.doc(userId).get().then((value) => value.get("last_report")).onError((error, stackTrace) {
                              setState(() {
                                isLoading = false;
                              });
                              Utils.showToast("Fail to complete task");
                            });
                            if(currentTime != status){
                              setState(() {
                                isLoading = false;
                              });
                              Utils.showToast("Please submit your daily report first");


                            }else{
                              await users.doc(userId).update({"work_state":"OUT"}).then((value) async {
                                //getUserData(userId);
                                setState(() {
                                  isLoading = false;
                                });
                                await addData("OUT");
                                Utils.showToast("Signed Out successfully");
                                auth.signOut().then((value) => _navigation.removeAndNavigateToRoute("/start"));
                                //SystemNavigator.pop();
                              }).onError((error, stackTrace) {
                                setState(() {
                                  isLoading = false;
                                });
                                Utils.showToast("Something went wrong");
                              });
                            }
                          }else{
                            // sign in
                            await checkLocation();
                          }
                        },
                      ),
                      Container(height: 20),
                      workState == "IN" ? restField() : Container(),
                    ],
                  ),
                ) : Center(child: Text("You have been removed", style: TextStyle(color: Colors.red),),)
            ),
          ),
        ),
      ),
    );
  }

Widget restField() {
    return Form(
      key: _formKey,  // Attach the key to the Form
      child: Column(
        children: [
          const Text("Submit your daily report below"),
          const SizedBox(height: 5),

          // Title or Unit Field
          TextFormField(
            keyboardType: TextInputType.text,
            cursorColor: Colors.blue,
            controller: title,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return "Title is required";
              } else if (text.length < 3) {
                return "Title is too short";
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              focusColor: Colors.blue,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26)),
              labelText: "Title or unit",
              errorStyle: TextStyle(color: Colors.red),
              prefixIcon: Icon(Icons.title),
              hintText: 'eg. Tech unit',
            ),
          ),
          const SizedBox(height: 20),

          // Name Field
          TextFormField(
            enabled: false,
            keyboardType: TextInputType.text,
            cursorColor: Colors.blue,
            controller: TextEditingController(text: name),
            decoration: const InputDecoration(
              focusColor: Colors.blue,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26)),
              labelText: "Who is submitting this report",
              prefixIcon: Icon(Icons.person),
              hintText: 'Your name',
            ),
          ),
          const SizedBox(height: 20),

          // Description Field
          TextFormField(
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            cursorColor: Colors.blue,
            controller: description,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return "Description is required";
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              focusColor: Colors.blue,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26)),
              labelText: "Description",
              errorStyle: TextStyle(color: Colors.red),
              hintText: 'Activities, observations, recommendations etc',
            ),
          ),
          const SizedBox(height: 35),

          // Submit Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              backgroundColor: MyColors.primary,
            ),
            child: const Text("Submit report", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              if (workState != "OUT") {
                // Use the _formKey to validate the form
                if (_formKey.currentState!.validate()) {
                  sendReport();
                  print('Form is valid, report sent.');
                } else {
                  Utils.showToast("Please fill in all required fields.");
                }
              } else {
                Utils.showToast("You are signed out");
              }
            },
          ),
        ],
      ),
    );
  }



  bool _decideWhichDayToEnable(DateTime day) {
    if ((day.isBefore(DateTime.now().add(Duration(days: 1))) )) {
      return true;
    }
    return false;
  }


void sendReport() async {
  List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  DateTime selectedDate = DateTime.now();
  print("here");

  // Basic validation
  if (title.text.isEmpty || description.text.isEmpty) {
    Utils.showToast("Title and description cannot be empty");
    return;
  }

  try {
    await dailyReport.add({
      "name": name,
      "hour": DateFormat('h a').format(selectedDate).toLowerCase(),
      "hour_with_day": DateFormat('h').format(selectedDate).toLowerCase(),
      "hour_without_day": DateFormat('a').format(selectedDate).toLowerCase(),
      "min": DateFormat('mm').format(selectedDate).toLowerCase(),
      "full_time": DateFormat('h:mm a').format(selectedDate).toLowerCase(),
      "month": months[selectedDate.month - 1],
      "title": title.text,
      "desc": description.text,
      "day": DateFormat('EEEE').format(selectedDate).toLowerCase(),
      "year": selectedDate.year,
      "current_date": selectedDate.day,
      "email": auth.currentUser?.email,
      "system_date": FieldValue.serverTimestamp(),
      "formatted_date": selectedDate.toString().substring(0, 10)
    }).then((value) async {
      // Update the user's last report timestamp
      DateTime selectedDate = DateTime.now();
      String currentTime = selectedDate.toString().substring(0, 10);
      await users.doc(userId).update({"last_report": currentTime});
      // Utils.showToast("Thank you for submitting your report");
      thankYouDialog("submitting your report"); // Remove for web
    }).catchError((error) {
      // Handle any errors
      Utils.showToast("Failed to submit report: $error");
    });

    // Clear fields after submission
    title.clear();
    description.clear();
    // Optionally update the state
    // setState(() {
    //   selectedDate = DateTime.now();
    // });

  } catch (e) {
    // Catch any unexpected errors
    Utils.showToast("An unexpected error occurred: $e");
  }
}


  locationDialog() async {
    return showDialog<Widget>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lets know where you are'),
          content: Lottie.asset('assets/location.json'),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text("Cancel")
            ),
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                  //locationFunc();
                },
                child: Text("Enable location")
            )
          ],
        );
      },
    );
  }


  scannerDialog() async {
    return showDialog<Widget>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Next, lets verify its you'),
          content: Lottie.asset('assets/scan.json'),
          actions: <Widget>[
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text("Cancel")
            ),
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                 // _authenticate();
                  //_authenticate()
                },
                child: Text("Scan fingerprint")
            )
          ],
        );
      },
    );
  }

  cancelDialog() async {
    return showDialog<Widget>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("It appears you're not at your duty post. Attendant cancelled", style: TextStyle(fontSize: 20),),
          content: Icon(Icons.error, color: Colors.red, size: 100,),
          actions: <Widget>[
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text("Ok")
            )
          ],
        );
      },
    );
  }

  thankYouDialog(String sms) async {
    return showDialog<Widget>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thank you for $sms'),
          content: Lottie.asset('assets/thankyou.json'),
          actions: <Widget>[
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text("Ok")
            )
          ],
        );
      },
    );
  }

  checkingLocation() async {
    return showDialog<Widget>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detecting your location. This might take about 5 seconds...'),
          // content: Text("You have successfully sign in, please close this page"),
          content: Lottie.asset('assets/detect_loc.json'),
          actions: <Widget>[
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text("Ok")
            )
          ],
        );
      },
    );
  }


  String monthLogic(){
    List months = ['Jan', 'Feb', 'Mar', 'Apr', 'May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var now =  DateTime.now();
    return months[now.month - 1];
  }

  Future<void> addData(String mode) async {
    DateTime dateToday = DateTime.now();
    String date = dateToday.toString().substring(0,10);
    String month = monthLogic();
    String day = DateFormat('EEEE').format(dateToday);

    attendance.add({
      "radius": radius_,
      "mode": mode,
      "status": status_,
      "placeOfWork": placeOfWork,
      "name": name,
      "hour": DateFormat('h a').format(dateToday).toLowerCase(),
      "hour_with_day": DateFormat('h').format(dateToday).toLowerCase(),
      "hour_without_day": DateFormat('a').format(dateToday).toLowerCase(),
      "min": DateFormat('mm').format(dateToday).toLowerCase(),
      "full_time": DateFormat('h:mm a').format(dateToday).toLowerCase(),
      "month": month,
      "comment": commentController.text,
      "day": day.toLowerCase(),
      "year": dateToday.year,
      "current_date": dateToday.day,
      "email": auth.currentUser?.email,
      "system_date": FieldValue.serverTimestamp(),
      "formatted_date": date
    });

  }

  Future<void> continueWithSignIn(int round)async {
    setState(() {
      isLoading = true;
      radius_ = round;
    });
    await users.doc(userId).update({"work_state":"IN"}).then((value) async {
      //await getUserData(userId);
      await addData("IN");
      Utils.showToast("Signed In successfully");
      setState(() {
        isLoading = false;
      });
      auth.signOut().then((value) => _navigation.removeAndNavigateToRoute("/start"));
      //SystemNavigator.pop();
    }).onError((error, stackTrace) {
      setState(() {
        isLoading = false;
      });
      Utils.showToast("Something went wrong continue!!!");
    });
  }

  Future<void> checkLocation()async {
    //checkingLocation();
    Utils.showToast("Please wait...");
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    const Distance distance =  Distance();

    Timer(const Duration(seconds: 5), () async {

      //Utils.showToast("${position.latitude}, ${position.longitude}");

      final double meter = distance.as(LengthUnit.Meter, LatLng(lat, long), LatLng(position.latitude, position.longitude));
      //final double meter = distance.as(LengthUnit.Meter, LatLng(8.974969, 7.336501), LatLng(position.latitude, position.longitude));

     // print("${position.latitude}, ${position.longitude}");
     // print("this is the meter: $meter");
      //print("Abuja lat: $lat");
      //print("Abuja long: $long");

      if(locDisplay != "Sign-in location. >"){
        if(meter.round() < 250){
          //Navigator.of(context).pop();
          checkingLocation();
          await continueWithSignIn(meter.round());
        }else{
          //Navigator.of(context).pop();
          Utils.showToast("Looks like you're not at your workplace");
        }
      }else{
        Utils.showToast("Please select a location");
      }


    });
  }
}
