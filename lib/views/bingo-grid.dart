import 'package:bingtendo/views/bingo-tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BingoGrid extends StatefulWidget {
  BingoGrid({this.width, this.height, this.tiles, this.documents}) {
    this.height ??= width;

    if (this.documents != null)
      this.tiles = _generateBingoTilesFromDocuments(documents);

    this.tiles[12].isFree = true;
  }

  int width;
  int height;
  List<BingoTile> tiles;
  List<DocumentSnapshot> documents;

  int get amountOfBingos {
    int result = 0;

    // horizontally
    // debugPrint("--HORIZONTALLY--");
    for (var i = 0; i < 5; i++) {
      int index = i * 5;
      // debugPrint("-----");

      bool isBingo = true;
      for (var tile in tiles.getRange(index, index + 5)) {
        // debugPrint("Tile: ${tile.title}, isChecked: ${tile.isChecked}");
        if (tile.isFree == false && tile.isChecked == false) isBingo = false;
      }
      // debugPrint("isBingo: $isBingo");
      if (isBingo) result++;
    }

    //vertically
    // debugPrint("--VERTICALLY--");
    for (var i = 0; i < 5; i++) {
      bool isBingo = true;
      List<BingoTile> verticalTiles = [];
      verticalTiles.add(tiles[i]);
      verticalTiles.add(tiles[i+5]);
      verticalTiles.add(tiles[i+10]);
      verticalTiles.add(tiles[i+15]);
      verticalTiles.add(tiles[i+20]);

      for (var tile in verticalTiles) {
        // debugPrint("Tile: ${tile.title}, isChecked: ${tile.isChecked}");
        if (tile.isFree == false && tile.isChecked == false) isBingo = false;
      }
      // debugPrint("isBingo: $isBingo");
      if (isBingo) result++;
    }

    debugPrint("Amount of bingo's: $result");

    return result;
  }

  static List<BingoTile> _generateBingoTilesFromDocuments(
      List<DocumentSnapshot> documents) {
    List<BingoTile> result = [];
    documents.forEach((snap) => result.add(BingoTile.fromSnapshot(snap)));
    return result;
  }

  @override
  _BingoGridState createState() => _BingoGridState();
}

class _BingoGridState extends State<BingoGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: widget.width,
      childAspectRatio: 1.0,
      children: widget.tiles,
    );
  }
}
