// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superb_landscaping/auth/login.dart';
import 'package:superb_landscaping/jobs/create_postings.dart';
import 'package:superb_landscaping/jobs/jobs_page.dart';
import 'package:superb_landscaping/auth/payment_form.dart';
import 'package:superb_landscaping/profile/edit_profile.dart';
import 'package:superb_landscaping/utils/scaffold_snackbar.dart';

import '../auth/register_business.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

///
/// Profile page
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
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text("User Profile"),
            actions: [
              IconButton(
                  onPressed: () {
                    _paymentForm(context);
                  },
                  icon: Icon(Icons.credit_card))
            ],
          ),

          ///
          /// Drawer
          /// Could use a bit of a styling touch up

          drawer: Drawer(
            child: ListView(children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: SizedBox(
                  height: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            Image.asset('assets/images/avatar.png').image,
                      ),
                    ],
                  ), //Added an image and header
                ),
              ),
              // Made the list items left aligned
              Container(
                margin: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreatePosting()));
                      },
                      icon: Icon(CupertinoIcons.pencil),
                      label: Text('Create a posting')),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfile()));
                      },
                      icon: Icon(CupertinoIcons.profile_circled),
                      label: Text('Edit profile')),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Login()));
                        ScaffoldSnackbar.of(context)
                            .show('Successfully signed out.');
                      },
                      icon: Icon(Icons.exit_to_app),
                      label: Text('Sign out')),
                ),
              ),
            ]),
          ),

          body: Profile(),
        ),
        onWillPop: () async {
          return false;
        });
  }

  _paymentForm(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentForm(),
      ),
    );
  }
}

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final user = FirebaseFirestore.instance
      .collection('users')
      .doc(_auth.currentUser!.uid);

  @override
  void initState() {
    super.initState();
    user.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: user.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData && snapshot.data.exists) {
            Map<String, dynamic> documentFields =
                snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              padding: EdgeInsets.all(10.0),
              children: [
                Center(
                  child: CircleAvatar(
                    child: Text(documentFields['firstName'][0]),
                  ),
                ),

                ///
                /// User name section
                /// could use some styling touch ups
                ///
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${documentFields['firstName']} ${documentFields['lastName']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                ),

                ///
                /// Rating section
                ///
                /// Working well
                ///
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: documentFields['rating'] /
                                    documentFields['reviews'] >=
                                0.2
                            ? Colors.yellow
                            : Colors.grey,
                      ),
                      Icon(
                        Icons.star,
                        color: documentFields['rating'] /
                                    documentFields['reviews'] >=
                                0.4
                            ? Colors.yellow
                            : Colors.grey,
                      ),
                      Icon(
                        Icons.star,
                        color: documentFields['rating'] /
                                    documentFields['reviews'] >=
                                0.6
                            ? Colors.yellow
                            : Colors.grey,
                      ),
                      Icon(
                        Icons.star,
                        color: documentFields['rating'] /
                                    documentFields['reviews'] >=
                                0.75
                            ? Colors.yellow
                            : Colors.grey,
                      ),
                      Icon(
                        Icons.star,
                        color: documentFields['rating'] /
                                    documentFields['reviews'] >=
                                0.85
                            ? Colors.yellow
                            : Colors.grey,
                      ),
                    ],
                  ),
                ),

                ///
                /// Address section of profile
                /// could use some styling touch ups
                ///
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${documentFields['address']['Street']}, ${documentFields['address']['City']},  ${documentFields['address']['Country']}',
                        style: TextStyle(),
                      ),
                    ],
                  ),
                ),

                ///
                /// Bio section of profile
                /// could use some styling touch ups
                ///
                Card(
                  child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Credits: ${documentFields['credits']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.green[800]),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(color: Colors.black))),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'About',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              '\t\t\t${documentFields['bio']}',
                              style: TextStyle(fontSize: 12),
                              textAlign: TextAlign.justify,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(color: Colors.black))),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            getBusiness((documentFields['business'])),
                          ])),
                ),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ///
                      /// Current posting section of Profile
                      ///
                      /// At the moment, working but could use
                      /// some clean up.
                      ///
                      Expanded(
                          child: Card(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => JobsPage(
                                                fromWhere: 'postings')));
                                  },
                                  icon: Icon(Icons.post_add),
                                  label: Text('View Current posts')),
                            ],
                          ),
                        ),
                      )),

                      Expanded(
                          child: Card(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              checkBusiness(documentFields['business'])
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  Widget getBusiness(var businessId) {
    final business =
        FirebaseFirestore.instance.collection('business').doc(businessId);
    return StreamBuilder(
        stream: business.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData && snapshot.data.exists) {
            Map<String, dynamic> documentFields =
                snapshot.data!.data() as Map<String, dynamic>;
            return Container(
              padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
              child: Column(
                children: [
                  Text(
                    documentFields['company'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.blue[800]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    documentFields['phone'].toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(documentFields['about']),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        documentFields['street'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        documentFields['city'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        documentFields['country'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      )
                    ],
                  )
                ],
              ),
            );
          } else {
            return Text('No Business linked.');
          }
        });
  }

  Widget checkBusiness(var businessId) {
    final business =
        FirebaseFirestore.instance.collection('business').doc(businessId);
    return StreamBuilder(
        stream: business.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData && snapshot.data.exists) {
            return Container(
              padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
              child: Column(
                children: [
                  TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => JobsPage(
                                      fromWhere: 'lookup',
                                    )));
                      },
                      icon: Icon(Icons.playlist_add_outlined),
                      label: Text('Look for jobs')),
                  TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => JobsPage(
                                      fromWhere: 'jobs',
                                    )));
                      },
                      icon: Icon(Icons.work),
                      label: Text('Current jobs')),
                ],
              ),
            );
          } else {
            return TextButton.icon(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterBusiness()));
                },
                icon: Icon(Icons.add_business),
                label: Text('Register your business'));
          }
        });
  }
}
