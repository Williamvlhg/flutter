import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoginMode = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [SimpsonsColors.yellow, SimpsonsColors.lightYellow],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: SimpsonsColors.blue, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildForm(),
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                        const SizedBox(height: 16),
                        _buildToggleMode(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SimpsonsColors.blue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.person,
            size: 40,
            color: SimpsonsColors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isLoginMode ? 'Connexion' : 'Inscription',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: SimpsonsColors.darkBlue,
          ),
        ),
        Text(
          _isLoginMode 
              ? 'Connectez-vous à votre compte'
              : 'Créez votre compte Simpson',
          style: const TextStyle(
            fontSize: 16,
            color: SimpsonsColors.darkBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!_isLoginMode)
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nom d\'utilisateur',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: SimpsonsColors.blue, width: 2),
                ),
              ),
              validator: (value) {
                if (!_isLoginMode && (value == null || value.isEmpty)) {
                  return 'Veuillez entrer un nom d\'utilisateur';
                }
                return null;
              },
            ),
          if (!_isLoginMode) const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: SimpsonsColors.blue, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!value.contains('@')) {
                return 'Veuillez entrer un email valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: SimpsonsColors.blue, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre mot de passe';
              }
              if (!_isLoginMode && value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: authService.isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: SimpsonsColors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: authService.isLoading
                ? const CircularProgressIndicator(color: SimpsonsColors.white)
                : Text(
                    _isLoginMode ? 'Se connecter' : 'S\'inscrire',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SimpsonsColors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildToggleMode() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isLoginMode = !_isLoginMode;
        });
      },
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: SimpsonsColors.darkBlue),
          children: [
            TextSpan(
              text: _isLoginMode 
                  ? 'Pas encore de compte ? '
                  : 'Déjà un compte ? ',
            ),
            TextSpan(
              text: _isLoginMode ? 'S\'inscrire' : 'Se connecter',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: SimpsonsColors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      bool success = false;

      if (_isLoginMode) {
        success = await authService.login(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        success = await authService.register(
          _emailController.text,
          _usernameController.text,
          _passwordController.text,
        );
      }

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isLoginMode ? 'Connexion réussie !' : 'Compte créé avec succès !',
            ),
            backgroundColor: SimpsonsColors.blue,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'authentification'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}