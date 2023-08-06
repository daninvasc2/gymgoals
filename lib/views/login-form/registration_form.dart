import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metas_academia/views/homepage/homepage.dart';
import 'package:metas_academia/models/current_user.dart';
import '../../helper.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker();
  File? _imageFile;

  void _submitRegisterForm() async {
    if (_fbKey.currentState!.saveAndValidate()) {
      String email = _fbKey.currentState!.value['email'];
      String password = _fbKey.currentState!.value['password'];
      String name = _fbKey.currentState!.value['name'];
      String imageUrl = '';

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (_imageFile != null) {
          imageUrl = await _uploadProfilePicture(userCredential.user!.uid);
        }

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'imageUrl': imageUrl,
        });

        CurrentUser currentUser = CurrentUser(
          name: name,
          email: email,
          profilePictureUrl: imageUrl,
        );

        showToast('Registrado com sucesso.');

        redirectToHomePage(currentUser);
      } catch (e) {
        if (e is FirebaseAuthException) {
          String message = '';
          switch (e.code) {
            case 'email-already-in-use':
              message = 'Email já está em uso.';
              break;
            case 'invalid-email':
              message = 'Email inválido.';
              break;
            case 'operation-not-allowed':
              message = 'Operação não permitida.';
              break;
            case 'weak-password':
              message = 'Senha fraca.';
              break;
            default:
              message = 'Erro desconhecido.';
          }
          showToast('Erro ao registrar: $message');
        } else {
          showToast('Erro desconhecido ao registrar: $e');
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

  Future<void> _pickImage() async {
    XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        showToast('Imagem selecionada!');
      });
    }
  }

  Future<String> _uploadProfilePicture(String userId) async {
    String fileName = 'profile_$userId.jpg';
    Reference reference = FirebaseStorage.instance.ref().child('profile_pictures/$fileName');
    UploadTask uploadTask = reference.putFile(_imageFile!);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gym Goals')),
      body: SingleChildScrollView(
        child: FormBuilder(
          key: _fbKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name field
                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: FormBuilderValidators.required(errorText: 'Campo obrigatório.'),
                ),
                const SizedBox(height: 20),
    
                // Email field
                FormBuilderTextField(
                  name: 'email',
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Campo obrigatório.'),
                    FormBuilderValidators.email(errorText: 'Entre com um email válido.'),
                  ]),
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
                  onPressed: _pickImage,
                  child: const Text('Foto de perfil'),
                ),
                const SizedBox(height: 20),
    
                ElevatedButton(
                  onPressed: _submitRegisterForm,
                  child: const Text('Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
