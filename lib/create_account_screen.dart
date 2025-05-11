import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen>
    with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  Color _buttonColor = const Color(0xFF007BFF);
  Color _linkColor = const Color(0xFF007BFF);

  late AnimationController _animationController;
  late Animation<double> _formAnimation;
  late Animation<double> _buttonScaleAnimation;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _gradeFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  String? _selectedGrade;

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

    _passwordFocusNode.addListener(() {
      setState(() {});
    });
    _confirmPasswordFocusNode.addListener(() {
      setState(() {});
    });
  }

  void _onEnterButton(PointerEvent details) {
    setState(() {
      _buttonColor = const Color(0xFF0056b3);
    });
  }

  void _onExitButton(PointerEvent details) {
    setState(() {
      _buttonColor = const Color(0xFF007BFF);
    });
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGrade == null) {
        _showToast("Please select a grade", Colors.red);
        return;
      }

      setState(() => _isLoading = true);

      try {
        final response = await http.post(
          Uri.parse('http://56.228.80.139/api/account/register/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'username': _fullNameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'confirm_password': _confirmPasswordController.text,
            'grade': _selectedGrade!,
          }),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 201 || response.statusCode == 200) {
          _showToast("Account created successfully!", Colors.green);
          Navigator.pop(context);
        } else {
          final errorData = jsonDecode(response.body);
          String errorMessage = 'Registration failed. Please try again.';

          if (errorData is Map<String, dynamic>) {
            if (errorData.containsKey('detail')) {
              errorMessage = errorData['detail'];
            } else if (errorData.containsKey('email')) {
              errorMessage = 'Email: ${errorData['email'][0]}';
            } else if (errorData.containsKey('username')) {
              errorMessage = 'Username: ${errorData['username'][0]}';
            } else if (errorData.containsKey('password')) {
              errorMessage = 'Password: ${errorData['password'][0]}';
            } else if (errorData.containsKey('confirm_password')) {
              errorMessage = 'Confirm Password: ${errorData['confirm_password'][0]}';
            } else if (errorData.containsKey('grade')) {
              errorMessage = 'Grade: ${errorData['grade'][0]}';
            } else {
              errorMessage = errorData.toString();
            }
          } else {
            errorMessage = 'Unexpected error: ${response.body}';
          }

          _showToast(errorMessage, Colors.red);
        }
      } catch (e) {
        _showToast("Error: ${e.toString()}. Please check your connection.", Colors.red);
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
    );
  }

  Color _getLabelColor(FocusNode focusNode) {
    return focusNode.hasFocus ? const Color(0xFF007BFF) : Colors.grey;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocusNode.dispose();
    _gradeFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF007BFF), Color(0xFF0056b3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
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
                const Padding(
                  padding: EdgeInsets.only(top: 60.0, left: 22),
                  child: Text(
                    'Create Account',
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
                height: 541,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _fullNameController,
                            focusNode: _fullNameFocusNode,
                            label: 'Username',
                            hintText: 'Enter your username',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              if (value.length < 4) {
                                return 'Username must be at least 4 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            label: 'Email',
                            hintText: 'Enter your email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildGradeDropdown(),
                          const SizedBox(height: 20),
                          _buildPasswordField(),
                          const SizedBox(height: 20),
                          _buildConfirmPasswordField(),
                          const SizedBox(height: 30),
                          _isLoading
                              ? CircularProgressIndicator() :
                          MouseRegion(
                            onEnter: _onEnterButton,
                            onExit: _onExitButton,
                            child: GestureDetector(
                              onTap: _registerUser,
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
                                      'SIGN UP',
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
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              MouseRegion(
                                onEnter: (details) {
                                  setState(() {
                                    _linkColor = const Color(0xFF0056b3);
                                  });
                                },
                                onExit: (details) {
                                  setState(() {
                                    _linkColor = const Color(0xFF007BFF);
                                  });
                                },
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    "Sign in",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: _linkColor,
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
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      cursorColor: const Color(0xFF007BFF),
      validator: validator,
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
    );
  }

  Widget _buildGradeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedGrade,
            focusNode: _gradeFocusNode,
            decoration: InputDecoration(
              hintText: 'Select your grade',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.school, color: Colors.grey),
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
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            ),
            dropdownColor: Colors.white,
            elevation: 8,
            style: const TextStyle(color: Colors.black, fontSize: 16),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            menuMaxHeight: 200,
            borderRadius: BorderRadius.circular(15),
            items: List.generate(12, (index) {
              final grade = '${index + 1}';
              return DropdownMenuItem<String>(
                value: grade,
                child: Text('Grade $grade', style: const TextStyle(color: Colors.black)),
              );
            }),
            onChanged: (value) {
              setState(() => _selectedGrade = value);
            },
            validator: (value) {
              if (value == null) {
                return 'Please select your grade';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      focusNode: _passwordFocusNode,
      cursorColor: const Color(0xFF007BFF),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
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
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      focusNode: _confirmPasswordFocusNode,
      cursorColor: const Color(0xFF007BFF),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Re-enter password',
        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
        suffixIcon: _confirmPasswordFocusNode.hasFocus
            ? IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
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
        labelStyle: TextStyle(color: _getLabelColor(_confirmPasswordFocusNode)),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}