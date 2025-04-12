import 'package:flutter/material.dart';
import '../controller/password_form_controller.dart';

class PasswordGeneratorModal extends StatelessWidget {
  final PasswordFormController controller;

  const PasswordGeneratorModal({
    super.key,
    required this.controller,
  });

  static void show(BuildContext context, PasswordFormController controller) {
    if (controller.generatedPassword.isEmpty) {
      controller.generateNewPassword();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => PasswordGeneratorModal(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gerador de Senha',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.generatedPassword.isEmpty
                            ? 'Gere uma senha segura'
                            : controller.generatedPassword,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => setState(() => controller.generateNewPassword()),
                      tooltip: 'Gerar nova senha',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  const Text('Tamanho: '),
                  Expanded(
                    child: Slider(
                      value: controller.passwordLength.toDouble(),
                      min: 6,
                      max: 30,
                      divisions: 24,
                      label: controller.passwordLength.toString(),
                      onChanged: (value) => setState(() {
                        controller.updatePasswordLength(value.toInt());
                      }),
                    ),
                  ),
                  Text('${controller.passwordLength}'),
                ],
              ),
              
              CheckboxListTile(
                title: const Text('Incluir caracteres especiais'),
                value: controller.includeSpecialChars,
                onChanged: (_) => setState(() => controller.toggleSpecialChars()),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              
              CheckboxListTile(
                title: const Text('Incluir números'),
                value: controller.includeNumbers,
                onChanged: (_) => setState(() => controller.toggleNumbers()),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              
              CheckboxListTile(
                title: const Text('Incluir letras maiúsculas'),
                value: controller.includeUppercase,
                onChanged: (_) => setState(() => controller.toggleUppercase()),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.applyGeneratedPassword();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Aplicar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}