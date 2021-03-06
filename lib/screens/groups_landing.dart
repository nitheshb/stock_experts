import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stock_experts/controllers/firebaseController.dart';
import 'package:stock_experts/pages/groupProfile1.dart';
import 'package:stock_experts/screens/conversation.dart';
import 'package:stock_experts/screens/createGroup.dart';
import 'package:stock_experts/screens/main_screen.dart';
import 'package:stock_experts/util/NotifyJson.dart';
import 'package:stock_experts/util/auth.dart';
import 'package:stock_experts/util/data.dart';
import 'package:stock_experts/util/state.dart';
import 'package:stock_experts/util/state_widget.dart';
import 'package:stock_experts/widgets/displayChatsMenuItem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class GroupsLandingScreen extends StatefulWidget {
  GroupsLandingScreen(
      {Key key,
      this.uId,
      this.uEmailId,
      this.followingGroupsLocal,
      this.followingGroupsReadCountLocal})
      : super(key: key);
  final String uId, uEmailId;
  List followingGroupsLocal, followingGroupsReadCountLocal;
  @override
  _GroupsLandingScreenState createState() => _GroupsLandingScreenState();
}

class _GroupsLandingScreenState extends State<GroupsLandingScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _tabController;
  StateModel appState;
  List waitingGroups = [],
      approvedGroups = [],
      myOwnGroups = [], followingGroupsP = [],
      followingGroups = [],
      primeGroups = [];

  String _searchTerm;
  bool allowGroupCreation = true;
  List widgetCountCheck = [];

  List NotifyData = [];
  List searchLists = [];
  int selTabIndex;
  var shimmer = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 0, length: 2);

    getlocalPrime_OwnGroups();
    selTabIndex = 0;


    // new Future.delayed(Duration.zero, () {
    //   loopFollowingGroup(followingGroupsP);
    // });
  }

  void _toggleTab() {
    _tabController.animateTo(1);
  }

  getlocalPrime_OwnGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    approvedGroups = await prefs.getStringList('approvedPrimeGroups');
       myOwnGroups = await prefs.getStringList('myOwnGroups_pref');
       followingGroupsP = await prefs.getStringList('followingGroups_pref');

       if(myOwnGroups == null){
         myOwnGroups = [];
         
       }

       List addFollowMyOwnGroups =[...followingGroupsP, ...myOwnGroups];

 await loopFollowingGroup(addFollowMyOwnGroups);
    print('local true by swetan1 ${addFollowMyOwnGroups}');
  }


  void updateInformation(String information) {}
  loopFollowingGroup(dataArray) {
    dataArray.forEach((data) {
      realTime(data);
    });
  }

  realTime(id) {
    if (id == null) {
      return;
    }
    DatabaseReference postsRef =
        FirebaseDatabase.instance.reference().child("Notify").child(id);
    postsRef.onValue.listen((event) async {
      var snap = event.snapshot;

      // var keys = snap.value.keys;
      var data = snap.value;

      // NotifyData.clear();
      if (data != null) {
        //code for disabaling shiimmer effect
        // setState(() {
        //   shimmer = false;
        // });

        NotifyData.removeWhere((item) => item['t'] == '${data['t']}');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var msgReadCountvar = prefs.getInt("${"qoX1aNeMcKgl69UCntgq"}");
    
        data['chatId'] = id;
        data['readCount'] = msgReadCountvar ?? 0;
        NotifyData.add(data);

        print("notify is ${NotifyData}");
      } else {
        //code for shimmer effect

        double containerWidth = 280;
        double containerHeight = 15;
        //code for shimmer effect
        ListView.builder(
          itemCount: 6,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Shimmer.fromColors(
                  highlightColor: Colors.white,
                  baseColor: Colors.grey[300],
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 7.5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: containerHeight,
                              width: containerWidth,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 5),
                            Container(
                              height: containerHeight,
                              width: containerWidth,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 5),
                            Container(
                              height: containerHeight,
                              width: containerWidth * 0.75,
                              color: Colors.grey,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  period: Duration(milliseconds: 2),
                ));
          },
        );
      }
  
      setState(() {});
    });
  }

  getMsgReadCount(chatId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var msgReadCountvar = prefs.getInt("${chatId}");
    return msgReadCountvar ?? 1000;
  }

