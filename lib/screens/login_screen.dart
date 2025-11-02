import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/models.dart';
import 'conductor_screen.dart';
import 'padre_screen.dart';
import 'admin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      User? user = await _firebaseService.iniciarSesion(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user == null) {
        throw Exception('No se pudo iniciar sesión');
      }

      Usuario? usuario = await _firebaseService.obtenerUsuario(user.uid);

      if (usuario == null) {
        throw Exception('Usuario no encontrado en la base de datos');
      }

      if (!mounted) return;

      // Navegar según el tipo de usuario
      Widget pantalla;
      switch (usuario.tipo) {
        case TipoUsuario.conductor:
          pantalla = ConductorScreen(
            idConductor: usuario.id,
            nombreConductor: usuario.nombre,
          );
          break;
        case TipoUsuario.padre:
          // ✅ CORREGIDO: Removido parámetro nombrePadre que no existe en PadreScreen
          pantalla = PadreScreen(
            userId: usuario.id,
          );
          break;
        case TipoUsuario.admin:
          pantalla = AdminScreen(
            userId: usuario.id,
          );
          break;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => pantalla),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      String mensaje = 'Error al iniciar sesión';
      if (e.toString().contains('user-not-found')) {
        mensaje = 'Usuario no encontrado';
      } else if (e.toString().contains('wrong-password')) {
        mensaje = 'Contraseña incorrecta';
      } else if (e.toString().contains('invalid-email')) {
        mensaje = 'Correo electrónico inválido';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[700]!,
              Colors.blue[500]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Icono
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.school_outlined,
                      size: 80,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Título
                  const Text(
                    'Transporte Escolar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sistema de Seguimiento en Tiempo Real',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Formulario
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Correo Electrónico',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese su correo';
                                }
                                if (!value.contains('@')) {
                                  return 'Correo inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Contraseña
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese su contraseña';
                                }
                                if (value.length < 6) {
                                  return 'La contraseña debe tener al menos 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),

                            // Botón de inicio de sesión
                            SizedBox(
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _iniciarSesion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Información de prueba
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Usuarios de Prueba',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildUserInfo('Conductor', 'conductor@ejemplo.com',
                              'conductor123'),
                          _buildUserInfo(
                              'Padre', 'padre@ejemplo.com', 'padre123'),
                          _buildUserInfo(
                              'Admin', 'admin@ejemplo.com', 'admin123'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(String tipo, String email, String password) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            tipo == 'Conductor'
                ? Icons.directions_bus
                : tipo == 'Padre'
                    ? Icons.person
                    : Icons.admin_panel_settings,
            size: 16,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$tipo: $email / $password',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
