const express = require("express");
const path = require("path");
const app = express();
const port = process.env.PORT || 3000;
const mongoose = require('mongoose');
const httpServer = require("http").createServer(app);
const { Server } = require("socket.io");
const Room = require('./models/room');
const playerSchema = require('./models/player');
const io = new Server(httpServer);

app.use(express.static(path.join(__dirname, "public-flutter")));

app.get("*", (req, res) => {
    res.sendFile(path.join(__dirname, "public-flutter/index.html"));
});



// middleware
app.use(express.json());

const DB = process.env.DB_URI;

io.on("connection", (socket) => {
    console.log("Connexion au socket !");
    socket.on('createRoom', async ({ nickname }) => {
        console.log(nickname);
        //create a room
        try {
            let room = new Room();
            let player = {
                socketID: socket.id,
                nickname: nickname,
                playerType: 'X',
            };
            room.players.push(player);
            room.turn = player;
            room = await room.save(); // saving in mongoDB
            console.log(room);
            const roomId = room._id.toString();

            socket.join(roomId);

            io.to(roomId).emit('createRoomSuccess', room);
        } catch (error) {
            console.error(error);
        }
    });

    socket.on('joinRoom', async ({ nickname, roomId }) => {
        try {
            if (!roomId.match(/^[0-9a-fA-F]{24}$/)) {
                socket.emit('errorOccurred', 'Aucune salle n\'a été trouvée.');
                return;
            }
            let room = await Room.findById(roomId);
            if (room.isJoin) {
                let player = {
                    nickname,
                    socketID: socket.id,
                    playerType: 'O',
                };
                socket.join(roomId);
                room.players.push(player);
                room.isJoin = false;
                room = await room.save();
                io.to(roomId).emit('joinRoomSuccess', room);
                io.to(roomId).emit('updatePlayers', room.players);
                io.to(roomId).emit('updateRoom', room);

            } else {
                socket.emit('errorOccurred', 'La salle est close');
            }
        } catch (error) {
            console.error(error);
        }
    });

    socket.on('tap', async ({ index, roomId }) => {
        try {
            let room = await Room.findById(roomId);
            let choice = room.turn.playerType; // X or O
            room.turnIndex ^= 1;
            room.turn = room.players[room.turnIndex];
            room = await room.save();
            io.to(roomId).emit('tapped', {
                index,
                choice,
                room,
            });

        } catch (error) {
            console.error(error);
        }
    });

    socket.on('winner', async ({ winnerSocketId, roomId }) => {
        try {
            let room = await Room.findById(roomId);
            winner = room.players.find((player) => player.socketID == winnerSocketId);
            winner.points += 1;
            room = await room.save();

            if (winner.points >= room.maxRounds) {
                io.to(roomId).emit('endGame', winner);
            }
            else {
                io.to(roomId).emit('pointIncrease', winner);
            }
        } catch (error) {
            console.error(error);
        }
    });
});

mongoose.connect(DB).then(() => {
    console.log("Connexion réussie à la base de donnée");
}).catch((error) => {
    console.log(`Erreur lors de la connexion à la base de donnée: ${error}`);
});

httpServer.listen(port, '0.0.0.0', (error) => {
    if (error) {
        console.error(`Erreur los du démarrage du server: ${error}`);
    }
    else {
        console.log(`Le serveur est lancé sur le port ${port}`);
    }

});
