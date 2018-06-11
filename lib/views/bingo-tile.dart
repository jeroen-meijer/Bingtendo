import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BingoTile extends StatefulWidget {
  static final String collectionName = "tiles";

  BingoTile(
      {this.isFree: false, this.isChecked: false, this.title, this.submitters});

  bool isFree;
  bool isChecked;
  String title;
  List<String> submitters;
  //TODO: (@jeroen-meijer) Add image.

  static Future<List<BingoTile>> getAllOptions() async =>
      (await Firestore.instance
              .collection(BingoTile.collectionName)
              .getDocuments())
          .documents
          .map((snap) => BingoTile.fromSnapshot(snap));

  static List<BingoTile> generateStubs(int amount) {
    List<BingoTile> result = [];

    for (var i = 0; i < amount; i++) {
      bool checked = ((i + 1) % 3 == 0);
      bool free = ((i + 1) % 5 == 0);

      result.add(BingoTile(
        isFree: free,
        isChecked: checked,
        title: i.toString(),
        submitters: [i.toString(), (i + 5).toString()],
      ));
    }

    return result;
  }

  @override
  _GirdTileState createState() => _GirdTileState();

  static fromSnapshot(DocumentSnapshot snap) {
    List<String> submitters = List.castFrom<dynamic, String>(snap.data["submitters"]);
    return BingoTile(
                isFree: snap.data["isFree"],
                isChecked: snap.data["isChecked"],
                submitters: submitters,
                title: snap.data["title"],
              );
  }
}

class _GirdTileState extends State<BingoTile> {
  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: Card(
        color: Colors.red,
        child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(widget.title),
              (widget.isFree) ? Text("isFree") : Container(),
              (widget.isChecked) ? Text("isChecked") : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
