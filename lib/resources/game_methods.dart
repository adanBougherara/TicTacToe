import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tic_tac_toe/provider/room_data_provider.dart';

import '../models/player.dart';
import '../utils/utils.dart';

class GameMethods {
  void checkWinner(BuildContext context, Socket socketClient) {
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
    List<List<int>> winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];
    for (var combination in winningCombinations) {
      String firstSymbol = roomDataProvider.displayElements[combination[0]];
      if (firstSymbol.isEmpty) continue;

      if (combination.every((index) => roomDataProvider.displayElements[index] == firstSymbol)) {
        Player winner = roomDataProvider.getPlayerByPlayerType(firstSymbol);
        showGameDialog(context, '${winner.nickname} a gagné la partie !');
        socketClient.emit('winner', {
          'winnerSocketId': winner.socketID,
          'roomId': roomDataProvider.roomData['_id'],
        });
        return;
      }
    }
    if (roomDataProvider.fillBoxes == 9) {
      showGameDialog(context, 'Egalité !');
    }
  }

  void clearBoard(BuildContext context) {
    Provider.of<RoomDataProvider>(context, listen: false).clearBoard();
  }
}