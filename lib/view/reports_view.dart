import 'package:blindex/components/app_bottom_bar.dart';
import 'package:blindex/controller/reports_controller.dart';
import 'package:blindex/model/password.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../controller/password_controller.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  late PasswordController _passwordController;
  final ReportsController _reportsController = ReportsController();

  @override
  void initState() {
    super.initState();
    _passwordController = GetIt.instance.get<PasswordController>();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _passwordController,
      child: Consumer<PasswordController>(
        builder: (context, controller, _) {
          final allPasswords = controller.passwords;
          final weakPasswords = _reportsController.getWeakPasswords(allPasswords);
          final reusedPasswords = _reportsController.getReusedPasswords(allPasswords);
          final securityScore = _reportsController.calculateSecurityScore(
            allPasswords,
            weakPasswords,
            reusedPasswords,
          );

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 0,
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  _buildSecurityScore(
                    context,
                    securityScore,
                    weakPasswords.length,
                    reusedPasswords.length,
                  ),
                  Expanded(
                    child: _buildReportsContent(
                      context,
                      weakPasswords,
                      reusedPasswords,
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const AppBottomBar(
              currentScreen: '/reports',
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Relatório de Segurança',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSecurityScore(
    BuildContext context,
    double score,
    int weakPasswordsCount,
    int reusedPasswordsCount,
  ) {
    final scoreColor = _reportsController.getScoreColor(score);

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pontuação de Segurança',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scoreColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${score.toInt()}%',
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildIssueCounter(
                context,
                Icons.warning_amber_outlined,
                Colors.orange,
                'Senhas Fracas',
                weakPasswordsCount.toString(),
              ),
              const SizedBox(width: 16),
              _buildIssueCounter(
                context,
                Icons.copy_all,
                Colors.red,
                'Senhas Reutilizadas',
                reusedPasswordsCount.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCounter(
    BuildContext context,
    IconData icon,
    Color color,
    String label,
    String count,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    count,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsContent(
    BuildContext context,
    List<Password> weakPasswords,
    List<Map<String, dynamic>> reusedPasswords,
  ) {
    if (weakPasswords.isEmpty && reusedPasswords.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView(
      children: [
        if (weakPasswords.isNotEmpty) ...[
          _buildSectionHeader(context, 'Senhas Fracas'),
          ...weakPasswords.map(
            (password) => _buildWeakPasswordCard(context, password),
          ),
        ],
        if (reusedPasswords.isNotEmpty) ...[
          _buildSectionHeader(context, 'Senhas Reutilizadas'),
          ...reusedPasswords.map(
            (group) => _buildReusedPasswordGroup(context, group),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            'Parabéns!',
            style: TextStyle(fontSize: 18, color: Colors.green),
          ),
          const SizedBox(height: 8),
          Text(
            'Não encontramos problemas com suas senhas',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          if (title == 'Senhas Fracas')
            const Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 20)
          else
            const Icon(Icons.copy_all, color: Colors.red, size: 20),
        ],
      ),
    );
  }

  Widget _buildWeakPasswordCard(BuildContext context, Password password) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: _buildPasswordAvatar(context, password.title, password.icon),
        title: Text(password.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(password.login),
            const SizedBox(height: 4),
            _buildWeaknessReasons(context, password.password),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/password/edit',
              arguments: password.toMap(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeaknessReasons(BuildContext context, String password) {
    final weaknesses = _reportsController.getPasswordWeaknesses(password);

    return Wrap(
      spacing: 4,
      children: weaknesses.map((weakness) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange.withAlpha(50),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            weakness,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.orange,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReusedPasswordGroup(BuildContext context, Map<String, dynamic> group) {
    final accounts = group['accounts'] as List<Password>;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.vpn_key, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Senha usada em ${accounts.length} contas',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...accounts.map((account) => ListTile(
                leading: _buildPasswordAvatar(context, account.title, account.icon),
                title: Text(account.title),
                subtitle: Text(account.login),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/password/edit',
                      arguments: account.toMap(),
                    );
                  },
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPasswordAvatar(BuildContext context, String title, String icon) {
    return icon.isNotEmpty
        ? CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.lock, color: Colors.white),
          )
        : CircleAvatar(
            backgroundColor: Theme.of(context).primaryColorLight,
            child: Text(
              title.isNotEmpty ? title.substring(0, 1).toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          );
  }
}