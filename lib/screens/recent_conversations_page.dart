import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplechatapp/models/conversation.dart';
import 'package:simplechatapp/providers/auth_provider.dart';
import 'package:simplechatapp/screens/chats_page.dart';
import 'package:simplechatapp/services/db_service.dart';
import 'package:simplechatapp/services/navigation_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:encrypt/encrypt.dart' as encrypt;
class RecentConversationsPage extends StatefulWidget {
  @override
  _RecentConversationsPageState createState() => _RecentConversationsPageState();
}

class _RecentConversationsPageState extends State<RecentConversationsPage> {
  var _deviceHeight;
  var _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      height: _deviceHeight,
      width: _deviceWidth,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationsListView(),
      ),
    );
  }

  _conversationsListView() {
    return Builder(
      builder: (context) {
        var _auth = Provider.of<AuthProvider>(context);
        return Container(
          height: _deviceHeight,
          width: _deviceWidth,
          child: StreamBuilder<List<ConversationSnippet>>(
              stream: DBService.instance.getUserConversations(_auth.user.uid),
              builder: (context, snapshot) {
                if (snapshot.data == null)
                  return Center(child: CircularProgressIndicator());
                else {
                  List _data = snapshot.data;
                  _data.removeWhere((element) => element.timestamp == null);
                  return _data.length != 0
                      ? ListView.builder(
                          itemCount: _data.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                NavigationService.instance.navigateToRoute(MaterialPageRoute(builder: (context) {
                                  return ChatsPage(
                                    conversationID: _data[index].conversationID,
                                    receiverID: _data[index].id,
                                    receiverName: _data[index].name,
                                    receiverImage: _data[index].image,
                                  );
                                }));
                              },
                              title: Text(_data[index].name),
                              subtitle: _data[index].lastMessage.startsWith(("https://firebasestorage.googleapis.com"))
                                  ? Text("Image 📷", style: TextStyle(fontWeight: FontWeight.bold))
                                  : Text(_data[index].lastMessage),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(_data[index].image))),
                              ),
                              trailing: listTileTrailing(_data[index].timestamp),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                          "No conversations yet!",
                          style: TextStyle(color: Colors.white30),
                        ));
                }
              }),
        );
      },
    );
  }

  Widget listTileTrailing(Timestamp timestamp) {
    return Text(timeago.format(timestamp.toDate()), style: TextStyle(fontSize: 15));
  }
}
