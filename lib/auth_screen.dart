import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  String _email = '';
  String _password = '';
  String _firstName = '';
  String _lastName = '';
  DateTime _dob = DateTime.now();

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isLogin) {
          // Log in existing user
          await _auth.signInWithEmailAndPassword(
            email: _email,
            password: _password,
          );
        } else {
          // Register new user
          final result = await _auth.createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          );

          // Store additional user data in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(result.user!.uid)
              .set({
            'firstName': _firstName,
            'lastName': _lastName,
            'email': _email,
            'userId': result.user!.uid,
            'role': 'user',
            'registrationDatetime': Timestamp.now(),
            'dob': _dob,
          });
        }
      } on FirebaseAuthException catch (error) {
        var message = 'An error occurred, please check your credentials!';

        if (error.message != null) {
          message = error.message!;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.blue,
          ),
        );
        
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.blue,
          ),
        );
        
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App name
                  const Text(
                    'Chatboards',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'For the New Age',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email field
                  TextFormField(
                    key: const ValueKey('email'),
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value!.trim();
                    },
                  ),
                  const SizedBox(height: 12),

                  // Password field
                  TextFormField(
                    key: const ValueKey('password'),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value!.trim();
                    },
                  ),
                  const SizedBox(height: 12),

                  // Registration fields
                  if (!_isLogin) ...[
                    // First name field
                    TextFormField(
                      key: const ValueKey('firstName'),
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _firstName = value!.trim();
                      },
                    ),
                    const SizedBox(height: 12),

                    // Last name field
                    TextFormField(
                      key: const ValueKey('lastName'),
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _lastName = value!.trim();
                      },
                    ),
                    const SizedBox(height: 12),

                    // Date of birth field (simplified)
                    GestureDetector(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _dob,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _dob = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date of Birth: ${_dob.day}/${_dob.month}/${_dob.year}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _submit,
                      child: Text(_isLogin ? 'Login' : 'Register'),
                    ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(_isLogin
                        ? 'Create a new account'
                        : 'I already have an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}