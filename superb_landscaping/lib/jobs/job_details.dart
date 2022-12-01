// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:superb_landscaping/utils/rating_dialog.dart';
import 'package:superb_landscaping/utils/scaffold_snackbar.dart';

final _auth = FirebaseAuth.instance;

class JobDetails extends StatefulWidget {
  const JobDetails({
    Key? key,
    required this.snap,
    required this.fromWhere,
  }) : super(key: key);
  final QueryDocumentSnapshot<Object?> snap;
  final String fromWhere;
  @override
  JobsDetailPageState createState() => JobsDetailPageState();
}

class JobsDetailPageState extends State<JobDetails> {
  Future<Location> getAddress() async {
    List<Location> locations =
        await locationFromAddress(widget.snap.get('street'));
    var first = locations.first;
    // ignore: avoid_print
    print("Locations:${first.toJson()}");
    return first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.snap.get("title")} job Details'),
        actions: getIconButton(widget.snap, widget.fromWhere),
      ),
      body: Container(
        margin: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 100,
                backgroundImage: Image.asset('assets/images/jobs.png').image,
              ),
              Card(
                color: Colors.white,
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      '${widget.snap.get("title")}',
                      style: TextStyle(
                          fontSize: 32,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      '${widget.snap.get("description")}',
                      maxLines: 7,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(),
                child: Text(
                  '- - - ${widget.snap.get("progress")} - - -',
                  maxLines: 7,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(),
                child: Text(
                  'Salary:\$${widget.snap.get("price")}',
                  maxLines: 7,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16))),
                child: SizedBox(
                  height: 220,
                  child: FutureBuilder<Location>(
                    future: getAddress(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      return ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: GoogleMap(
                            mapType: MapType.hybrid,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(snapshot.data!.latitude,
                                  snapshot.data!.longitude),
                              zoom: 14.4746,
                            ),
                            onMapCreated: (GoogleMapController controller) {},
                            markers: {
                              Marker(
                                  markerId: const MarkerId("1"),
                                  position: LatLng(snapshot.data!.latitude,
                                      snapshot.data!.longitude),
                                  infoWindow: InfoWindow(
                                      title: widget.snap.get('street')))
                            },
                          ));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> getIconButton(var snap, var fromWhere) {
    if (fromWhere == 'postings') {
      if (snap.get('progress') == 'Available') {
        return [
          IconButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Delete'),
                        content:
                            Text("Are you sure you want to delete this post?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection("jobs")
                                    .doc(widget.snap.id)
                                    .delete();
                                Navigator.of(context).pop();
                              },
                              child: Text('Yes'))
                        ],
                      )).then((value) => Navigator.of(context).pop()),
              icon: Icon(Icons.delete))
        ];
      } else if (snap.get('progress') == 'In progress') {
        return [
          IconButton(
              onPressed: () {
                ScaffoldSnackbar.of(context)
                    .show('Cannot delete a job in progress');
              },
              icon: Icon(
                Icons.delete_forever,
                color: Colors.white38,
              ))
        ];
      } else {
        return [
          IconButton(
              onPressed: () => showDialog(
                      context: context,
                      builder: (context) => RatingDialog()).then((value) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(snap.get('worker'))
                        .update({'rating': FieldValue.increment(value)});

                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(snap.get('worker'))
                        .update({'reviews': FieldValue.increment(5)});

                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(snap.get('worker'))
                        .update({
                      'credits': FieldValue.increment(snap.get('price'))
                    });

                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(_auth.currentUser!.uid)
                        .update({
                      'credits': FieldValue.increment(-snap.get('price'))
                    });
                    FirebaseFirestore.instance
                        .collection("jobs")
                        .doc(widget.snap.id)
                        .delete();
                    Navigator.of(context).pop();
                  }),
              icon: Icon(Icons.payments_outlined))
        ];
      }
    } else if (fromWhere == 'jobs') {
      return [
        IconButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("jobs")
                  .doc(widget.snap.id)
                  .update({'progress': 'Pending payment'});
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.check_circle_outline_outlined))
      ];
    } else {
      return [
        IconButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("jobs")
                  .doc(widget.snap.id)
                  .update({
                'worker': _auth.currentUser!.uid,
                'progress': 'In progress'
              });
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.post_add))
      ];
    }
  }
}
