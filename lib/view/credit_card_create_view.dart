import 'package:blindex/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import '../repository/user_repository.dart';
import '../controller/credit_card_controller.dart';
import '../model/credit_card.dart';

class CreditCardCreateView extends StatefulWidget {
  final CreditCard? card;

  const CreditCardCreateView({super.key, this.card});

  @override
  State<CreditCardCreateView> createState() => _CreditCardCreateViewState();
}

class _CreditCardCreateViewState extends State<CreditCardCreateView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _cardholderNameController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _expiryDateController;
  late final TextEditingController _securityCodeController;
  late final TextEditingController _pinController;
  late final TextEditingController _notesController;

  late final CreditCardController _controller;
  late final UserRepository _userRepository;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    
    _isEditing = widget.card != null;
    
    _titleController = TextEditingController(text: widget.card?.title ?? '');
    _cardholderNameController = TextEditingController(text: widget.card?.cardholderName ?? '');
    _cardNumberController = TextEditingController(text: widget.card?.cardNumber ?? '');
    _expiryDateController = TextEditingController(text: widget.card?.expiryDate ?? '');
    _securityCodeController = TextEditingController(text: widget.card?.securityCode ?? '');
    _pinController = TextEditingController(text: widget.card?.pin ?? '');
    _notesController = TextEditingController(text: widget.card?.notes ?? '');
    
    _controller = GetIt.instance.get<CreditCardController>();
    _userRepository = GetIt.instance.get<UserRepository>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cardholderNameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _securityCodeController.dispose();
    _pinController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userRepository.currentUser?.uid == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final card = _isEditing && widget.card != null
          ? widget.card!.copyWith(
              title: _titleController.text.trim(),
              cardholderName: _cardholderNameController.text.trim(),
              cardNumber: _cardNumberController.text.replaceAll(' ', ''),
              expiryDate: _expiryDateController.text.trim(),
              securityCode: _securityCodeController.text.trim(),
              pin: _pinController.text.trim(),
              notes: _notesController.text.trim(),
            )
          : CreditCard.create(
              userId: _userRepository.currentUser!.uid!,
              title: _titleController.text.trim(),
              cardholderName: _cardholderNameController.text.trim(),
              cardNumber: _cardNumberController.text.replaceAll(' ', ''),
              expiryDate: _expiryDateController.text.trim(),
              securityCode: _securityCodeController.text.trim(),
              pin: _pinController.text.trim(),
              notes: _notesController.text.trim(),
            );

      final success = _isEditing
          ? await _controller.updateCard(card)
          : await _controller.addCard(card);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing 
                ? 'Cartão atualizado com sucesso!' 
                : 'Cartão adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing 
                ? 'Erro ao atualizar cartão' 
                : 'Erro ao adicionar cartão'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Cartão' : 'Novo Cartão'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCardPreview(),
              const SizedBox(height: 32),
              
              _buildTextField(
                controller: _titleController,
                label: 'Título do Cartão',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Título é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _cardholderNameController,
                label: 'Nome no Cartão',
                icon: Icons.person,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome no cartão é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _cardNumberController,
                label: 'Número do Cartão',
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CardNumberInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.replaceAll(' ', '').length < 13) {
                    return 'Número do cartão inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _expiryDateController,
                      label: 'Data de Expiração',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ExpiryDateInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.length != 5) {
                          return 'Data inválida';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _securityCodeController,
                      label: 'CVV',
                      icon: Icons.security,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value == null || value.length < 3) {
                          return 'CVV inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _pinController,
                label: 'PIN (Opcional)',
                icon: Icons.pin,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                obscureText: true,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _notesController,
                label: 'Notas (Opcional)',
                icon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCard,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(_isEditing ? 'Atualizar Cartão' : 'Salvar Cartão'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: _getCardColors(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titleController.text.isEmpty ? 'Título do Cartão' : _titleController.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _cardNumberController.text.isEmpty 
                ? '**** **** **** ****' 
                : _formatCardNumber(_cardNumberController.text),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
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
                  Text(
                    _cardholderNameController.text.isEmpty 
                        ? 'NOME SOBRENOME'
                        : _cardholderNameController.text.toUpperCase(),
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
                  Text(
                    _expiryDateController.text.isEmpty 
                        ? '12/28'
                        : _expiryDateController.text,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.textColor(context).withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.accent(context),
          ),
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      onChanged: (_) => setState(() {}),
    );
  }

  List<Color> _getCardColors() {
    final number = _cardNumberController.text.replaceAll(RegExp(r'\D'), '');
    if (number.startsWith('4')) return [Colors.blue.shade700, Colors.blue.shade900];
    if (number.startsWith('5')) return [Colors.red.shade600, Colors.red.shade800];
    if (number.startsWith('3')) return [Colors.green.shade600, Colors.green.shade800];
    if (number.startsWith('6')) return [Colors.orange.shade600, Colors.orange.shade800];
    return [Colors.grey.shade600, Colors.grey.shade800];
  }

  String _formatCardNumber(String input) {
    final clean = input.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    if (text.length <= 2) {
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    
    final month = text.substring(0, 2);
    final year = text.substring(2, text.length > 4 ? 4 : text.length);
    final formatted = '$month/$year';
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
