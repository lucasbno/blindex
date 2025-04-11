import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {
  const AboutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: 
        Builder(builder: (context) => 
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.shield, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'Blindex',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'by Data Liquid Labs',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Version 0.0.1 Debug',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              SizedBox(height: 24),
              
              // Description
              const Text(
                'Blindex é um gerenciador de senhas focused on simplicidade e uso facíl.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.5),
              ),
              
              const SizedBox(height: 24),
              
              // Features
              _buildSection(
                title: 'Features',
                context: context,
                child: Column(
                  children: [
                    _buildFeatureRow(icon: Icons.lock, text: 'Encriptação de ponta a ponta', context: context),
                    _buildFeatureRow(icon: Icons.code, text: 'Codigo aberto', context: context),
                  ],
                ),
              ),
              
              // Time
              _buildSection(
                title: 'Desenvolvido por',
                context: context,
                child: Column(
                  children: [
                    _buildTeamMember(name: 'Lucas Bueno Ricardo', email: 'lucas.ricardo@fatec.sp.gov.br', context: context),
                    _buildTeamMember(name: 'Gustavo Miguel Santana', email: 'gustavo.santana19@fatec.sp.gov.br', context: context),
                  ],
                ),
              ),
              
              // Footer
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text('Politica de Privacidade', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {},
                    child: Text('Termos de Serviço', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            ]
          ),
        ),
      );
  }

  Widget _buildSection({required String title, required Widget child, required BuildContext context}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildFeatureRow({required IconData icon, required String text, required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildTeamMember({required String name, required String email, required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(email, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}