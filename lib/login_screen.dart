import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_account_screen.dart';
import 'forget_password_screen.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _isLoading = false;
  Color _buttonColor = const Color(0xFF007BFF);
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  Color _signUpColor = const Color(0xFF007BFF);
  Color _forgotPasswordColor = const Color(0xFF007BFF);

  late AnimationController _animationController;
  late Animation<double> _formAnimation;
  late Animation<double> _buttonScaleAnimation;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _formAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  void _onEnter(PointerEvent details) {
    setState(() {
      _buttonColor = const Color(0xFF0056b3);
    });
  }

  void _onExit(PointerEvent details) {
    setState(() {
      _buttonColor = const Color(0xFF007BFF);
    });
  }

  void _onSignUpEnter(PointerEvent details) {
    setState(() {
      _signUpColor = const Color(0xFF0056b3);
    });
  }

  void _onSignUpExit(PointerEvent details) {
    setState(() {
      _signUpColor = const Color(0xFF007BFF);
    });
  }

  void _onForgotPasswordEnter(PointerEvent details) {
    setState(() {
      _forgotPasswordColor = const Color(0xFF0056b3);
    });
  }

  void _onForgotPasswordExit(PointerEvent details) {
    setState(() {
      _forgotPasswordColor = const Color(0xFF007BFF);
    });
  }

  void _onForgotPasswordTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgetPasswordScreen()),
    );
  }

  void _onSignUpTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
    );
  }

  Future<void> _onLoginTap() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await http.post(
          Uri.parse('http://56.228.80.139/api/account/login/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username_or_email': _emailController.text,
            'password': _passwordController.text,
          }),
        ).timeout(const Duration(seconds: 15)); // Added timeout

        print('Login response: ${response.statusCode} - ${response.body}');
        final email = _emailController.text.trim();
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', email);
          await prefs.setBool('loggedIn', true);
          print('User logged in as: $email');


          if (responseData['token'] != null) {
            await prefs.setString('authToken', responseData['token']);
          }
          if (responseData['user'] != null) {
            await prefs.setString('userData', jsonEncode(responseData['user']));
          }

          _showToast("Login successful!", Colors.green);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StudyGPTHome()),
          );
        } else {
          final errorData = jsonDecode(response.body);
          String errorMessage = 'Login failed. Please try again.';
          if (errorData is Map<String, dynamic>) {
            if (errorData.containsKey('detail')) {
              errorMessage = errorData['detail'];
            } else if (errorData.containsKey('non_field_errors')) {
              errorMessage = errorData['non_field_errors'][0];
            } else if (errorData.containsKey('email')) {
              errorMessage = 'Email: ${errorData['email'][0]}';
            } else if (errorData.containsKey('password')) {
              errorMessage = 'Password: ${errorData['password'][0]}';
            } else if (errorData.containsKey('username')) {
              errorMessage = 'Username: ${errorData['username'][0]}';
            } else {
              errorMessage = 'Error: ${response.body}';
            }
          }
          _showToast(errorMessage, Colors.red);
        }
      } catch (e) {
        print('Error: $e');
        _showToast("Network error: ${e.toString()}. Please check your connection.", Colors.red);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      timeInSecForIosWeb: 5,
    );
  }

  Color _getLabelColor(FocusNode focusNode) {
    return focusNode.hasFocus ? const Color(0xFF007BFF) : Colors.grey;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF007BFF),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        'assets/background_pattern.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0, left: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 49,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_formAnimation),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 30, bottom: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            _buildTextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              label: 'Email or Username',
                              hintText: 'Enter your email or username',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email or username';
                                }
                                // if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                //     .hasMatch(value) && !RegExp(r'^\w+$').hasMatch(value)) {
                                //   return 'Enter a valid email or username';
                                // }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildPasswordField(),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: MouseRegion(
                                onEnter: _onForgotPasswordEnter,
                                onExit: _onForgotPasswordExit,
                                child: GestureDetector(
                                  onTap: _onForgotPasswordTap,
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: _forgotPasswordColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Center(
                              child: _isLoading
                                  ? CircularProgressIndicator()
                                  : MouseRegion(
                                onEnter: _onEnter,
                                onExit: _onExit,
                                child: GestureDetector(
                                  onTap: _onLoginTap,
                                  child: ScaleTransition(
                                    scale: _buttonScaleAnimation,
                                    child: Container(
                                      height: 55,
                                      width: 300,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: LinearGradient(
                                          colors: [
                                            _buttonColor,
                                            _buttonColor.withOpacity(0.8),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _buttonColor.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'SIGN IN',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                MouseRegion(
                                  onEnter: _onSignUpEnter,
                                  onExit: _onSignUpExit,
                                  child: GestureDetector(
                                    onTap: _onSignUpTap,
                                    child: Text(
                                      "Sign up",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: _signUpColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Semantics(
      label: label,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        cursorColor: const Color(0xFF007BFF),
        validator: validator,
        key: Key('${label.toLowerCase()}_field'),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2.0),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          labelStyle: TextStyle(color: _getLabelColor(focusNode)),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Semantics(
      label: 'Password',
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        focusNode: _passwordFocusNode,
        cursorColor: const Color(0xFF007BFF),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          return null;
        },
        key: const Key('password_field'),
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Enter password',
          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
          suffixIcon: _passwordFocusNode.hasFocus
              ? IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2.0),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          labelStyle: TextStyle(color: _getLabelColor(_passwordFocusNode)),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}