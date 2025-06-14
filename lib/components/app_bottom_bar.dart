import 'package:flutter/material.dart';

class AppBottomBar extends StatelessWidget {
  final String currentScreen;

  const AppBottomBar({
    super.key,
    required this.currentScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavButton(
            context: context,
            route: '/passwords',
            isActive: currentScreen == '/passwords',
            icon: Icons.home_outlined,
            label: 'Início',
          ),
          
          _buildNavButton(
            context: context,
            route: '/cards',
            isActive: currentScreen == '/cards',
            icon: Icons.credit_card_outlined,
            label: 'Cartões',
          ),
          
          _buildNavButton(
            context: context,
            route: '/reports',
            isActive: currentScreen == '/reports',
            icon: Icons.analytics_outlined,
            label: 'Relatório',
          ),
          
          _buildNavButton(
            context: context,
            route: '/profile',
            isActive: currentScreen == '/profile',
            icon: Icons.person,
            label: 'Perfil',
          ),

          _buildNavButton(
            context: context,
            route: '/trash',
            isActive: currentScreen == '/trash',
            icon: Icons.delete_outline,
            label: 'Lixeira',
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required String route,
    required bool isActive,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {
        if (!isActive && route.isNotEmpty) {
          Navigator.of(context).pushReplacementNamed(route);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.grey.shade600,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade600,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}