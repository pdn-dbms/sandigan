import 'package:flutter/material.dart';
import 'package:pol_dbms/services/auth.dart';
import 'package:pol_dbms/util/widgets.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = GlobalKey<FormState>();

  String _name = '', _username = '', _password = '', _confirmPassword = '';

  String? validateEmail(String? value) {
    String _msg = '';
    RegExp regex = new RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (value!.isEmpty) {
      _msg = "Your username is required";
    } else if (!regex.hasMatch(value)) {
      _msg = "Please provide a valid emal address";
    }
    if (_msg == '') {
      return null;
    } else {
      return _msg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
      autofocus: false,
      obscureText: false,
      validator: (value) => value!.isEmpty ? "Please enter fullname" : null,
      onSaved: (value) => _name = value!,
      decoration:
          buildInputDecoration("Enter Fullname", Icons.verified_user_rounded),
    );

    final usernameField = TextFormField(
      autofocus: false,
      validator: validateEmail,
      onSaved: (value) => _username = value!,
      decoration: buildInputDecoration("Confirm password", Icons.email),
    );

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (value) => value!.isEmpty ? "Please enter password" : null,
      onSaved: (value) => _password = value!,
      decoration: buildInputDecoration("Confirm password", Icons.lock),
    );

    final confirmPassword = TextFormField(
      autofocus: false,
      validator: (value) => value!.isEmpty ? "Your password is required" : null,
      onSaved: (value) => _confirmPassword = value!,
      obscureText: true,
      decoration: buildInputDecoration("Confirm password", Icons.lock),
    );

    // ignore: prefer_function_declarations_over_variables
    var doRegister = () async {
      final form = formKey.currentState;

      form!.save();
      if (form.validate()) {
        FireAuth.registerUsingEmailPassword(
            name: _name, email: _username, password: _password);
        Navigator.pop(context);
      }
    };

    return Scaffold(
      backgroundColor: const Color.fromRGBO(9, 2, 81, 1),
      appBar: AppBar(
        title: Text('Add leader'),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15.0),
              label("Fullname"),
              const SizedBox(height: 5.0),
              nameField,
              const SizedBox(height: 15.0),
              label("Email"),
              SizedBox(height: 5.0),
              usernameField,
              SizedBox(height: 15.0),
              label("Password"),
              SizedBox(height: 10.0),
              passwordField,
              SizedBox(height: 15.0),
              label("Confirm Password"),
              SizedBox(height: 10.0),
              confirmPassword,
              SizedBox(height: 20.0),
              longButtons("Create Leader", doRegister),
            ],
          ),
        ),
      ),
    );
  }
}
