import 'package:bingtendo/views/bingo-tile.dart';
import 'package:flutter/material.dart';

class BingoGrid extends StatefulWidget {

  BingoGrid({this.width, this.height, this.tiles}) {
    this.height ??= width;
  }

  int width;
  int height;
  List<BingoTile> tiles;

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