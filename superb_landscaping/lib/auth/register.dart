// ignore_for_file: avoid_print, prefer_const_constructors, unnecessary_brace_in_string_interps

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:superb_landscaping/models/user.dart';
import 'package:superb_landscaping/profile/profile_view.dart';
import 'package:superb_landscaping/utils/scaffold_snackbar.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

///
/// Registration page
///
///
///
class RegisterPage extends StatefulWidget {
  final String title = 'Registration';

  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  /// Form stuffs
  /// DATABASE STRUCTURE:
  /// user ->
  ///       Documents (uid) ->
  ///                         string firstName
  ///                         string lastName
  ///                         number rating
  ///                         string bio
  ///                         address (collection) ->
  ///                                               string street
  ///                                               string city
  ///                                               string country
  ///                         string posting (uid of post done via 'createPosting')
  ///
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          children: [
            Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ///
                      /// Email form
                      ///
                      _textField(_emailController, 'Email',
                          'Please enter an Email.', false),

                      ///
                      /// Password
                      _textField(_passwordController, 'Password',
                          'Please enter a password.', true),

                      ///
                      /// First name
                      ///
                      _textField(_nameController, 'First Name',
                          'Please enter your first name.', false),

                      ///
                      /// last name
                      ///
                      _textField(_surnameController, 'Last Name',
                          'Please enter your last name.', false),

                      ///
                      /// bio
                      ///
                      _textField(
                          _bioController, 'Bio', 'Please enter a bio.', false),

                      ///
                      /// Street
                      ///
                      _textField(_streetController, 'Street Address',
                          'Please enter your street address.', false),

                      ///
                      /// city
                      ///
                      _textField(_cityController, 'City',
                          'Please enter your city.', false),

                      ///
                      /// country
                      ///
                      _textField(_countryController, 'Country',
                          'Please enter your country.', false),

                      ///
                      /// register button
                      /// ** Takes user back to sign in page
                      ///
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        child: TextButton.icon(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await _register();
                            }
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text("Register"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _textField(
      TextEditingController c, String l, String e, bool isPassword) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(labelText: l),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return e;
        }
        return null;
      },
      obscureText: isPassword,
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _bioController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  ///
  /// Register function
  ///
  Future<void> _register() async {
    User? user;
    try {
      user = (await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ))
          .user;
    } on FirebaseAuthException catch (error) {
      ///
      /// These are the error codes that firebaseauth returns if registration
      /// throws errors
      ///
      /// Used them to handle user notif regarding the form field values
      ///
      print(
          '-----------------------------------------ERROR-------------------------- \n ${error}');
      String errorMessage;
      switch (error.code) {
        case "invalid-email":
          errorMessage = "Your email address is invalid.";
          break;
        case "weak-password":
          errorMessage = "Your password must be at least 6 characters long.";
          break;
        case "email-already-in-use":
          errorMessage = "User with this email already exists.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
      ScaffoldSnackbar.of(context).show(errorMessage);
    }

    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          LocalUser(
                  _nameController.text.trim(),
                  _surnameController.text.trim(),
                  _bioController.text.trim(),
                  _streetController.text.trim(),
                  _cityController.text.trim(),
                  _countryController.text.trim())
              .getDataMap());
      // Automatically signIn after registration
      ScaffoldSnackbar.of(context)
          .show('${user.email} created. Automatically signing you in...');
      if (await _signInWithEmailAndPassword()) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ProfilePage()));
      }
    }
  }

  Future<bool> _signInWithEmailAndPassword() async {
    try {
      bool authenticated = true;
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