Widget messagesTabDisplay(context, userId){
  return SingleChildScrollView(
            child: Column(children: <Widget>[
              Visibility(
                visible: myOwnGroups.length> 0,
                child: 
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0,0,0),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Created Groups ",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Color(0xff3A4276),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                    ListView.builder(
              itemCount: NotifyData.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 8, bottom: 8),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index){
               
                return 
                myOwnGroups.contains(NotifyData[index]['chatId']) ?
                recentChatDetailsCard(NotifyData[index],userId,0,) :
                Container();
              },
            ),
                    ],
                  ),
                ),
              ),
              ),
        
            
            
         Padding(
           padding: const EdgeInsets.only(left:8.0, top: 8),
           child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Following Groups ",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Color(0xff3A4276),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
         ),
        followingGroupsP.length == 0
        ? noGroupsFolllowed()
        :  ListView.builder(
              itemCount: NotifyData.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 8),
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index){
var searchGroupForReadCount;
                try {
                    searchGroupForReadCount = widgetCountCheck.firstWhere(
                  (data) => data['chatId'] == NotifyData[index]['chatId']);
                } catch (e) {
                  print('error is ${e}');
                  searchGroupForReadCount ={'readCount': 0};
                }
                
                return
                (followingGroupsP.contains(NotifyData[index]['chatId'])) ?
                 recentChatDetailsCard(NotifyData[index],userId,searchGroupForReadCount['readCount'] ?? 0,):Container();
              },
            )
            ]),
          );
}

