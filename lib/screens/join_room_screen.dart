import 'package:flutter/material.dart';

import '../resources/socket_methods.dart';
import '../responsive/responsive.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_textfield.dart';

class JoinRoomScreen extends StatefulWidget {
  static String routeName = '/join-room';
  const JoinRoomScreen({
    super.key,
  });

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _gameIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final SocketMethods _socketMethods = SocketMethods();

  @override
  void initState() {
    super.initState();
    _socketMethods.joinRoomSuccessListener(context);
    _socketMethods.errorOccurredListener(context);
    _socketMethods.updatePlayersListener(context);
  }
  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _gameIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: Responsive(
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CustomText(
                    shadows: [Shadow(
                      blurRadius: 40,
                      color: Colors.blue,
                    )],
                    text: 'Rejoindre une salle',
                    fontSize: 65),
                SizedBox(height: size.height * 0.08),
                CustomTextField(controller: _nameController, hintText: 'Entrer votre pseudo',),
                const SizedBox(height: 20),
                CustomTextField(controller: _gameIdController, hintText: 'Entrer l\'ID de la partie',),
                SizedBox(height: size.height * 0.045,),
                CustomButton(onTap: () => _socketMethods.joinRoom(_nameController.text, _gameIdController.text), text: 'Rejoindre'),
              ],
            ),
          ),
        )
    );
  }
}