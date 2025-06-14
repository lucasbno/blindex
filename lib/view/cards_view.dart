import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../repository/user_repository.dart';
import '../controller/credit_card_controller.dart';
import '../model/credit_card.dart';
import '../components/app_bottom_bar.dart';
import 'credit_card_create_view.dart';

class CardsView extends StatefulWidget {
  const CardsView({super.key});

  @override
  State<CardsView> createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  late final CreditCardController _controller;
  late final UserRepository _userRepository;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = GetIt.instance.get<CreditCardController>();
    _userRepository = GetIt.instance.get<UserRepository>();
    _initializeController();
  }

  Future<void> _initializeController() async {
    if (_userRepository.currentUser != null) {
      await _controller.loadCards();
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userRepository.currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Faça login para acessar seus cartões'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Text('Fazer Login'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<CreditCardController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.errorMessage != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Erro ao carregar cartões',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(controller.errorMessage!),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        controller.clearError();
                        _initializeController();
                      },
                      child: Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final filteredCards = controller.filteredCards;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 0,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  _buildSearchBar(context, controller),
                  Expanded(
                    child: _buildCardsList(
                      context,
                      controller,
                      filteredCards,
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const AppBottomBar(
              currentScreen: '/cards',
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, CreditCardController controller) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 20.0,
        bottom: 12.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  controller.searchQuery = value;
                },
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Pesquisar cartões...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: InputBorder.none,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.searchQuery.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, size: 20),
                          onPressed: () => controller.searchQuery = '',
                        ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.search,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CreditCardCreateView(),
          ),
        );
      },
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_off, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Nenhum cartão encontrado',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione seu primeiro cartão',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsList(
    BuildContext context,
    CreditCardController controller,
    List<CreditCard> cards,
  ) {
    if (cards.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return _buildCreditCardWidget(context, controller, card);
      },
    );
  }

  Widget _buildCreditCardWidget(
    BuildContext context,
    CreditCardController controller,
    CreditCard card,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: _getCardColors(card.cardBrand),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          Navigator.pushNamed(
                            context,
                            '/card/edit',
                            arguments: card.toMap(),
                          );
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context, controller, card);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                card.maskedCardNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NOME NO CARTÃO',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.cardholderName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'VALIDADE',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.expiryDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getCardColors(String brand) {
    switch (brand) {
      case 'Visa':
        return [Colors.blue.shade700, Colors.blue.shade900];
      case 'Mastercard':
        return [Colors.red.shade600, Colors.red.shade800];
      case 'American Express':
        return [Colors.green.shade600, Colors.green.shade800];
      case 'Elo':
        return [Colors.orange.shade600, Colors.orange.shade800];
      default:
        return [Colors.grey.shade600, Colors.grey.shade800];
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    CreditCardController controller,
    CreditCard card,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Cartão'),
        content: Text('Deseja excluir permanentemente o cartão "${card.title}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && card.id != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      
      try {
        final success = await controller.deleteCard(card.id!);
        
        if (success) {
          _showSuccessSnackBar('Cartão excluído com sucesso!');
        } else {
          _showErrorSnackBar('Erro ao excluir cartão');
        }
      } catch (e) {
        _showErrorSnackBar('Erro ao excluir cartão: $e');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
