import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simplechatapp/models/message.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ConversationSnippet {
  final String id;
  final String conversationID;
  final String lastMessage;
  final String name;
  final String image;
  final int unseenCount;
  final Timestamp timestamp;

  ConversationSnippet(
      {this.id, this.conversationID, this.image, this.name, this.unseenCount, this.lastMessage, this.timestamp});

  factory ConversationSnippet.fromFirestore(DocumentSnapshot _snapshot) {



    var _data = _snapshot.data;
    String _conversationID = _data["conversationID"];
    final key = encrypt.Key.fromUtf8(_conversationID.substring(0,16));
    final iv = encrypt.IV.fromUtf8(_conversationID.substring(0,16));
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    String decrypted = "";
    if(_data["lastMessage"] != null) {
      final plainText = _data["lastMessage"];
      decrypted = encrypter.decrypt64(plainText, iv: iv);
    }

    return ConversationSnippet(
        id: _snapshot.documentID,
        conversationID: _data["conversationID"],
        unseenCount: _data["unseenCount"],
        lastMessage: _data["lastMessage"] != null ? decrypted : "",
        name: _data["name"],
        image: _data["image"],
        timestamp: _data["timestamp"] != null ? _data["timestamp"] : null);
  }
}

class Conversation {
  final String id;
  final List members;
  final List<Message> messages;
  final String ownerID;

  Conversation({this.id, this.members, this.ownerID, this.messages});

  factory Conversation.fromFirestore(DocumentSnapshot _snapshot, String _conversationID) {

    final key = encrypt.Key.fromUtf8(_conversationID.substring(0,16));
    final iv = encrypt.IV.fromUtf8(_conversationID.substring(0,16));
    final encrypter = encrypt.Encrypter(encrypt.AES(key));


    var _data = _snapshot.data;
    List _messages = _data["messages"];
    if (_messages != null) {
      _messages = _messages.map(
        (_m) {
          if( _m["type"] == "text"){
            final plainText = _m["message"];
            final decrypted = encrypter.decrypt64(plainText, iv: iv);
            return Message(
                type: MessageType.Text,
                content: decrypted,
                timestamp: _m["timestamp"],
                senderID: _m["senderID"]);
          }
          else{
            return Message(
                type: MessageType.Image,
                content:  _m["message"],
                timestamp: _m["timestamp"],
                senderID: _m["senderID"]);
          }
        },
      ).toList();
    } else {
      _messages = [];
    }
    return Conversation(
        id: _snapshot.documentID, members: _data["members"], ownerID: _data["ownerID"], messages: _messages);
  }
}
