import 'package:flutter/material.dart';
import 'welcome.dart';
import 'package:flutter/services.dart';

final Color primaryColor = const Color(0xFF2196F3);
final Color accentColor = const Color(0xFF4CAF50);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _validateCredentials(String username, String password) {
    // This is a simple validation. In a real app, you'd typically check against a database or API.
    return username == 'admin' && password == '123456';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 10.0, left: 30.0, right: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue[900]!,
                        Colors.blue[300]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.school,
                        size: 80,
                        color: Colors.white,
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'E-Learning Mobile',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Username',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue[700]),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        
                        decoration: InputDecoration(
                          hintText: 'Username',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Mohon masukkan username';
                          }
                          if (value.length < 3) {
                            return 'Username harus minimal 3 karakter';
                          }
                          return null;
                        },
                        onSaved: (value) => _username = value!,
                      ),
                      const SizedBox(height: 16.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue[700]),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.lock, color: Colors.blue[700]),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Mohon masukkan password';
                          }
                          if (value.length < 6) {
                            return 'Password harus minimal 6 karakter';
                          }
                          return null;
                        },
                        onSaved: (value) => _password = value!,
                      ),
                      const SizedBox(height: 8.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handle forgot password
                          },
                          child: Text('Forgot Password?', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            if (_validateCredentials(_username, _password)) {
                              _showDialog('Login Berhasil', 'Selamat datang, $_username!');
                              Future.delayed(const Duration(seconds: 2), () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                                );
                              });
                            } else {
                              _showDialog('Login Gagal', 'Username atau password salah');
                            }
                          }
                        },
                        child: const Text('Login', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
