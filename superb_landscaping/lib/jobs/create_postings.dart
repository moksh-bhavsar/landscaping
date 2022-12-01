// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:superb_landscaping/utils/scaffold_snackbar.dart';

final _auth = FirebaseAuth.instance;

class CreatePosting extends StatelessWidget {
  const CreatePosting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a post'),
      ),
      body: const PostingForm(),
    );
  }
}

class PostingForm extends StatefulWidget {
  const PostingForm({Key? key}) : super(key: key);

  @override
  _PostingFormState createState() => _PostingFormState();
}

class _PostingFormState extends State<PostingForm> {
  /// Form stuffs
  /// DATABASE STRUCTURE:
  /// Job ->
  ///       Documents (uid) ->
  ///                         string title
  ///                         string description
  ///                         number price
  ///                         string street
  ///                         string city
  ///                         string country
  ///                         string poster (uid of current user)
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
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
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please name the job';
                      }
                      return null;
                    },
                  ),

                  ///
                  /// Description
                  ///
                  TextFormField(
                    controller: _aboutController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please describe the job';
                      }
                      return null;
                    },
                  ),

                  ///
                  /// Price
                  ///
                  TextFormField(
                    controller: _price,
                    decoration: const InputDecoration(labelText: 'Pricing'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price for the job';
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
                      icon: const Icon(Icons.approval_rounded),
                      label: const Text("Post"),
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
    _price.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _title.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    //  jobs -> used for adding new post
    var jobs = FirebaseFirestore.instance.collection('jobs');

    ///
    /// .add query call
    ///
    /// adds a new document into the jobs collection
    /// updates the user (currentuser) to store this job's uid in ['posting']
    ///
    try {
      jobs.add({
        'title': _title.text,
        'poster': _auth.currentUser!.uid,
        'description': _aboutController.text,
        'price': int.tryParse(_price.text),
        'street': _streetController.text,
        'city': _cityController.text,
        'country': _countryController.text,
        'worker': '',
        'progress': 'Available',
      }).then((value) {
        Navigator.of(context).pop();
      });
    } catch (error) {
      print(
          '-----------------------------------------ERROR-------------------------- \n $error');
      ScaffoldSnackbar.of(context).show("An unexpected error has occured.");
    }
  }
}


/*
Widget addImage() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    alignment: Alignment.center,
    child: TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.camera_alt),
      label: const Text("Add an Image"),
    ),
  );
}
*/
