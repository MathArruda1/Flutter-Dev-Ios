import 'package:flutter/material.dart';
import '../Models/lancamento.dart';

class LancamentosPage extends StatelessWidget {
  final List<Lancamento> lista;

  const LancamentosPage({super.key, required this.lista});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lançamentos"),
      ),
body: lista.isEmpty
    ? const Center(child: Text("Nenhum lançamento ainda"))
    : ListView.builder(
        itemCount: lista.length,
        itemBuilder: (context, index) {
          final item = lista[index];

          return ListTile(
            leading: Icon(
              
              item.isEntrada
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: item.isEntrada ? Colors.green : Colors.red,
            ),
            title: Text(item.item),
            trailing: Text(
              "R\$ ${item.valor.toStringAsFixed(2)}",
            ),
          );
        },
      ),
    );
  }
}

class AddLancamentoDialog extends StatefulWidget {
  final Function(Lancamento) onSalvar;

  const AddLancamentoDialog({super.key, required this.onSalvar});

  @override
  State<AddLancamentoDialog> createState() =>
      _AddLancamentoDialogState();
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
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),

        ElevatedButton(
          onPressed: () {
            String item = itemController.text;
            double valor =
                double.tryParse(valorController.text) ?? 0;

            if (item.isEmpty || valor <= 0) return;

            final lancamento = Lancamento(
              item: item,
              valor: valor,
              isEntrada: isEntrada,
            );

            widget.onSalvar(lancamento);

            Navigator.pop(context);
          },
          child: const Text("Salvar"),
        ),
      ],
    );
  }
}