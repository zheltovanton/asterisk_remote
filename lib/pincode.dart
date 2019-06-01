import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:local_auth/local_auth.dart';

RegExp _alphanumeric = new RegExp(r'^[a-zA-Z0-9]+$');


bool isAlphanumeric(String str) {
  return _alphanumeric.hasMatch(str);
}

class PinCodePage extends StatefulWidget {
  BuildContext _context;
  PinCodePage(BuildContext context) {
    this._context = context;
  }

  @override
  State<StatefulWidget> createState() => new _PinCodePageState(_context);
}

class _PinCodePageState extends State<PinCodePage>
    with TickerProviderStateMixin {
  BuildContext context;
  _PinCodePageState(BuildContext _context) {
    this.context = _context;
  }
  final _controllerpin = TextEditingController () ;
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = 'Not Authorized';
  bool _canCheckBiometrics = false;
  bool loading = false;
  List<BiometricType> _availableBiometrics;

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });

    new Future.delayed(const Duration(seconds: 1),
            () => _authenticate());

  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Используйте авторизацию по отпечатку пальца',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    if (authenticated) {
      print("success auth");
      AuthIn(context);
    } else {
      //StartTimer();
    }

    setState(() {
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    });
  }

  BoxDecoration inputDecor = new BoxDecoration(
      color:Colors.black,
      border: new Border(
        bottom: new BorderSide(
          width: 1,
          color: Colors.black54,
        ),
      )
  );

  void AuthIn(BuildContext context) async{
    setState(() {
      loading = true;
    });

    Navigator.of(context).pushReplacementNamed('/home');

  }

  void CheckPin(BuildContext context) async{
    String pin = "1234";

    if (_controllerpin.text == pin) {
      AuthIn(context);
    }
  }

  @override
  void initState() {
    _checkBiometrics();
    super.initState();
  }

  @override
  void dispose() {
    _controllerpin.dispose();
    super.dispose();
  }

  void moveToHome() async{
    Navigator.pushReplacementNamed(context, "/home");
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.4;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return new Scaffold(
        backgroundColor: Colors.white,
        body:   new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Expanded(
                  flex: 1,
                  child:new Container(
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                        children: <Widget>[
                          new Container(
                            margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
                            padding: new EdgeInsets.fromLTRB(0.0,6.0, 0.0, 6.0),
                            decoration: inputDecor,
                            child:  new TextFormField(
                              obscureText: false,
                              style: const TextStyle(color: Colors.white, fontSize: 20.0),
                              textAlign: TextAlign.center,
                              //focusNode: _focusNode,
                              controller: _controllerpin,
                              keyboardType: TextInputType.number,
                              decoration: new InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter pin code",
                                hintStyle: const TextStyle(color: Colors.white54, fontSize: 20.0),

                                contentPadding: const EdgeInsets.only(
                                    top: 10.0, right: 00.0, bottom: 10.0, left: 0.0),
                              ),

                            ),
                          ),
                          new Container(
                              height: 50,
                              child: RaisedButton(
                                  onPressed: () {CheckPin(context);},
                                  color: Color(0xFF1976D2),
                                  textColor: Colors.white,
                                  child: Container(
                                    padding: const EdgeInsets.all(5.0),
                                    child:
                                    const Text('Login', style: TextStyle(fontSize: 20)),
                                  )
                              )
                          ),

                        ],
                      )
                  )
              )
            ]
        )
    );
  }
}
