import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  // Method to handle form submission for registration
  void _submitRegisterForm() async {
    if (_fbKey.currentState!.saveAndValidate()) {
      String email = _fbKey.currentState!.value['email'];
      String password = _fbKey.currentState!.value['password'];

      try {
        await _auth.createUserWithEmailAndPassword(email: email, password: password);
        showToast('Registration successful.');
      } catch (e) {
        showToast('Registration failed: $e');
      }
    }
  }

  // Method to handle form submission for login
  void _submitLoginForm() async {
    if (_fbKey.currentState!.saveAndValidate()) {
      String email = _fbKey.currentState!.value['email'];
      String password = _fbKey.currentState!.value['password'];

      try {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        showToast('Login successful.');
      } catch (e) {
        showToast('Login failed: $e');
      }
    }
  }

  // Method to show Toast messages
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FormBuilder(
        key: _fbKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email field
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 20),

              // Password field
              FormBuilderTextField(
                name: 'password',
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Registration button
              ElevatedButton(
                onPressed: _submitRegisterForm,
                child: const Text('Register'),
              ),
              const SizedBox(height: 10),

              // Login button
              ElevatedButton(
                onPressed: _submitLoginForm,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
