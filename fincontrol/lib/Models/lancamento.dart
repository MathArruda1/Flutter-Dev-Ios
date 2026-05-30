class Lancamento {
  final int? id; // Adicionado o ID opcional
  final String item;
  final double valor;
  final bool isEntrada;

  Lancamento({
    this.id, // Recebe o ID aqui
    required this.item,
    required this.valor,
    required this.isEntrada,
  });
}