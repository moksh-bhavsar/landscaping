// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:superb_landscaping/profile/profile_view.dart';
import 'package:superb_landscaping/auth/register.dart';
import 'package:superb_landscaping/utils/scaffold_snackbar.dart';

///
/// First screen of app
///
class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Superb Landscaping"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: const LoginWidget(),
    );
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  ///
  /// Form stuff for log in
  ///
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  User? user;

  ///
  /// Somewhat jank? code here
  /// need to check if widget is mounted or else error is thrown
  /// might work more on it later
  ///
  @override
  void initState() {
    _auth.userChanges().listen((event) {
      if (mounted) {
        setState(() => user = event);
      }
    });
    super.initState();
  }

  ///
  /// login with email widget
  /// currently working ok
  ///
  /// CONTAINS JANK CODE
  /// -- ON ANDROID A WEIRD ERROR IS FOUND --
  /// on android there is a "back" button that is not a part of the app.
  /// when this button is pressed, weird navigation can occur
  ///   -> If you sign in, then sign out, even though nav.pop is called, you
  ///       can still navigate back to the page where you need to be logged in.
  ///
  /// Currently no clue how to fix properly.
  /// Needs more research
  ///
  /// ---------------------- ADHOC FIX------------------------
  /// Wrapped the page up in a 'Willpopscope' that disables
  /// the back button. Did this on the profile page as well to
  /// disable the user from going back to the login page without
  /// signing out.
  ///
  ///
  @override
  Widget build(BuildContext context) {
    //ADHOC FIX here
    return WillPopScope(
        child: ListView(
          padding: const EdgeInsets.all(10.0),
          children: [
            Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      loginImage(), //Scroll to bottom of file to see code
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        alignment: Alignment.center,
                        child: const Text(
                          'Sign in with Email and Password',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (String? value) {
                          if (value!.isEmpty) return 'Please enter an Email';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        validator: (String? value) {
                          if (value!.isEmpty) return 'Please enter some text';
                          return null;
                        },
                        obscureText: true,
                      ),
                      Container(
                          padding: const EdgeInsets.only(top: 16),
                          alignment: Alignment.center,
                          child: TextButton.icon(
                            label: const Text('Sign in'),
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                bool isAuth =
                                    await _signInWithEmailAndPassword();
                                if (!isAuth) {
                                  _emailController.clear();
                                  _passwordController.clear();
                                } else {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProfilePage()));
                                }
                              }
                            },
                          )),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        child: const Text(
                          'New User? Register now!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterPage()));
                        },
                        icon: const Icon(Icons.app_registration),
                        label: const Text('Register'),
                      ),
                    ],
                  )),
            ),
          ],
        ),
        onWillPop: () async {
          return false;
        });
  }

  ///
  /// Attempt at fixing some jank code
  /// does not do anything impactful at the moment
  ///
  @override
  void dispose() {
    _auth.userChanges().listen((event) {}).cancel();
    super.dispose();
  }

  ///
  /// sign in with email call
  ///
  /// working
  ///
  Future<bool> _signInWithEmailAndPassword() async {
    try {
      bool authenticated = true;
      final User user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ))
          .user!;
      ScaffoldSnackbar.of(context).show('${user.email} signed in');
      return authenticated;
    } catch (e) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Unable to Sign In"),
              content: Text("Incorrect Email or Password"),
              actions: [
                ElevatedButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
      return false;
    }
  }
}

Widget loginImage() {
  return Container(
    alignment: Alignment.center,
    child: Container(
      width: 200.0,
      height: 200.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          image: DecorationImage(
              image: AssetImage(
                "assets/images/login_shovel.png",
              ),
              fit: BoxFit.cover)),
    ),
  );
}
