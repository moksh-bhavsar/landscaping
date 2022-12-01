// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:superb_landscaping/jobs/job_details.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({Key? key, required this.fromWhere}) : super(key: key);
  final String fromWhere;
  @override
  JobsPageState createState() => JobsPageState();
}

class JobsPageState extends State<JobsPage> {
  @override
  Widget build(BuildContext context) {
    //Getting data from database collection
    CollectionReference<Map<String, dynamic>> jobs =
        FirebaseFirestore.instance.collection('jobs');

    // Jobs view
    return Scaffold(
      appBar: AppBar(
        title: Text('Jobs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: jobs.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //Loop through each snapshot to get a job
            Iterable<QueryDocumentSnapshot<Object?>> doc = snapshot.data!.docs;

            // Check from where the nav.push was done
            if (widget.fromWhere == 'postings') {
              doc = snapshot.data!.docs.where((element) =>
                  element.get('poster') ==
                  FirebaseAuth.instance.currentUser!.uid);
            } else if (widget.fromWhere == 'jobs') {
              doc = snapshot.data!.docs.where((element) =>
                  element.get('worker') ==
                  FirebaseAuth.instance.currentUser!.uid);
            } else {
              doc = snapshot.data!.docs.where((element) =>
                  element.get('poster') !=
                      FirebaseAuth.instance.currentUser!.uid &&
                  element.get('worker') == '');
            }
            return ListView.builder(
                itemCount: doc.length,
                itemBuilder: (context, index) {
                  //Add an item of each snapshot to a list
                  QueryDocumentSnapshot<Object?> snap = doc.elementAt(index);
                  print('==' + doc.elementAt(index).data().toString());
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        print('Tap 0');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => JobDetails(
                                    snap: snap, fromWhere: widget.fromWhere)));
                      },
                      child: Card(
                        shadowColor: (snap.get('progress') == 'Pending payment')
                            ? Colors.red
                            : (snap.get('progress') == 'In progress')
                                ? Colors.green
                                : Colors.blue,
                        elevation: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  print('Tap 1');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => JobDetails(
                                              snap: snap,
                                              fromWhere: widget.fromWhere)));
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: 16, top: 16, bottom: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      // Text('${doc[index].get('city')},${doc[index].get('country')}'),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${snap.get("title")}, ${snap.get('description')}',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          margin: EdgeInsets.only(right: 16),
                                          child: Text(
                                            '${snap.get('city')}, ${doc.elementAt(index).get('country')}',
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 18),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                      // Text(doc[index].get('title')),
                                    ],
                                  ),
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          } else {
            return LinearProgressIndicator();
          }
        },
      ),
    );
  }
}
