import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplechatapp/models/conversation.dart';
import 'package:simplechatapp/models/message.dart';
import 'package:simplechatapp/providers/auth_provider.dart';
import 'package:simplechatapp/services/cloud_storage_service.dart';
import 'package:simplechatapp/services/db_service.dart';
import 'package:simplechatapp/services/media_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsPage extends StatefulWidget {
  final String conversationID;
  final String receiverID;
  final String receiverImage;
  final String receiverName;

  ChatsPage({this.conversationID, this.receiverName, this.receiverID, this.receiverImage});

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  var _deviceHeight;
  var _deviceWidth;
  AuthProvider _auth;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _messageText = '';
  ScrollController _listViewController = ScrollController();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(31, 31, 31, 1.0),
        title: Text(widget.receiverName),
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationPageUI(),
      ),
    );
  }

  Widget _conversationPageUI() {
    return Builder(
      builder: (context) {
        _auth = Provider.of<AuthProvider>(context);
        return Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            _messageListView(),
            Align(alignment: Alignment.bottomCenter, child: _messageField(context))
          ],
        );
      },
    );
  }

  Widget _messageListView() {
    return Container(
      height: _deviceHeight * 0.75,
      child: StreamBuilder<Conversation>(
          stream: DBService.instance.getConversation(widget.conversationID),
          builder: (context, snapshot) {
            if (_listViewController.hasClients) {
              Timer(Duration(milliseconds: 50), () {
                _listViewController.jumpTo(_listViewController.position.maxScrollExtent);
              });
            }
            var _conversationData = snapshot.data;
            if (_conversationData != null) {
              if (_conversationData.messages.length != 0) {
                return ListView.builder(
                  controller: _listViewController,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  itemCount: _conversationData.messages.length,
                  itemBuilder: (context, index) {
                    var message = _conversationData.messages[index];
                    bool isUserMessage = message.senderID == _auth.user.uid;
                    return _messageListViewChild(isUserMessage, message);
                  },
                );
              } else {
                return Center(child: Text("Start chatting!"));
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Widget _messageListViewChild(bool _isUserMessage, Message _message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: _isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          _isUserMessage ? Container() : _userImageWidget(),
          SizedBox(width: 5),
          _message.type == MessageType.Text
              ? _textMessageBubble(_isUserMessage, _message.content, _message.timestamp)
              : _imageMessageBubble(_isUserMessage, _message.content, _message.timestamp),
        ],
      ),
    );
  }

  Widget _userImageWidget() {
    double _imageRadius = _deviceHeight * 0.05;
    return Container(
      height: _imageRadius,
      width: _imageRadius,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(500),
          image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(widget.receiverImage))),
    );
  }

  Widget _textMessageBubble(bool _isUserMessage, String _message, Timestamp _timestamp) {
    return Container(
      height: _deviceHeight * 0.1,
      width: _deviceWidth * 0.75,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration:
          BoxDecoration(color: _isUserMessage ? Colors.blue : Colors.white60, borderRadius: BorderRadius.circular(30)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(_message),
          Text(
            timeago.format(_timestamp.toDate()),
            style: TextStyle(color: Colors.white70),
          )
        ],
      ),
    );
  }

  Widget _imageMessageBubble(bool _isUserMessage, String _imageURL, Timestamp _timestamp) {
    DecorationImage _image = DecorationImage(image: NetworkImage(_imageURL), fit: BoxFit.cover);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: _isUserMessage ? Colors.blue : Colors.white60,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            height: _deviceHeight * 0.50,
            width: _deviceWidth * 0.50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: _image,
            ),
          ),
          SizedBox(height: 10),
          Text(
            timeago.format(_timestamp.toDate()),
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _messageField(BuildContext context) {
    return Container(
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(color: Color.fromRGBO(43, 43, 43, 1), borderRadius: BorderRadius.circular(100)),
      margin: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.02, vertical: _deviceHeight * 0.02),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[_messageTextField(), _imageMessageButton(context), _sendMessageButton(context)],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.55,
      child: TextFormField(
        validator: (value) {
          if (value.length == 0) return "Please enter a message";
          return null;
        },
        onChanged: (value) {
          _formKey.currentState.save();
          setState(() {
            _messageText = value;
          });
        },
        cursorColor: Colors.white,
        decoration: InputDecoration(border: InputBorder.none, hintText: "Type a message"),
      ),
    );
  }

  Widget _sendMessageButton(BuildContext context) {
    return Container(
      height: _deviceHeight * 0.1,
      width: _deviceWidth * 0.15,
      child: IconButton(
        icon: Icon(Icons.send),
        color: Colors.white,
        onPressed: () {
          if (_formKey.currentState.validate()) {
            DBService.instance.sendMessage(
                widget.conversationID,
                Message(
                  content: _messageText,
                  timestamp: Timestamp.now(),
                  senderID: _auth.user.uid,
                  type: MessageType.Text,
                ));
            _formKey.currentState.reset();
            Timer(Duration(milliseconds: 50), () {
              _listViewController.jumpTo(_listViewController.position.maxScrollExtent);
            });
          }
        },
      ),
    );
  }

  Widget _imageMessageButton(BuildContext context) {
    return Container(
      height: _deviceHeight * 0.1,
      width: _deviceWidth * 0.15,
      child: IconButton(
        icon: Icon(Icons.image),
        color: Colors.white,
        onPressed: () async {
          var _image = await MediaService.instance.getImageFromLibrary();
          if (_image != null) {
            var _result = await CloudStorageService.instance.uploadMediaMessage(_auth.user.uid, _image);
            var _imageURL = await _result.ref.getDownloadURL();
            await DBService.instance.sendMessage(
                widget.conversationID,
                Message(
                  content: _imageURL,
                  type: MessageType.Image,
                  senderID: _auth.user.uid,
                  timestamp: Timestamp.now(),
                ));
          }
        },
      ),
    );
  }
}
