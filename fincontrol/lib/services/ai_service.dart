import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth.dart';
import '../database/db_helper.dart';

class AIService {
  static const String aiUrl = 'https://mobile-ios-ia.zani0x03.eti.br/api/ai/chat';

  static Future<String> obterDicasFinanceiras() async {
    try {
      String? token = await AuthService.getToken();
      
      // Busca os dados do SQLite para criar o resumo
      final lancamentos = await DBHelper.instance.getAll();
      
      double totalEntradas = 0;
      double totalSaidas = 0;
      String resumoGastos = "";

      if (lancamentos.isEmpty) {
        resumoGastos = "Nenhum gasto cadastrado ainda.";
      } else {
        for (var l in lancamentos) {
          if (l.isEntrada) {
            totalEntradas += l.valor;
          } else {
            totalSaidas += l.valor;
          }
        }
        resumoGastos = lancamentos.map((l) => 
          "- ${l.item}: R\$ ${l.valor.toStringAsFixed(2)} (${l.isEntrada ? 'Entrada' : 'Saída'})"
        ).join("\n");
      }

      String prompt = "Analise minhas finanças e me dê uma dica rápida de economia com base nisso:\n$resumoGastos";

      // 🚀 Envia a requisição para o servidor de IA
      final response = await http.post(
        Uri.parse(aiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'prompt': prompt}),
      ).timeout(const Duration(seconds: 180));

      // 🔍 PRINTS ADICIONADOS PARA VOCÊ VER NO TERMINAL!
      print("🌐 [HTTP IA STATUS]: ${response.statusCode}");
      print("🌐 [HTTP IA BODY]: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? data['text'] ?? response.body;
      }
      
      // Trata erros de servidor comuns (como o 502 Bad Gateway que seu app previa)
      if (response.statusCode == 502) return "erro_servidor";
      
    } catch (e) {
      print("🚨 [CATCH IA ERROR]: $e");
      if (e.toString().contains("TimeoutException")) {
        return "erro_timeout";
      }
    }

    // ========== MOCK / MODO OFFLINE SE A API FALHAR ==========
    print("🤖 [IA OFFLINE]: API fora do ar ou sem resposta. Gerando dica local...");
    final lancamentos = await DBHelper.instance.getAll();
    if (lancamentos.isEmpty) {
      return "🤖 [FinControl IA]: Ainda não vi movimentações no seu banco local. Adicione algumas entradas ou saídas na aba 'Lançamentos' para eu analisar seu perfil!";
    }

    double entradas = 0;
    double saidas = 0;
    for (var l in lancamentos) {
      l.isEntrada ? entradas += l.valor : saidas += l.valor;
    }

    if (saidas > entradas) {
      return "🚨 [FinControl IA]: Atenção! Suas saídas (R\$ ${saidas.toStringAsFixed(2)}) superaram suas entradas. Recomendo cortar gastos supérfluos esta semana para equilibrar o saldo.";
    } else {
      double economia = entradas - saidas;
      return "🤖 [FinControl IA]: Parabéns! Você está no azul por R\$ ${economia.toStringAsFixed(2)}. Dica: Que tal separar 10% desse valor hoje mesmo para sua reserva de emergência?";
    }
  }
}