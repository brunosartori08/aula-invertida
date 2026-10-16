import 'package:flutter/material.dart';

void main() => runApp(const MeuApp());

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaNome(),
    );
  }
}

class TelaNome extends StatefulWidget {
  const TelaNome({super.key});

  @override
  State<TelaNome> createState() => _TelaNomeState();
}

class _TelaNomeState extends State<TelaNome> {
  final chave = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  String mensagem = '';

  void confirmar() {
    if (chave.currentState!.validate()) {
      setState(() {
        mensagem = 'Olá, ${nomeController.text.trim()}!';
      });
    } else {
      // Exercício 2: Apaga saudação anterior caso a entrada seja inválida
      setState(() {
        mensagem = '';
      });
    }
  }

  void limpar() {
    // Exercício 2: Limpa controller, estado do Form e variável de mensagem
    nomeController.clear();
    chave.currentState?.reset();
    setState(() {
      mensagem = '';
    });
  }

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nome validado')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: chave,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  // Exercício 1: Validação de campo vazio e tamanho mínimo
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o nome.';
                  }
                  if (valor.trim().length < 3) {
                    return 'O nome deve ter pelo menos três caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: confirmar,
                      child: const Text('Confirmar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: limpar,
                      child: const Text('Limpar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (mensagem.isNotEmpty)
                Text(
                  mensagem,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
