import 'dart:async';

import 'package:flutter/material.dart';

import 'package:retog/app/app.dart';
import 'package:retog/app/modules/api.dart';
import 'package:retog/app/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _username;
  String _password;
  String _baseApiUrl;
  bool _showBaseApiUrl = false;

  Future<void> _submit() async {
    _updateFormAttributes();

    if (_username == _password && _username == App.application.config.secretKeyWord) {
      setState(() {
        _formKey.currentState.reset();
        _showBaseApiUrl = true;
      });
      return null;
    }
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => Center(child: CircularProgressIndicator())
      );

      await Api.login(_username, _password);
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => HomePage()),
        (Route<dynamic> route) => false
      );
    } on ApiException catch(e) {
      Navigator.pop(context);
      _showSnackBar(e.errorMsg);
    } catch(e) {
      Navigator.pop(context);
      _showSnackBar('Произошла ошибка');
    }
  }

  Future<void> _getNewPassword() async {
    _updateFormAttributes();

    if (_username == null || _username == '') {
      _showSnackBar('Не заполнено поле с логином');
    } else {
      try {
        await Api.resetPassword(_username);
        _showSnackBar('Пароль отправлен на почту');
      } on ApiException catch(e) {
        _showSnackBar(e.errorMsg);
      }
    }
  }

  void _updateFormAttributes() {
    _formKey.currentState.save();
    if (_showBaseApiUrl) {
      App.application.config.apiBaseUrl = _baseApiUrl;
      App.application.config.save();
    }
  }

  void _showSnackBar(String content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(content)
    ));
  }

  Widget _buildLoginForm(BuildContext context) {
    return Container(
      height: 320,
      child: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    onSaved: (val) => _username = val,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: 'Телефон или e-mail или login',
                    ),
                  ),
                  TextFormField(
                    onSaved: (val) => _password = val,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Пароль'
                    ),
                  ),
                  _showBaseApiUrl ? TextFormField(
                    initialValue: App.application.config.apiBaseUrl,
                    onSaved: (val) => _baseApiUrl = val,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: 'Api Url'
                    ),
                  ) : Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                        child: Container(
                          width: 160,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                              primary: Colors.blue,
                            ),
                            onPressed: _submit,
                            child: const Text('Войти'),
                          ),
                        )
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                        child: Container(
                          width: 160,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                              primary: Colors.blue,
                            ),
                            onPressed: _getNewPassword,
                            child: const Text('Получить пароль')
                          ),
                        )
                      ),
                    ],
                  )
                ]
              )
            )
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    String fullVersion = App.application.config.packageInfo.version
      + '+'
      + App.application.config.packageInfo.buildNumber;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Войти в приложение'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _buildLoginForm(context),
          Expanded(child: Container()),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Text('Версия $fullVersion')
          )
        ]
      )
    );
  }
}
