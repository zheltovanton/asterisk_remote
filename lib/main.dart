// Flutter code sample for material.RaisedButton.1

// This sample shows how to render a disabled RaisedButton, an enabled RaisedButton
// and lastly a RaisedButton with gradient background.
//
// ![Three raised buttons, one enabled, another disabled, and the last one
// styled with a blue gradient background](https://flutter.github.io/assets-for-api-docs/assets/material/raised_button.png)

import 'package:flutter/material.dart';
import 'pincode.dart';
import 'package:ssh/ssh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';

void main() => runApp(App());

class App extends StatefulWidget {
  App({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AppState createState() => _AppState();
}

showWarning(BuildContext context, String msg) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        backgroundColor: Colors.white,
        title: new Text("Результат"),
        content: new Text(msg),
        actions: <Widget>[
          new FlatButton(
            child: new Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


class _AppState extends State<App> with TickerProviderStateMixin {

  String _connect = "";
  String _disconnect = "";

  final _controllerserver = TextEditingController () ;
  final _controllerport = TextEditingController () ;
  final _controlleruser = TextEditingController () ;
  final _controllerpassword = TextEditingController () ;

  @override
  void dispose() {
    _controllerserver.dispose();
    _controllerport.dispose();
    _controlleruser.dispose();
    _controllerpassword.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    loadDefault();

    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _controllerserver.addListener(_saveServer);
    _controllerport.addListener(_savePort);
    _controlleruser.addListener(_saveUser);
    _controllerpassword.addListener(_savePassword);
  }

  void loadDefault() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _controllerserver.text = await prefs.getString('server');
    _controllerport.text = await prefs.getString('port');
    _controlleruser.text = await prefs.getString('user');
    _controllerpassword.text = await prefs.getString('password');
  }


  _saveServer() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('server',_controllerserver.text);
  }

  _savePort() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('port',_controllerport.text);
  }
  _saveUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user',_controlleruser.text);
  }
  _savePassword() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('password',_controllerpassword.text);
  }

  BoxDecoration inputDecor = new BoxDecoration(
      color:Colors.white,
      border: new Border(
        bottom: new BorderSide(
          width: 2,
          color: Colors.black26,
        ),
      )
  );

  void showRegistry(BuildContext context) async{
    var client = new SSHClient(
      host: _controllerserver.text,
      port: int.parse(_controllerport.text),
      username: _controlleruser.text,
      passwordOrKey: _controllerpassword.text,
    );
    await client.connect();
    var result = await client.execute("asterisk -x 'sip show registry' | awk '{print \$1 "+ '"\t"'+ "  \$5}' ");
    showWarning(context, result.toString());
    await client.disconnect();
  }

  void showSip(BuildContext context) async{
    var client = new SSHClient(
      host: _controllerserver.text,
      port: int.parse(_controllerport.text),
      username: _controlleruser.text,
      passwordOrKey: _controllerpassword.text,
    );
    await client.connect();
    var result = await client.execute("asterisk -x 'sip show peers' | grep -w OK | awk '{print \$1}' | awk -F'/' '{print \$1}'");
    showWarning(context, result.toString());
    await client.disconnect();
  }

  void showSipReload(BuildContext context) async{
    var client = new SSHClient(
      host: _controllerserver.text,
      port: int.parse(_controllerport.text),
      username: _controlleruser.text,
      passwordOrKey: _controllerpassword.text,
    );
    await client.connect();
    var result = await client.execute("asterisk -x 'sip reload'");
    if (result.toString().trim().length<5) {
      showWarning(context, "OK");
    } else {
      showWarning(context, result.toString());
    }
    await client.disconnect();
  }

  void showCoreRestartNow(BuildContext context) async{
    var client = new SSHClient(
      host: _controllerserver.text,
      port: int.parse(_controllerport.text),
      username: _controlleruser.text,
      passwordOrKey: _controllerpassword.text,
    );
    await client.connect();
    var result = await client.execute("asterisk -x 'core restart now'");
    showWarning(context, result.toString());
    await client.disconnect();
  }

  Widget MainPage(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        body: new SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child:Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new SizedBox(height: 30,),
                new Container(
                  margin: new EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
                  decoration: inputDecor,
                  child:  new TextFormField(
                    obscureText: false,
                    controller: _controllerserver,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black),
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(
                      border: UnderlineInputBorder(),

                      labelText: 'Server IP',
                      contentPadding: const EdgeInsets.only(
                          top: 10.0, right: 00.0, bottom: 4.0, left: 0.0),
                    ),
                  ),
                ),
                new Container(
                  margin: new EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
                  decoration: inputDecor,
                  child:  new TextFormField(
                    obscureText: false,
                    controller: _controllerport,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black),
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(
                      border: InputBorder.none,

                      labelText: 'Port',
                      contentPadding: const EdgeInsets.only(
                          top: 10.0, right: 00.0, bottom: 4.0, left: 0.0),
                    ),
                  ),
                ),
                new Container(
                  margin: new EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
                  decoration: inputDecor,
                  child:  new TextFormField(
                    obscureText: false,
                    controller: _controlleruser,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black),
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(
                      border: InputBorder.none,

                      labelText: 'User',
                      contentPadding: const EdgeInsets.only(
                          top: 10.0, right: 00.0, bottom: 4.0, left: 0.0),
                    ),
                  ),
                ),
                new Container(
                  margin: new EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
                  decoration: inputDecor,
                  child:  new TextFormField(
                    obscureText: true,
                    controller: _controllerpassword,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black),
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(
                      border: InputBorder.none,

                      labelText: 'Password',
                      contentPadding: const EdgeInsets.only(
                          top: 10.0, right: 00.0, bottom: 4.0, left: 0.0),
                    ),
                  ),
                ),

                RaisedButton(
                  padding: const EdgeInsets.all(10.0),
                  color:Color(0xFF1976D2),
                  onPressed: () {
                    showRegistry(context);
                  },
                  child: Text(
                      'Sip show registry',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20)),
                ),

                const SizedBox(height: 20),
                RaisedButton(
                  padding: const EdgeInsets.all(10.0),
                  color:Color(0xFF1976D2),
                  onPressed: () {
                    showSip(context);
                  },
                  child: Text(
                      'Sip show Peers',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20)),
                ),
                const SizedBox(height: 20),
                RaisedButton(
                  padding: const EdgeInsets.all(10.0),
                  color:Colors.green,
                  onPressed: () {
                    showSipReload(context);
                  },
                  child: Text(
                      'Sip reload',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20)),
                ),
                const SizedBox(height: 20),
                RaisedButton(
                  padding: const EdgeInsets.all(10.0),
                  color:Colors.red,
                  onPressed: () {
                    showCoreRestartNow(context);
                  },
                  child: Text(
                      'Core Restart NOW',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20)),
                ),
              ],
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Android remote',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => PinCodePage(context),
        '/home': (BuildContext context) => MainPage(context)
      },

      initialRoute: "/",
    );
  }
}

