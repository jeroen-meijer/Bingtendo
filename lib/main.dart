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
  String header = "Getting user...";
  FirebaseUser authUser;
  List<String> visibleTileIds = [];

  initializeUser() async {
    await FirebaseAuth.instance.signOut();
    FirebaseUser newUser = await FirebaseAuth.instance.currentUser();
    if (newUser == null) {
      newUser = await FirebaseAuth.instance.signInAnonymously();
      DocumentReference newUserDocument = Firestore.instance
          .collection(User.collectionName)
          .document(newUser.uid);
      List<DocumentSnapshot> newUserTileDocSnaps = (await Firestore.instance
              .collection(BingoTile.collectionName)
              .getDocuments())
          .documents;

      newUserTileDocSnaps.shuffle();
      int max =
          newUserTileDocSnaps.length >= 25 ? 25 : newUserTileDocSnaps.length;
      newUserTileDocSnaps = newUserTileDocSnaps.getRange(0, max).toList();

      List<DocumentReference> newUserTileDocRefs = [];
      for (var docSnap in newUserTileDocSnaps)
        newUserTileDocRefs.add(docSnap.reference);

      await newUserDocument
          .setData({BingoTile.collectionName: newUserTileDocRefs});

      newUserTileDocRefs
          .forEach((docRef) => visibleTileIds.add(docRef.documentID));
    } else {
      DocumentSnapshot userDoc = await Firestore.instance
          .collection(User.collectionName)
          .document(newUser.uid)
          .get();
      List
          .castFrom<dynamic, DocumentReference>(userDoc.data["tiles"])
          .forEach((docRef) => visibleTileIds.add(docRef.documentID));
    }

    setState(() {
      authUser = newUser;
      header = "ID: ${authUser.uid}";
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingAnimation = CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.red),
    );

    if (authUser == null) initializeUser();

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: Center(
            child: (authUser == null)
                ? loadingAnimation
                : StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection(BingoTile.collectionName)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return loadingAnimation;

                      List<DocumentSnapshot> visibleTiles = [];
                      for (var snap in snapshot.data.documents) {
                        if (visibleTileIds.contains(snap.documentID))
                          visibleTiles.add(snap);
                      }

                      BingoGrid grid = BingoGrid(
                              width: 5,
                              height: 5,
                              documents: visibleTiles);

                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(header),
                          Text(snapshot.data.documents[0].data["title"]),
                          grid,
                          Text("Bingos: ${grid.amountOfBingos}")
                        ],
                      );
                    },
                  )));
  }
}
