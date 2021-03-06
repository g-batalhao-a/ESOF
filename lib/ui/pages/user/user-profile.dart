part of '../../../main.dart';

class AccountPage extends StatefulWidget {
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;
  final translator;
  final bool needPop = false;

  AccountPage(this._storage, this._speechProvider, this.translator);
  @override
  State<AccountPage> createState() => new _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: _buildBar(context),
          body: Stack(alignment: Alignment.center, children: <Widget>[
            CustomPaint(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height),
                painter: HeaderCurvedContainer()),
            TabBarView(
              children: [
                _buildAccount(),
                _buildHistory(),
                _buildYourConferences()
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      title: new Text("InstantWords"),
      centerTitle: true,
      bottom: TabBar(
        tabs: [
          Tab(text: "Account"),
          Tab(text: "History"),
          Tab(text: "Conferences"),
        ],
      ),
    );
  }

  Widget _buildAccount() {
    return new Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 75.0, bottom: 50.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
                context.watch<FireAuth>().currentUser.photoURL ??
                    "https://eu.ui-avatars.com/api/?name=" +
                        context.watch<FireAuth>().currentUser.displayName),
            radius: 100,
          ),
        ),
        _buildText(
            "Username", context.watch<FireAuth>().currentUser.displayName),
        _buildText("Email", context.watch<FireAuth>().currentUser.email),
        _buildButton()
      ],
    );
  }

  Widget _buildHistory() {
    return new Container(
      padding: EdgeInsets.only(top: 30, right: 15, left: 15),
      child: new Center(
        child: new Column(
          children: <Widget>[
            Text("Conferences you attended",
                textScaleFactor: 2,
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildAttendedConferenceBlocks(),
          ],
        ),
      ),
    );
  }

  Widget _buildYourConferences() {
    return new Container(
      padding: EdgeInsets.only(top: 30, right: 15, left: 15),
      child: new Center(
        child: new Column(
          children: <Widget>[
            Text("Your Conferences",
                textScaleFactor: 2,
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildCreatedConferenceBlocks(),
          ],
        ),
      ),
    );
  }

  Widget _buildText(String title, String info) {
    return new Container(
      padding: EdgeInsets.only(bottom: 40.0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Text(title,
              textScaleFactor: 2,
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(info, textScaleFactor: 1.7),
        ],
      ),
    );
  }

  Widget _buildButton() {
    return new Container(
      padding: EdgeInsets.all(20.0),
      child: new SizedBox(
        width: 200.0,
        height: 50.0,
        child: FloatingActionButton.extended(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          heroTag: "btn1",
          label: Text(
            'LOGOUT',
            textScaleFactor: 1.5,
          ),
          onPressed: () {
            context.read<FireAuth>().signOut();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => LoginPage(widget._storage,
                        widget._speechProvider, widget.translator)),
                (route) => false);
          },
        ),
      ),
    );
  }

  Widget _buildCreatedConferenceBlocks() {
    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: _getConferences(),
        ),
      ),
    );
  }

  Widget _buildAttendedConferenceBlocks() {
    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: _getAttendedConferences(),
        ),
      ),
    );
  }

  Widget _getConferences() {
    return FutureBuilder(
        future: widget._storage
            .getOwnerConferences(context.watch<FireAuth>().currentUser.uid),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData) return new Container();
          List<QueryDocumentSnapshot> content = snapshot.data;
          return new ListView.builder(
            itemCount: content.length,
            itemBuilder: (BuildContext context, int index) {
              return new Padding(
                padding: EdgeInsets.all(10),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(12),
                  color: Colors.white,
                  onPressed: () => _goToConferencePressed(
                      content[index].id.toString(), content[index]['language']),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: Text(
                            content[index].id.toString(),
                            textScaleFactor: 2,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          formatDate(content[index]['date'].toDate(),
                              [dd, '/', mm, '/', yyyy]),
                          textScaleFactor: 1.2,
                          style: TextStyle(color: Colors.black54),
                        ),
                        SizedBox(height: 10.0),
                        Text(content[index]['description'],
                            textScaleFactor: 1.2),
                        SizedBox(height: 4.0),
                        Text(
                            'Language: ' +
                                LanguageConverter.convertLanguage(
                                    content[index]['language']),
                            textScaleFactor: 1.2,
                            style: TextStyle(color: Colors.black54)),
                        SizedBox(height: 10.0),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  Widget _getAttendedConferences() {
    return FutureBuilder(
        future: widget._storage
            .getAttendeeConferences(context.watch<FireAuth>().currentUser.uid),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData) return new Container();
          List<QueryDocumentSnapshot> content = snapshot.data;
          return new ListView.builder(
            itemCount: content.length,
            itemBuilder: (BuildContext context, int index) {
              return new Padding(
                padding: EdgeInsets.all(5),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(3),
                  color: Colors.white,
                  onPressed: () {},
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: Text(
                          content[index].id.toString(),
                          textScaleFactor: 2,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        formatDate(content[index]['date'].toDate(),
                            [dd, '/', mm, '/', yyyy]),
                        textScaleFactor: 1.2,
                        style: TextStyle(color: Colors.black54),
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  void _goToConferencePressed(String id, String language) async {
    int confIndex = await widget._storage.getConferenceByID(id);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProviderDemoApp(
                widget._storage,
                widget._speechProvider,
                confIndex,
                language,
                widget.translator)));
  }
}
