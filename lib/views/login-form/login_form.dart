import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:metas_academia/views/homepage/homepage.dart';
import 'package:metas_academia/views/login-form/registration_form.dart';
import 'package:metas_academia/models/current_user.dart';
import '../../helper.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  void _submitLoginForm() async {
    if (_fbKey.currentState!.saveAndValidate()) {
      String email = _fbKey.currentState!.value['email'];
      String password = _fbKey.currentState!.value['password'];

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

        String imageUrl = userSnapshot.get('imageUrl');
        String userName = userSnapshot.get('name');

        CurrentUser currentUser = CurrentUser(
          name: userName,
          email: userCredential.user!.email!,
          profilePictureUrl: imageUrl,
        );
        showToast('Logado com sucesso.');

        redirectToHomePage(currentUser);
      } catch (e) {
        if (e is FirebaseAuthException) {
          String message = '';
          switch (e.code) {
            case 'invalid-email':
              message = 'Email inválido.';
              break;
            case 'user-disabled':
              message = 'Usuário desabilitado.';
              break;
            case 'user-not-found':
              message = 'Usuário não encontrado. Crie uma conta!.';
              break;
            case 'wrong-password':
              message = 'Senha incorreta.';
              break;
            default:
              message = 'Erro desconhecido.';
          }
          showToast('Erro ao logar: $message');
        } else {
          showToast('Erro desconhecido ao logar: $e');
        }
      }
    }
  }

  void redirectToHomePage(CurrentUser currentUser) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(currentUser: currentUser,)),
    );
  }

  void redirectToRegisterPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationForm()),
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
                keyboardType: TextInputType.emailAddress,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Campo obrigatório.'),
                  FormBuilderValidators.email(errorText: 'Entre com um email válido.'),
                ])
              ),
              const SizedBox(height: 20),

              FormBuilderTextField(
                name: 'password',
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Campo obrigatório.'),
                  FormBuilderValidators.minLength(6, errorText: 'A senha deve ter pelo menos 6 caracteres.'),
                ]),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submitLoginForm,
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrationForm()));
                },
                child: const Text('Cadastrar'),
              ),              
            ],
          ),
        ),
      ),
    );
  }
}
