// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:credit_capital/page/HomePage.dart';
// import 'package:credit_capital/page/login.dart';

// import 'package:credit_capital/page/register.dart';
// import 'package:credit_capital/page/start_page.dart';
// import 'package:credit_capital/utils/navigation_service.dart'; // Import NavigationService

// // Initialize Firestore collections
// final staffs = FirebaseFirestore.instance.collection('staffs');
// final users = FirebaseFirestore.instance.collection('users');
// final wifi = FirebaseFirestore.instance.collection('wifi');
// final attendance = FirebaseFirestore.instance.collection('attendance');
// final dailyReport = FirebaseFirestore.instance.collection('dailyReports');
// final update = FirebaseFirestore.instance.collection('appSettings');
// final testLoc = FirebaseFirestore.instance.collection('testLoc');

// void setupLocator() {
//   GetIt.instance.registerSingleton<NavigationService>(NavigationService());
//   print("NavigationService registered with GetIt."); // Debug print
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   setupLocator(); // Correct order: register services first
//   await Firebase.initializeApp(); // Then initialize Firebase

//   runApp(const MyApp());
// }
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   int version = 0;
//   bool forUpdate = false;
//   bool firebaseConnected = false;

//   @override
//   void initState() {
//     super.initState();
//     checkAppUpdate(); // Call after super.initState()
//     checkFirebaseConnection();
//   }

//   Future<void> checkAppUpdate() async {
//     try {
//       DocumentSnapshot doc = await update.doc("app").get();
//       if (mounted) {
//         setState(() {
//           version = doc.get("version");
//           forUpdate = doc.get("forceUpdate");
//         });
//       }
//     } catch (e) {
//       print("Error checking app update: $e");
//       // Optionally handle the error (e.g., show a snackbar or log it)
//     }
//   }
//    Future<void> checkFirebaseConnection() async {
//     try {
//       // Attempt a simple Firestore read operation
//       DocumentSnapshot doc = await staffs.doc('ids').get();
//       if (doc.exists) {
//         setState(() {
//           firebaseConnected = true;
//         });
//         print("Firestore is connected.");
//       } else {
//         print("Document does not exist in Firestore.");
//       }
//     } catch (e) {
//       print("Error connecting to Firestore: $e");
//       setState(() {
//         firebaseConnected = false;
//       });
//     }
//    }

//   @override
//   Widget build(BuildContext context) {
//     FirebaseAuth auth = FirebaseAuth.instance;
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       navigatorKey: NavigationService.navigatorKey, // Access the static navigatorKey directly
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: auth.currentUser != null
//           ? MyHomePage(forUpdate, version)
//           : StartPage(version, forUpdate),
//       initialRoute: '/start',
//       routes: {
//         '/login': (context) => Login(version, forUpdate),
//         '/start': (context) => StartPage(version, forUpdate),
//         '/reg': (context) => Register(version, forUpdate),
//         '/home': (context) => MyHomePage(forUpdate, version),
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credit_capital/page/HomePage.dart';
import 'package:credit_capital/page/login.dart';
import 'package:credit_capital/page/register.dart';
import 'package:credit_capital/page/start_page.dart';
import 'package:credit_capital/utils/navigation_service.dart';
import 'package:credit_capital/page/taskpage.dart'; // Import TaskPage

// Initialize Firestore collections
final staffs = FirebaseFirestore.instance.collection('staffs');
final users = FirebaseFirestore.instance.collection('users');
final wifi = FirebaseFirestore.instance.collection('wifi');
final attendance = FirebaseFirestore.instance.collection('attendance');
final dailyReport = FirebaseFirestore.instance.collection('dailyReports');
final update = FirebaseFirestore.instance.collection('appSettings');
final testLoc = FirebaseFirestore.instance.collection('testLoc');

void setupLocator() {
  GetIt.instance.registerSingleton<NavigationService>(NavigationService());
  print("NavigationService registered with GetIt."); // Debug print
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator(); // Correct order: register services first
  await Firebase.initializeApp(); // Then initialize Firebase

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int version = 0;
  bool forUpdate = false;
  bool firebaseConnected = false;

  @override
  void initState() {
    super.initState();
    checkAppUpdate(); // Call after super.initState()
    checkFirebaseConnection();
  }

  Future<void> checkAppUpdate() async {
    try {
      DocumentSnapshot doc = await update.doc("app").get();
      if (mounted) {
        setState(() {
          version = doc.get("version");
          forUpdate = doc.get("forceUpdate");
        });
      }
    } catch (e) {
      print("Error checking app update: $e");
    }
  }

  Future<void> checkFirebaseConnection() async {
    try {
      DocumentSnapshot doc = await staffs.doc('ids').get();
      if (doc.exists) {
        setState(() {
          firebaseConnected = true;
        });
        print("Firestore is connected.");
      } else {
        print("Document does not exist in Firestore.");
      }
    } catch (e) {
      print("Error connecting to Firestore: $e");
      setState(() {
        firebaseConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey, // Access the static navigatorKey directly
      theme: ThemeData(primarySwatch: Colors.blue),
      home: auth.currentUser != null
          ? MyHomePage(forUpdate, version)
          : StartPage(version, forUpdate),
      initialRoute: '/start',
      routes: {
        '/login': (context) => Login(version, forUpdate),
        '/start': (context) => StartPage(version, forUpdate),
        '/reg': (context) => Register(version, forUpdate),
        '/home': (context) => MyHomePage(forUpdate, version),
        '/tasks': (context) => TaskPage(employId: 'GM003'), // Register the TaskPage route
      },
    );
  }
}
