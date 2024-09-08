// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:loading_overlay/loading_overlay.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../main.dart';
// import '../utils/navigation_service.dart';
// import '../utils/utils.dart';
// import 'HomePage.dart';



// class StartPage extends StatefulWidget {

//   final int version;
//   final bool forUpdate;

//   const StartPage(this.version, this.forUpdate, {Key? key}) : super(key: key);

//   @override
//   State<StartPage> createState() => _StartPageState();
// }

// class _StartPageState extends State<StartPage> {

//   late final NavigationService _navigation;
//   bool isLoading = false;
//   bool hasFile = false;
//   bool found = false;
//   bool shouldProceed = false;
//   final TextEditingController inPutIdController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Welcome"),),
//       body: LoadingOverlay(
//         isLoading: isLoading,
//         color: Colors.blue,
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             //child: allFields(),
//             child:  Center(child: single()),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget single(){
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         const SizedBox(height: 20),
//         Image.asset("assets/logo_black.png", height: 100,),
//         const SizedBox(height: 20),
//         const Text("Please enter your ID number located on your ID card. Form is case sensitive"),
//         const SizedBox(height: 10),
//         TextFormField(
//             textCapitalization: TextCapitalization.sentences,
//             controller: inPutIdController,
//             //autovalidateMode: AutovalidateMode.onUserInteraction,
//             keyboardType: TextInputType.text,
//             decoration: const InputDecoration(
//               focusColor: Colors.blue,
//               border: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.black26)),
//               labelText: "ID Number",
//               errorStyle: TextStyle(color: Colors.red),
//               prefixIcon: Icon(Icons.person),
//               hintText: 'eg. GM003',
//             )),
//         const SizedBox(height: 20),
//         found ? Text("ID not found", style: TextStyle(color: Colors.red),) : Container(),
//         const SizedBox(height: 10),
//         ElevatedButton(
//             onPressed: (){
//               if(inPutIdController.text.isNotEmpty){
//                 getData();
//               }else{
//                 Utils.showToast("ID required");
//               }
//             },
//             child: const Text("Check")
//         ),
//         const SizedBox(height: 5),
//         TextButton(
//             onPressed: (){
//               _navigation.removeAndNavigateToRoute('/login');
//             },
//             child: Text("Login")
//         )
//       ],
//     );
//   }

//   void getData(){
//     List<dynamic> list = [];
//     setState(() {
//       isLoading = true;
//     });
//     staffs.doc("ids").get().then((value) async {
//       setState(() {
//         list = value.data()!["id_number"];
//       });
//       if(list.contains(inPutIdController.text.replaceAll(" ", ""))){
//         setState(() {
//           shouldProceed = list.contains(inPutIdController.text.replaceAll(" ", ""));
//           found = !shouldProceed;
//           isLoading = false;
//         });
//         getUserData(inPutIdController.text.replaceAll(" ", ""));
//       }else{
//         setState(() {
//           isLoading = false;
//         });
//         Utils.showToast("ID not found");
//       }

//     }).onError((error, stackTrace) {
//       setState(() {
//         isLoading = false;
//       });
//       Utils.showToast("Something went wrong, try again");
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     // print("Accessing NavigationService"); // Debug print
//     // GetIt sl = GetIt.instance;
//     // _navigation = sl.get<NavigationService>(); 
//     if (GetIt.instance.isRegistered<NavigationService>()) {
//       _navigation = GetIt.instance.get<NavigationService>();
//     } else {
//         print("NavigationService is not registered");
//     }// Retrieve after setup
//   }
//  Future<void> getUserData(String id) async {
//   setState(() {
//     isLoading = true;
//   });

//   FirebaseAuth auth = FirebaseAuth.instance;

//   try {
//     // Retrieve email from Firestore


//     String email =  await users.doc(id).get().then((value) => value.get("email"));
//     print('Retrieved email: $email');

//     // Sign in with email and password
//     UserCredential userCredential = await auth.signInWithEmailAndPassword(
//       email: email,
//       password: '12345678', // Ensure this matches the user's password
//     );

//     print('User signed in: ${userCredential.user?.email}');

