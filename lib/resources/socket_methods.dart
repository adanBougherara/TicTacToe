import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tic_tac_toe/provider/room_data_provider.dart';
import 'package:tic_tac_toe/resources/game_methods.dart';
import 'package:tic_tac_toe/resources/socket_client.dart';
import 'package:tic_tac_toe/screens/game_screen.dart';

import '../utils/utils.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;
  // EMITS
  void createRoom(String nickname) {
    if (nickname.isNotEmpty) {
      _socketClient.emit('createRoom', {
        'nickname': nickname,
      });
    }
  }

  void joinRoom(String nickname, String roomId) {
    if (nickname.isNotEmpty && roomId.isNotEmpty) {
      _socketClient.emit('joinRoom', {
        'nickname': nickname,
        'roomId': roomId,
      });
    }
  }

  void tapGrid(int index, String roomId, List<String> displayElements) {
    if (displayElements[index] == '') {
      _socketClient.emit('tap', {
        'index': index,
        'roomId': roomId,
      });
    }
  }

  // LiSTENERS
  void createRoomSuccessListener(BuildContext context) {
    _socketClient.on('createRoomSuccess', (room) => {
      Provider.of<RoomDataProvider>(context, listen: false).updateRoomData(room),
      Navigator.pushNamed(context, GameScreen.routeName),
    });
  }

  void joinRoomSuccessListener(BuildContext context) {
    _socketClient.on('joinRoomSuccess', (room) => {
      Provider.of<RoomDataProvider>(context, listen: false).updateRoomData(room),
      Navigator.pushNamed(context, GameScreen.routeName),
    });
  }

  void errorOccurredListener(BuildContext context) {
    _socketClient.on('errorOccurred', (data) => {
      showSnackBar(context, data),
    });
  }

  void updatePlayersListener(BuildContext context) {
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
    _socketClient.on('updatePlayers', (playersData) => {
      roomDataProvider.updatePlayer1(playersData[0]),
      roomDataProvider.updatePlayer2(playersData[1]),
    });
  }

  void updateRoomListener(BuildContext context) {
    _socketClient.on('updateRoom', (room) => {
      Provider.of<RoomDataProvider>(context, listen: false).updateRoomData(room),
    });
  }
  void tappedListener(BuildContext context){
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
    _socketClient.on('tapped', (data) => {
      roomDataProvider.updateDisplayElements(data['index'], data['choice']),
      roomDataProvider.updateRoomData(data['room']),
      GameMethods().checkWinner(context, _socketClient),
    });
  }

  void pointIncreaseListener(BuildContext context) {
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
    _socketClient.on('pointIncrease', (player) {
      if (roomDataProvider.player1.socketID == player['socketID']) {
        roomDataProvider.updatePlayer1(player);
      }
      else {
        roomDataProvider.updatePlayer2(player);
      }
    });
  }

  void endGameListener(BuildContext context) {
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
    _socketClient.on('endGame', (player) {
      showGameDialog(context, '${player['nickname']} a gagné la partie !');
      Navigator.popUntil(context, (route) => false);
    });
  }

}