Widget followGroupsTabDisplay(context, userId){
  return   SingleChildScrollView(
            child: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Win more under guidance of Experts ",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Color(0xff3A4276),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Follow to receive expert messages",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Color(0xff3A4276),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchTerm = val;
                          print('search term ${_searchTerm}');
                        });
                      },
                      style: new TextStyle(color: Colors.black, fontSize: 20),
                      decoration: new InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey[400], width: 2)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey[400], width: 2)),
                          // border: InputBorder.none,
                          hintText: 'Search Group Name....',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Color(0xff3A4276),
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: const Icon(Icons.search, color: Colors.black))),
                ),
              ),

            
              // Display results as per search string mentioned in above text field
              StreamBuilder(
                stream: searchGroupsQuery(_searchTerm),
                builder: (context, snapshot) {
                  // display default img/ placeholder when no results are available
                  if (!snapshot.hasData)  {
                    return Column(
                      children: <Widget>[
                        SizedBox(height: 30),
                        Align(
                          alignment: Alignment.center,
                          child: new Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/searchFind.png'),
                                    fit: BoxFit.fill)),
                          ),
                        ),
                        SizedBox(height: 30),
                        Align(
                          alignment: Alignment.topLeft,
                          child: new Container(
                            height: 160,
                            // width: 160,
                            child: Column(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.center,
                                  child: Text("Use above search bar to find",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Color(0xff3A4276),
                                        fontWeight: FontWeight.w500,
                                      )),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  } else if (snapshot.hasData) {
                 return   snapshot.data['payload'].length  == 0
        ? Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 60),
                          new Container(
                            height: MediaQuery.of(context).size.height / 3,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/searchFind.png'),
                                    fit: BoxFit.cover)),
                          ),
                          new Text('No Matched Data Found'),
                        ],
                      ),
                  )
        :  ListView.builder(
              itemCount: snapshot.data['payload'].length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 8),
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index){
                DocumentSnapshot ds = snapshot.data;
                // Todo:  check y this followersA was declared 
              var followersA = [];
                return
                InkWell(

                  // This is card Widget
                  child:  buildApplication(
                                          ds['payload'][index]['logo'],
                                          ds['payload'][index]['title'],
                                          ds['payload'][index]['ownerName'],
                                          ds['payload'][index]['category'],
                                          followingGroupsP.contains(ds['payload'][index]['chatId']),
                                          ds['payload'][index]['chatId'],
                                          userId
                                      ),
                  onTap:(){
                                        Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => Profile3(
                                              title: ds['payload'][index]['title'],
                                              avatarUrl: ds['payload'][index]['logo'],
                                              categories: ds['payload'][index]['category'],
                                              following: followersA.contains(widget.uId),
                                              chatId: ds['payload'][index]['chatId'],
                                              userId: userId,
                                              followers: ds['payload'][index]['followers'] ?? [],
                                              groupOwnerName: ds['payload'][index]['ownerName'] ?? '',
                                              feeDetails: ds['payload'][index]['FeeDetails'] ?? [],
                                              seasonRating: ds['payload'][index]['seasonRating'] ?? 'NA',
                                              thisWeekRating: ds['payload'][index]['thisWeekRating'] ?? 'NA',
                                              lastWeekRating: ds['payload'][index]['lastWeekRating'] ?? 'NA',
                                              followingGroupsLocal: followingGroupsP)),
                                      );
                  },
                  
                );
               
 
              },
            );
            

            // 
                    // return CustomScrollView(
                    //   shrinkWrap: true,
                    //   slivers: <Widget>[
                    //     SliverList(
                    //       delegate: SliverChildBuilderDelegate((context, index) {
                    //         DocumentSnapshot ds = snapshot.data;
                    //         var followersA = [];
                    //         return Container(
                    //             child: InkWell(
                    //                 onTap: () {
                    //                   Navigator.push(context,
                    //                       MaterialPageRoute(builder: (context) => Profile3(
                    //                           title: ds['payload'][index]['title'],
                    //                           avatarUrl: ds['payload'][index]['logo'],
                    //                           categories: ds['payload'][index]['category'],
                    //                           following: followersA.contains(widget.uId),
                    //                           chatId: ds['payload'][index]['chatId'],
                    //                           userId: userId,
                    //                           followers: ds['payload'][index]['followers'] ?? [],
                    //                           groupOwnerName: ds['payload'][index]['ownerName'] ?? '',
                    //                           feeDetails: ds['payload'][index]['FeeDetails'] ?? [],
                    //                           seasonRating: ds['payload'][index]['seasonRating'] ?? 'NA',
                    //                           thisWeekRating: ds['payload'][index]['thisWeekRating'] ?? 'NA',
                    //                           lastWeekRating: ds['payload'][index]['lastWeekRating'] ?? 'NA',
                    //                           followingGroupsLocal: followingGroupsP)),
                    //                   );
                    //                   },
                    //                 child: Padding(
                    //                   padding: const EdgeInsets.only(
                    //                       left: 8.0, right: 8.0),
                    //                   child: buildApplication(
                    //                       ds['payload'][index]['logo'],
                    //                       ds['payload'][index]['title'],
                    //                       ds['payload'][index]['ownerName'],
                    //                       ds['payload'][index]['category'],
                    //                       followingGroupsP.contains(ds['payload'][index]['chatId']),
                    //                       ds['payload'][index]['chatId'],
                    //                       userId
                    //                   ),
                    //                 ),
                    //             ),
                    //         );
                    //         },
                    //         childCount: snapshot.data['payload'].length ?? 0,
                    //       ),
                    //     ),
                    //   ],
                    // );
                  }
                  
                },
              ),
            ]),
          );
}

  Widget recentChatDetailsCard(NotifyData, userId, alreadyReadCount){
return InkWell(
                onTap: () async {
                  var snap = await FirebaseController.instanace.getChatOwnerId(NotifyData['chatId']);
                  var chatId = approvedGroups.contains(NotifyData['chatId'])
                          ? "${NotifyData['chatId']}PGrp"
                          : "${NotifyData['chatId']}";
                  final information = await Navigator.push(
                    context, MaterialPageRoute(
                      builder: (context) => Conversation(
                          followingGroupsLocal: followingGroupsP,
                          groupFullDetails: [],
                          chatId: chatId,
                          groupSportCategory: [],
                          chatOwnerId: snap['o'],
                          groupTitle: NotifyData['t'] ?? "",
                          groupLogo: NotifyData['i'],
                          followers: [],
                          approvedGroupsJson: [],
                          userId: widget.uId,
                          senderMailId: widget.uEmailId,
                          chatType: "",
                          waitingGroups: waitingGroups,
                          approvedGroups: [],
                          followersCount: snap['c'] ?? 0,
                          msgFullCount: NotifyData['c'],
                          msgFullPmCount: NotifyData['pc'],
                          msgReadCount: 0),
                    ),
                  );
                  updateInformation(information);
                },
                child: ChatMenuIcon(
                  user: userId,
                  dp: "${NotifyData['i']}",
                  groupName: "${NotifyData['t']}",
                  isOnline: true,
                  counter: "${NotifyData['c'] - alreadyReadCount}",
                  // counter: 0,
                  msg: "${approvedGroups.contains(NotifyData['chatId']) ? NotifyData['pm'] : NotifyData['m']}",
                  time: "${""}",
                  amiPrime: approvedGroups.contains(NotifyData['chatId']),
                  amiOwner: myOwnGroups.contains(NotifyData['chatId']),
                ),
              );
  }

  Widget noGroupsFolllowed() {
    return Align(
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height / 4.5),
            new Container(
              height: MediaQuery.of(context).size.height / 5.5,
              child: Icon(
                FontAwesomeIcons.star,
                color: Colors.grey,
                size: 70,
              ),
            ),
            Column(
              children: <Widget>[
                new Text("No groups subscribed yet",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Color(0xff3A4276),
                      fontWeight: FontWeight.w500,
                    )),
                SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    _toggleTab();
                  },
                  child: new Text("Subscribe to a group",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      )),
                )
              ],
            ),
          ],
        ));
  }

  Widget groupSearViewRealDB(_searchTerm) {
    return FutureBuilder(
        future: FirebaseDatabase.instance
            .reference()
            .child("NameSearch")
            .orderByChild("childNode")
            .startAt('$_searchTerm')
            .endAt('${_searchTerm}\uF7FF')
            .once(),
        builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
          if (!snapshot.hasData)
            return Column(
              children: <Widget>[
                SizedBox(height: 30),
                Align(
                  alignment: Alignment.center,
                  child: new Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/searchFind.png'),
                            fit: BoxFit.fill)),
                  ),
                ),
                SizedBox(height: 30),
                Align(
                  alignment: Alignment.topLeft,
                  child: new Container(
                    height: 160,
                    // width: 160,
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Type to find a group...!",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );

          if (snapshot.hasData) {
            searchLists.clear();
            Map<dynamic, dynamic> values = snapshot.data.value;
            values.forEach((key, values) {
              searchLists.add(values);
            });
            return new ListView.builder(
                shrinkWrap: true,
                itemCount: searchLists.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Name: " + searchLists[index]["n"]),
                      ],
                    ),
                  );
                });
          }
          return CircularProgressIndicator();
        });
  }

 




  void _showBasicsFlash({
    Duration duration,
    flashStyle = FlashStyle.floating,
    BuildContext context,
    String messageText,
  }) {
    showFlash(
      context: context,
      duration: duration,
      builder: (context, controller) {
        return Flash(
          controller: controller,
          style: flashStyle,
          boxShadows: kElevationToShadow[4],
          horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            message: Text('$messageText'),
          ),
        );
      },
    );
  }

  List<Widget> _buildSelectedOptions(dynamic values) {
    List<Widget> selectedOptions = [];

    if (values != null) {
      values.forEach((item) {
        selectedOptions.add(
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 6,
            ),
            child: Center(
              child: Text(
                "${item['categoryName'] ?? item}",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        );
      });
    }

    return selectedOptions;
  }

  searchGroupsQuery(query) {
    if (query != null && ((query.length == 1))) {
      var followGroupState =
          FirebaseController.instanace.searchResultsByName(query);
      return followGroupState;
    } else {
      return;
    }
  }

  readCountLooper(array) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    widgetCountCheck = [];

    followingGroupsP.forEach((chatId) {
      var readCountLocal = prefs.getInt("${chatId}");
      var payload = {'chatId': chatId, 'readCount': readCountLocal ?? 0};
      widgetCountCheck.add(payload);
    });
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    //followingGroups =  ['nQ4T04slkEdANneRb4k62'];
    appState = StateWidget.of(context).state;
    final userId = appState?.firebaseUserAuth?.uid ?? '';
    final email = appState?.firebaseUserAuth?.email ?? '';
    final followGroupState = appState.followingGroups;
    final phoneNumber = appState.user.phoneNumber;
    var data = Auth.getFollowingGroups;

    readCountLooper(followingGroupsP);

    if (widget.followingGroupsReadCountLocal == null) {
      widget.followingGroupsReadCountLocal = [];
    }

    // getUserData(userId);

    if (followingGroupsP == null) {
      followingGroupsP = followGroupState;
    }

    // followingGroupsP.forEach((data){
    //   realTime(data);
    //     print('data@@ ${data}');
    //   });

    return Scaffold(
        appBar: AppBar(
          title: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).accentColor,
            labelColor: Theme.of(context).accentColor,
            unselectedLabelColor: Theme.of(context).textTheme.caption.color,
            isScrollable: false,
            labelStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: Color(0xff3A4276),
              fontWeight: FontWeight.w400,
            ),
            onTap: (index) {
              setState(() {
                selTabIndex = index;
              });
            },
            tabs: <Widget>[
              Tab(
                text: "Messages",
              ),
              Tab(
                text: "Follow Experts",
              ),
            ],
          ),
        ),
        body: TabBarView(
            controller: _tabController,
            children: <Widget>[

          // first tab
        messagesTabDisplay(context,userId),


          // second tab
        followGroupsTabDisplay(context,userId)
        ]),
        floatingActionButton: Visibility(
          // this floating button should be visiable only in Follow Experts Tab
         visible: selTabIndex == 1,
          child: FloatingActionButton(
            child: Container(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            onPressed: () async {

              if (allowGroupCreation) {
                //
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateGroupProfile(
                        primaryButtonRoute: "/home",
                        followingGroupsLocal: followingGroupsP),
                  ),
                );
              } else {
                _showBasicsFlash(
                    context: context,
                    duration: Duration(seconds: 4),
                    messageText: 'Limit Reached.Unfollow any group to proceed');
              }
            },
          ),
        ));
  }
