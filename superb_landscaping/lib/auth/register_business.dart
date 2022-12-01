// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:superb_landscaping/utils/scaffold_snackbar.dart';

final _auth = FirebaseAuth.instance;

class RegisterBusiness extends StatelessWidget {
  const RegisterBusiness({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register your business'),
      ),
      body: const BusinessForm(),
    );
  }
}

class BusinessForm extends StatefulWidget {
  const BusinessForm({Key? key}) : super(key: key);

  @override
  _BusinessFormState createState() => _BusinessFormState();
}

class _BusinessFormState extends State<BusinessForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _companyName = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ListView(
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
                  /// TITLE
                  ///
                  TextFormField(
                    controller: _companyName,
                    decoration:
                        const InputDecoration(labelText: 'Company name'),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please name your company';
                      }
                      return null;
                    },
                  ),

                  ///
                  /// Description
                  ///
                  TextFormField(
                    controller: _aboutController,
                    decoration: const InputDecoration(labelText: 'About'),
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
                  ),

                  ///
                  /// Phone number
                  ///
                  ///

                  TextFormField(
                    controller: _phoneNumber,
                    decoration: const InputDecoration(
                        labelText: 'Company Phone number'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your company phone number';
                      }
                      return null;
                    },
                  ),

                  ///
                  /// Street
                  ///
                  TextFormField(
                    controller: _streetController,
                    decoration: const InputDecoration(
                        labelText: 'House number and Street Name'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Street address';
                      }
                      return null;
                    },
                  ),

                  ///
                  /// City
                  ///
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your City';
                      }
                      return null;
                    },
                  ),

                  ///
                  /// Country
                  ///
                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(labelText: 'Country'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Country';
                      }
                      return null;
                    },
                  ),

                  ///
                  /// Push post button
                  ///
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _post();
                        }
                      },
                      icon: const Icon(Icons.add_business),
                      label: const Text("Register business"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _aboutController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _companyName.dispose();
    _phoneNumber.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    print('in post');
    //  jobs -> used for adding new post
    var business = FirebaseFirestore.instance.collection('business');
    //  user -> used to update current user document field ['posting']
    var user = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid);

    ///
    /// .add query call
    ///
    /// adds a new document into the jobs collection
    /// updates the user (currentuser) to store this job's uid in ['posting']
    ///
    try {
      business.add({
        'company': _companyName.text,
        'worker': _auth.currentUser!.uid,
        'about': _aboutController.text,
        'street': _streetController.text,
        'city': _cityController.text,
        'country': _countryController.text,
        'phone': int.tryParse(_phoneNumber.text)
      }).then((value) {
        user.update({'business': value.id});
        user.update({'isWorker': 'true'});
        Navigator.of(context).pop();
      });
    } catch (error) {
      print(
          '-----------------------------------------ERROR-------------------------- \n $error');
      ScaffoldSnackbar.of(context).show("An unexpected error has occured.");
    }
  }
}
