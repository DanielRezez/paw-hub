import 'package:flutter/material.dart';

class ItemAlimentacao {
  final String horario;
  final String alimento;
  final String quantidade;
  final String status;

  ItemAlimentacao({
    required this.horario,
    required this.alimento,
    required this.quantidade,
    required this.status,
  });

  Color get corStatus =>
      status.toLowerCase() == 'concluído' ? Colors.green : Colors.orange;
}

class TelaAgendaViewModel extends ChangeNotifier {
  final List<ItemAlimentacao> _itens = [
    ItemAlimentacao(horario: '07:00', alimento: 'Ração Premium', quantidade: '60g', status: 'Concluído'),
    ItemAlimentacao(horario: '12:00', alimento: 'Ração Premium', quantidade: '60g', status: 'Concluído'),
    ItemAlimentacao(horario: '18:30', alimento: 'Ração Premium', quantidade: '60g', status: 'Pendente'),
  ];

  List<ItemAlimentacao> get itens => _itens;

  void marcarComoConcluido(int index) {
    _itens[index] = ItemAlimentacao(
      horario: _itens[index].horario,
      alimento: _itens[index].alimento,
      quantidade: _itens[index].quantidade,
      status: 'Concluído',
    );
    notifyListeners();
  }

  // Novo método adicionado
  void adicionarItem({required String horario, required String alimento, required String quantidade}) {
    // A lógica para criar um novo ItemAlimentacao e adicioná-lo à lista _itens
    // Por padrão, o status será 'Pendente'
    final novoItem = ItemAlimentacao(
      horario: horario,
      alimento: alimento,
      quantidade: quantidade,
      status: 'Pendente', // Novo item é sempre pendente inicialmente
    );
    _itens.add(novoItem);
    // Você pode querer ordenar a lista _itens por horário aqui
    // Ex: _itens.sort((a, b) => a.horario.compareTo(b.horario));
    notifyListeners();
  }
}