// UnFollow Group Function

  unFollowFun(chatId, userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.get('FCMToken');

    setState(() {
      followingGroupsP.remove(chatId);
      prefs.setStringList('followingGroups_pref', followingGroupsP);

    });

    await Navigator.of(context).pushAndRemoveUntil(
        new MaterialPageRoute(
          builder: (BuildContext context) => MainScreen(
              userId: userId,
              followingGroupsLocal: followingGroupsP),
        ),
        (Route<dynamic> route) => false);
  }

// Follow Group Function
  followFun(chatId, userId) async {
    // make an entry in db as joinedGroups
    try {
      //  this is for token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userToken = prefs.get('FCMToken');

      prefs.setInt("${chatId}", 00000);

      if (followingGroupsP.length < 9) {
        FirebaseController.instanace.followGroup(chatId, userId, userToken);

        setState(() {
          followingGroupsP.add(chatId);
          prefs.setStringList('followingGroups_pref', followingGroupsP);
        });
        await Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(
              builder: (BuildContext context) => MainScreen(
                  userId: userId,
                  followingGroupsLocal: followingGroupsP),
            ),
            (Route<dynamic> route) => false);
      } else {
        _showBasicsFlash(
            context: context,
            duration: Duration(seconds: 4),
            messageText: 'Overall max 9 group can be followed...!');
      }
    } catch (e) {
      _showBasicsFlash(
          context: context,
          duration: Duration(seconds: 4),
          messageText: 'error at following ${e}');
    }
  }

  Widget buildApplication(
      logoUrl, title, owner, categories, isFollow, chatId, userId) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
      margin: EdgeInsets.symmetric(vertical: 2),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.all(
      //     Radius.circular(10),
      //   ),
      // ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Color(0xffF1F3F6)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 70,
                width: 65,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(logoUrl),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${title[0].toUpperCase() + title.substring(1)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.userAlt,
                          size: 10,
                          color: Colors.black,
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          "${owner[0].toUpperCase() + owner.substring(1)}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: <Widget>[
                        Wrap(
                          spacing: 4.0, // gap between adjacent chips
                          runSpacing: 1.0, // gap between lines
                          children: _buildSelectedOptions(categories),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
              InkWell(
                onTap: () {
                  if (isFollow) {
                    unFollowFun(chatId, userId);
                  } else {
                    followFun(chatId, userId);
                  }
                },
                child: Container(
                  height: 35,
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: isFollow
                        ? LinearGradient(
                            colors: [
                              Colors.grey,
                              Colors.grey,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.topRight,
                          )
                        : LinearGradient(
                            colors: [
                              Color(0xff0072ff),
                              Color(0xff00d4ff),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.topRight,
                          ),
                    // color: isFollow ? Colors.grey :Colors.blueAccent,
                    borderRadius: BorderRadius.all(
                      Radius.circular(6),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isFollow ? "UnFollow" : "Follow",
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
