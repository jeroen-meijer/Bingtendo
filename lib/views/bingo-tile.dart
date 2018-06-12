import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BingoTile extends StatefulWidget {
  static final String collectionName = "tiles";

  BingoTile(
      {this.reference, this.isFree: false, this.isChecked: false, this.title}) {
    this.isChecked = (this.isFree) ? true : this.isChecked;
  }

  DocumentReference reference;
  bool isFree;
  bool isChecked;
  String title;

  static Future<List<BingoTile>> getAllOptions() async =>
      (await Firestore.instance
              .collection(BingoTile.collectionName)
              .getDocuments())
          .documents
          .map((snap) => BingoTile.fromSnapshot(snap));

  static List<BingoTile> generateStubs(int amount) {
    List<BingoTile> result = [];

    for (var i = 0; i < amount; i++) {
      result.add(BingoTile(
          isFree: (i == 12),
          isChecked: ((i + 1) % 4 == 0),
          title: i.toString()));
    }

    return result;
  }

  @override
  _GridTileState createState() => _GridTileState();

  static BingoTile fromSnapshot(DocumentSnapshot snap) {
    bool checked = false;
    if (snap.data["isChecked"] != null) checked = snap.data["isChecked"];
    
    return BingoTile(
      reference: snap.reference,
      isChecked: checked,
      title: snap.data["title"],
    );
  }

  static Future<BingoTile> fromReference(DocumentReference ref) async {
    return fromSnapshot(await ref.get());
  }
}

class _GridTileState extends State<BingoTile> {
  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: Card(
        color: (widget.isFree)
            ? Colors.blueAccent
            : (widget.isChecked) ? Colors.green : Colors.red,
        child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                (widget.isFree) ? "Gratis" : widget.title,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
