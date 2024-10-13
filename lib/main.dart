import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardData {
  String frontImage;
  String backImage;
  bool isFaceUp = false;

  CardData({required this.frontImage, required this.backImage});
}

class GameModel extends ChangeNotifier {
  List<CardData> cards = [];
  List<int> flippedCards = [];
  bool _isProcessing = false;

  void initializeCards(int numPairs) {
    List<String> imageList = [
      'assets/jackofspades.png',
      'assets/queenofspades.png',
      'assets/kingofspades.png',
      'assets/aceofspades.png'
    ];

    numPairs = min(numPairs, imageList.length);
    for (int i = 0; i < numPairs; i++) {
      cards.addAll([
        CardData(frontImage: imageList[i], backImage: 'assets/card_back.png'),
        CardData(frontImage: imageList[i], backImage: 'assets/card_back.png'),
      ]);
    }

    cards.shuffle();
    notifyListeners();
  }

  void flipCard(int index) {
    if (_isProcessing || cards[index].isFaceUp) return;

    flippedCards.add(index);
    cards[index].isFaceUp = true;
    notifyListeners();

    if (flippedCards.length == 2) {
      _isProcessing = true;

      if (cards[flippedCards[0]].frontImage == cards[flippedCards[1]].frontImage) {
        flippedCards.clear();
        _isProcessing = false;
        notifyListeners();
      } else {
        Future.delayed(Duration(seconds: 1), () {
          cards[flippedCards[0]].isFaceUp = false;
          cards[flippedCards[1]].isFaceUp = false;
          flippedCards.clear();
          _isProcessing = false;
          notifyListeners();
        });
      }
    }
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameModel(),
      child: MaterialApp(
        home: MemoryGame(),
      ),
    ),
  );
}

class MemoryGame extends StatefulWidget {
  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  @override
  void initState() {
    super.initState();
    final gameModel = context.read<GameModel>();
    if (gameModel.cards.isEmpty) {
      gameModel.initializeCards(4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameModel = context.watch<GameModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Game'),
      ),
      body: GridView.count(
        crossAxisCount: 4,
        padding: EdgeInsets.all(16.0),
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        children: List.generate(gameModel.cards.length, (index) {
          return GestureDetector(
            onTap: () => gameModel.flipCard(index),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    gameModel.cards[index].isFaceUp
                        ? gameModel.cards[index].frontImage
                        : gameModel.cards[index].backImage,
                  ),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    color: Colors.black26,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
