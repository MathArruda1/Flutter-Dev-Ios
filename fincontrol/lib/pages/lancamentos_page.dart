import 'package:flutter/material.dart';

class LancamentosPage extends StatelessWidget {
  const LancamentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(title: const Text("Lançamentos")),

        const Expanded(
          child: Center(
            child: Text("Nenhum lançamento ainda"),
          ),
        ),
      ],
    );
  }
}

class AddLancamentoDialog extends StatefulWidget {
  const AddLancamentoDialog({super.key});

  @override
  State<AddLancamentoDialog> createState() => _AddLancamentoDialogState();
}

class _AddLancamentoDialogState extends State<AddLancamentoDialog> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController valorController = TextEditingController();

  bool isEntrada = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Novo Lançamento"),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: itemController,
            decoration: const InputDecoration(labelText: "Item"),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: valorController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Valor"),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Checkbox(
                value: isEntrada,
                onChanged: (value) {
                  setState(() {
                    isEntrada = value!;
                  });
                },
              ),
              Text(isEntrada ? "Entrada 💰" : "Saída 💸"),
            ],
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancelar"),
        ),

        ElevatedButton(
          onPressed: () {
            String item = itemController.text;
            String valor = valorController.text;

            print("Item: $item");
            print("Valor: $valor");
            print(isEntrada ? "Entrada" : "Saída");

            Navigator.pop(context);
          },
          child: const Text("Salvar"),
        ),
      ],
    );
  }
}