import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe/provider/room_data_provider.dart';
import 'package:tic_tac_toe/widgets/custom_textfield.dart';

class WaitingLobby extends StatefulWidget {
  const WaitingLobby({super.key});

  @override
  State<WaitingLobby> createState() => _WaitingLobby();
}

class _WaitingLobby extends State<WaitingLobby>{
  late TextEditingController roomIdController;

  @override
  void initState() {
   super.initState();
   roomIdController = TextEditingController(
     text: Provider.of<RoomDataProvider>(context, listen: false).roomData['_id'],
   );
  }

  @override
  void dispose() {
    super.dispose();
    roomIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('En attente de votre adversaire'),
        const SizedBox(height: 20,),
        CustomTextField(controller: roomIdController, hintText: '', isReadOnly: true,),
      ],
    );
  }



}
