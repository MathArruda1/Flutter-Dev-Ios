import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

void login(BuildContext context) {
  String email = emailController.text.trim();
  String senha = senhaController.text.trim();

  if (email.isEmpty && senha.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Preencha os campos de e-mail e senha"),
      ),
    );
    return;
  }

  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Preencha o e-mail"),
      ),
    );
    return;
  }

    if (senha.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Preencha a sua senha"),
      ),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const HomePage()),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( 
        child: Container(
          width: 300, 
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "FinControl IA 💰",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Esqueceu a senha?",
                    style: TextStyle(color: Colors.blue),
                  ),

                  ElevatedButton(
                    onPressed: () => login(context),
                    child: const Text(
                      "Entrar",
                        style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}