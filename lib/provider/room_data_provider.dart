import 'package:flutter/material.dart';

import '../models/player.dart';

class RoomDataProvider extends ChangeNotifier {
  Map<String, dynamic> _roomData = {};
  List<String> _displayElements = ['', '','', '','', '','', '',''];
  int _fillBoxes = 0;
  Player _player1 = Player(nickname:'', socketID:'', points:0.0, playerType:'X');
  Player _player2 = Player(nickname:'', socketID:'', points:0.0, playerType:'O');

    Map<String, dynamic> get roomData => _roomData;
    List<String> get displayElements => _displayElements;

    int get fillBoxes => _fillBoxes;
    Player get player1 => _player1;
    Player get player2 => _player2;

    void updateRoomData(Map<String, dynamic> roomData) {
      _roomData = roomData;
      notifyListeners();
    }

    void updatePlayer1(Map<String, dynamic> player1Data) {
      _player1 = Player.fromMap(player1Data);
      notifyListeners();
    }

  void updatePlayer2(Map<String, dynamic> player2Data) {
    _player2 = Player.fromMap(player2Data);
    notifyListeners();
  }

  void updateDisplayElements(int index, String choice) {
      _displayElements[index] = choice;
      _fillBoxes += 1;
      notifyListeners();
  }

  // playerType can't be empty
  Player getPlayerByPlayerType(String playerType) {
      return player1.playerType == playerType ? player1 : player2;
  }

  void clearBoard() {
      for(int i = 0; i < _displayElements.length; i++) {
        _displayElements[i] = '';
      }
      _fillBoxes = 0;
      notifyListeners();
  }
}