//     // Store user ID in SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('id', id);

//     // Navigate to home page
//     _navigation.removeAndNavigateToRoute('/home');

//   } on FirebaseAuthException catch (e) {
//     // Handle specific FirebaseAuthException cases
//     if (e.code == 'wrong-password') {
//       Utils.showToast("Wrong password");
//     } else if (e.code == 'user-not-found') {
//       Utils.showToast("User not found");
//     } else {
//       Utils.showToast("Authentication error: ${e.message}");
//     }
//   } catch (e) {
//     // Handle general errors
//     Utils.showToast("Something went wrong: ${e.toString()}");
//     print("${e.toString()}");
//   } finally {
//     setState(() {
//       isLoading = false;
//     });
//   }
// }


// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../utils/navigation_service.dart';
import '../utils/utils.dart';

class StartPage extends StatefulWidget {
  final int version;
  final bool forUpdate;

  const StartPage(this.version, this.forUpdate, {Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late final NavigationService _navigation;
  bool isLoading = false;
  bool hasFile = false;
  bool found = false;
  bool shouldProceed = false;
  final TextEditingController inPutIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome"),),
      body: LoadingOverlay(
        isLoading: isLoading,
        color: Colors.blue,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: single()),
          ),
        ),
      ),
    );
  }

  Widget single() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Image.asset("assets/logo_black.png", height: 100,),
        const SizedBox(height: 20),
        const Text("Please enter your ID number located on your ID card. Form is case sensitive"),
        const SizedBox(height: 10),
        TextFormField(
          textCapitalization: TextCapitalization.sentences,
          controller: inPutIdController,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            focusColor: Colors.blue,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
            ),
            labelText: "ID Number",
            errorStyle: TextStyle(color: Colors.red),
            prefixIcon: Icon(Icons.person),
            hintText: 'eg. GM003',
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            focusColor: Colors.blue,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
            ),
            labelText: "Password",
            errorStyle: TextStyle(color: Colors.red),
            prefixIcon: Icon(Icons.lock),
            hintText: 'Enter your password',
          ),
        ),
        const SizedBox(height: 20),
        found ? Text("ID not found", style: TextStyle(color: Colors.red),) : Container(),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            if (inPutIdController.text.isNotEmpty && passwordController.text.isNotEmpty) {
              getData();
            } else {
              Utils.showToast("ID and Password required");
            }
          },
          child: const Text("Check")
        ),
        const SizedBox(height: 5),
        TextButton(
          onPressed: () {
            _navigation.removeAndNavigateToRoute('/reg');
          },
          child: Text("Registeration")
        )
      ],
    );
  }

  void getData() {
    List<dynamic> list = [];
    setState(() {
      isLoading = true;
    });
    staffs.doc("ids").get().then((value) async {
      setState(() {
        list = value.data()!["id_number"];
      });
      if (list.contains(inPutIdController.text.replaceAll(" ", ""))) {
        setState(() {
          shouldProceed = true;
          found = false;
          isLoading = false;
        });
        getUserData(inPutIdController.text.replaceAll(" ", ""));
      } else {
        setState(() {
          isLoading = false;
        });
        Utils.showToast("ID not found");
      }
    }).onError((error, stackTrace) {
      setState(() {
        isLoading = false;
      });
      Utils.showToast("Something went wrong, try again");
    });
  }

  Future<void> getUserData(String id) async {
    setState(() {
      isLoading = true;
    });

    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      String email = await users.doc(id).get().then((value) => value.get("email"));
      String password = passwordController.text;

      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('User signed in: ${userCredential.user?.email}');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id', id);

      _navigation.removeAndNavigateToRoute('/home');

    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        Utils.showToast("Wrong password");
      } else if (e.code == 'user-not-found') {
        Utils.showToast("User not found");
      } else {
        Utils.showToast("Authentication error: ${e.message}");
      }
    } catch (e) {
      Utils.showToast("Something went wrong: ${e.toString()}");
      print("${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (GetIt.instance.isRegistered<NavigationService>()) {
      _navigation = GetIt.instance.get<NavigationService>();
    } else {
      print("NavigationService is not registered");
    }
  }
}

