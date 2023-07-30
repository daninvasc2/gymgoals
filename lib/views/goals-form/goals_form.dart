import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../models/goals.dart';
import 'package:intl/intl.dart';

class GoalsForm extends StatefulWidget {
  const GoalsForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GoalsFormState createState() => _GoalsFormState();
}

class _GoalsFormState extends State<GoalsForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar nova meta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _fbKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(labelText: 'Nome da meta'),
                validator: FormBuilderValidators.required(errorText: 'Campo obrigatório.'),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'description',
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: FormBuilderValidators.required(errorText: 'Campo obrigatório.'),
              ),
              const SizedBox(height: 16),
              FormBuilderDateTimePicker(
                name: 'expirationDate',
                inputType: InputType.date,
                format: DateFormat('dd/MM/yyyy'),
                decoration: const InputDecoration(labelText: 'Data de expiração'),
                validator: FormBuilderValidators.required(errorText: 'Campo obrigatório.'),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'goalValue',
                decoration: const InputDecoration(labelText: 'Objetivo (em dias)'),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Campo obrigatório.'),
                  FormBuilderValidators.numeric(errorText: 'Campo deve ser numérico.'),
                ]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_fbKey.currentState!.saveAndValidate()) {
                    Goals newGoal = Goals(
                      name: _fbKey.currentState!.value['name'],
                      description: _fbKey.currentState!.value['description'],
                      imageUrl: '', // You can add the image URL logic here if needed
                      expirationDate: _fbKey.currentState!.value['expirationDate'],
                      goalValue: num.parse(_fbKey.currentState!.value['goalValue']),
                    );

                    Navigator.pop(context); // Navigate back to the previous screen after saving.
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
