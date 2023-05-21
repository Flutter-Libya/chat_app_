import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/welcome_screen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppStart(),
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id: (context) => ChatScreen(),
      },
    );
  }
}

class AppStart extends StatefulWidget {
  @override
  _AppStartState createState() => _AppStartState();
}

class _AppStartState extends State<AppStart> {
  final _auth = FirebaseAuth.instance;
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Please check your internet connection and try again.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      // Check if user is already signed in
      _checkSignInStatus();
    }
  }

  void _checkSignInStatus() async {
    // Retrieve the stored token from secure storage
    String? token = await _storage.read(key: 'authToken');

    // If a token exists, attempt to sign in with it
    if (token != null) {
      try {
        UserCredential userCredential =
        await _auth.signInWithCustomToken(token);

        if (userCredential.user != null) {
          // User is signed in, navigate to ChatScreen
          Navigator.pushReplacementNamed(context, ChatScreen.id);
        } else {
          // User is not signed in, navigate to WelcomeScreen
          Navigator.pushReplacementNamed(context, WelcomeScreen.id);
        }
      } catch (e) {
        print(e);
        // Error occurred while signing in, navigate to WelcomeScreen
        Navigator.pushReplacementNamed(context, WelcomeScreen.id);
      }
    } else {
      // No token found, navigate to WelcomeScreen
      Navigator.pushReplacementNamed(context, WelcomeScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
