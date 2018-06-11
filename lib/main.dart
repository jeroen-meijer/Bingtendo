import 'package:bingtendo/user.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bingtendo/views/bingo-grid.dart';
import 'package:bingtendo/views/bingo-tile.dart';

void main() => runApp(new BingtendoApp());

class BingtendoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Bingtendo',
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home: new HomePage(title: 'Bingtendo'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  String header = "";
  FirebaseUser currentUser;

  initializeUser() async {
    FirebaseUser newUser = await FirebaseAuth.instance.currentUser();
    if (newUser == null) {
      newUser = await FirebaseAuth.instance.signInAnonymously();
      DocumentReference newUserDocument = Firestore.instance
          .collection(User.collectionName)
          .document(newUser.uid);
      List<DocumentSnapshot> docSnaps = (await Firestore.instance
              .collection(BingoTile.collectionName)
              .getDocuments())
          .documents;

      List<DocumentReference> newTiles = [];
      for (var doc in docSnaps) {
        newTiles.add(doc.reference);
      }

      newTiles.shuffle();
      int max = newTiles.length >= 25 ? 25 : newTiles.length;
      newTiles = newTiles.getRange(0, max).toList();

      await newUserDocument.setData({BingoTile.collectionName: newTiles});
    }
    setState(() => currentUser = newUser);
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingAnimation = CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.red),
    );

    if (currentUser == null) initializeUser();

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: Center(
          //TODO: (@jeroen-meijer) Change to tiles collection.
            child: (currentUser == null)
                ? loadingAnimation
                : StreamBuilder<List<DocumentSnapshot>>(
                    stream: Firestore.instance
                        .collection(User.collectionName)
                        .document(currentUser.uid)
                        .snapshots()
                        .asyncMap((snap) async {
                      if (snap.data != null)
                        debugPrint(
                            snap.data[BingoTile.collectionName].toString());
                      List<DocumentSnapshot> tiles = <DocumentSnapshot>[];
                      for (DocumentReference docRef
                          in snap.data[BingoTile.collectionName]) {
                        tiles.add(await docRef.get());
                      }
                      return tiles;
                    }),
                    builder: (context, tilesnapshot) {
                      if (!tilesnapshot.hasData) return loadingAnimation;

                      List<BingoTile> children = [];
                      tilesnapshot.data.forEach(
                          (snap) => children.add(BingoTile.fromSnapshot(snap)));

                      return GridView.count(
                        crossAxisCount: 5,
                        children: children,
                      );
                    },
                  )));
  }
}
