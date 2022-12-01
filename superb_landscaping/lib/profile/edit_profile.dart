import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:superb_landscaping/auth/login.dart';
import 'package:superb_landscaping/utils/scaffold_snackbar.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final users = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid);

    Future<void> updateUser() async {
      try {
        if (_nameController.text != '') {
          users.update({'firstName': _nameController.text});
        }
        if (_surnameController.text != '') {
          users.update({'lastName': _surnameController.text});
        }
        if (_bioController.text != '') {
          users.update({'bio': _bioController.text});
        }
        if (_streetController.text != '') {
          users.update({'Street': _streetController.text});
        }
        if (_cityController.text != '') {
          users.update({'City': _cityController.text});
        }
        if (_countryController.text != '') {
          users.update({'Country': _countryController.text});
        }
      } catch (e) {
        // ignore: avoid_print
        print("Failed to update user: $e");
      } finally {
        // ignore: avoid_print
        print("User Updated");
      }
    }

    //NEED TO FIGURE OUT HOW TO DELETE USER EMAIL AND PASSWORD
    Future<void> deleteUser() async {
      await FirebaseFirestore.instance
          .collection('jobs')
          .where('poster', isEqualTo: _auth.currentUser!.uid)
          .get()
          .then((snapshot) async {
        for (DocumentSnapshot ds in snapshot.docs) {
          await ds.reference.delete();
        }
      });

      await users
          .delete()
          // ignore: avoid_print
          .then((value) => print("User Deleted"))
          // ignore: avoid_print
          .catchError((error) => print("Failed to user: $error"));
    }

    _showAlertDialog(BuildContext context) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:
                  const Text('Are you sure you want to delete your account?'),
              content: const Text('This will permanently erase your data.'),
              actions: [
                TextButton(
                    onPressed: () async {
                      await deleteUser();
                      //DELETE USER EMAIL/PASSWORD
                      FirebaseAuth.instance.currentUser!.delete();
                      FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()));
                      ScaffoldSnackbar.of(context)
                          .show('Account has been deleted.');
                    },
                    child: const Text('yes')),
                TextButton(
                    onPressed: () {
                      return Navigator.pop(context, "No");
                    },
                    child: const Text('no')),
              ],
            );
          });
    }

    return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile'), actions: [
          IconButton(
              onPressed: () {
                _showAlertDialog(context);
              },
              // onPressed: () async {
              //   await deleteUser();
              //   //DELETE USER EMAIL/PASSWORD
              //   FirebaseAuth.instance.currentUser!.delete();

              //   Navigator.pop(context);
              //   Navigator.push(
              //       context, MaterialPageRoute(builder: (context) => Login()));
              //   ScaffoldSnackbar.of(context).show('Account has been deleted.');
              // },
              icon: const Icon(Icons.delete_forever))
        ]),
        body: StreamBuilder(
            stream: users.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData && snapshot.data.exists) {
                Map<String, dynamic> documentFields =
                    snapshot.data!.data() as Map<String, dynamic>;

                return ListView(children: [
                  Form(
                      key: _formKey,
                      child: Card(
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _textField(
                                      documentFields['firstName'],
                                      _nameController,
                                      'First Name',
                                      'Please enter your first name.'),
                                  _textField(
                                      documentFields['lastName'],
                                      _surnameController,
                                      'Last Name',
                                      'Please enter your last name.'),
                                  _textField(
                                      documentFields['bio'],
                                      _bioController,
                                      'Bio',
                                      'Please enter your bio.'),
                                  _textField(
                                      documentFields['address']['Street'],
                                      _streetController,
                                      'Street Address',
                                      'Please enter your Street Address.'),
                                  _textField(
                                      documentFields['address']['City'],
                                      _cityController,
                                      'City',
                                      'Please enter your city.'),
                                  _textField(
                                      documentFields['address']['Country'],
                                      _countryController,
                                      'Country',
                                      'Please enter your country.'),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    alignment: Alignment.center,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        updateUser();
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(Icons.update),
                                      label: const Text("Update"),
                                    ),
                                  )
                                ],
                              ))))
                ]);
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                  ],
                );
              }
            }));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _nameController.dispose();
    _surnameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }
}

_textField(var init, TextEditingController c, String l, String e) {
  return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: TextFormField(
        controller: c..text = init,
        decoration:
            InputDecoration(border: const OutlineInputBorder(), labelText: l),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return e;
          }
          return null;
        },
      ));
}
