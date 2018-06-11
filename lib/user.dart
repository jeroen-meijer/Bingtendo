import 'package:bingtendo/views/bingo-tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  static final collectionName = "users";

  User({this.reference, this.tiles});

  DocumentReference reference;
  List<BingoTile> tiles;
}