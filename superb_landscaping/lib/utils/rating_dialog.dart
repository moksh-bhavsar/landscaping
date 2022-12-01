import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({Key? key}) : super(key: key);

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _stars = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text('Rate this job!'),
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          InkWell(
            child: Icon(
              Icons.star,
              color: _stars >= 1 ? Colors.orange : Colors.grey,
            ),
            onTap: () {
              setState(() {
                _stars = 1;
              });
            },
          ),
          InkWell(
            child: Icon(
              Icons.star,
              color: _stars >= 2 ? Colors.orange : Colors.grey,
            ),
            onTap: () {
              setState(() {
                _stars = 2;
              });
            },
          ),
          InkWell(
            child: Icon(
              Icons.star,
              color: _stars >= 3 ? Colors.orange : Colors.grey,
            ),
            onTap: () {
              setState(() {
                _stars = 3;
              });
            },
          ),
          InkWell(
            child: Icon(
              Icons.star,
              color: _stars >= 4 ? Colors.orange : Colors.grey,
            ),
            onTap: () {
              setState(() {
                _stars = 4;
              });
            },
          ),
          InkWell(
            child: Icon(
              Icons.star,
              color: _stars >= 5 ? Colors.orange : Colors.grey,
            ),
            onTap: () {
              setState(() {
                _stars = 5;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('CANCEL'),
          onPressed: Navigator.of(context).pop,
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop(_stars);
          },
        )
      ],
    );
  }
}
