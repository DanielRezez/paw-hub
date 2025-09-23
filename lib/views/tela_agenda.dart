import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrador2/viewmodels/agenda_viewmodel.dart';
import 'package:projeto_integrador2/viewmodels/sensor_viewmodel.dart'; // Importar SensorViewModel

// 1. Transformar em StatefulWidget
class TelaAgenda extends StatefulWidget {
  @override
  _TelaAgendaState createState() => _TelaAgendaState();
}

class _TelaAgendaState extends State<TelaAgenda> {
  // 2. Chamar fetchSensorData no initState
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SensorViewModel>(context, listen: false).fetchSensorData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final agendaViewModel = Provider.of<TelaAgendaViewModel>(context);
    // sensorViewModel pode ser acessado dentro do Consumer ou aqui se necessário
    // final sensorViewModel = Provider.of<SensorViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Agenda e Níveis')),
      body: Column(
        children: [
          // 3. Seção para exibir dados dos sensores
          Consumer<SensorViewModel>(
            builder: (context, sensorVM, child) {
              if (sensorVM.isLoading) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (sensorVM.errorMessage != null) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Erro ao carregar sensores: ${sensorVM.errorMessage}',
                      style: TextStyle(color: Colors.red)),
                );
              }
              // Exibe placeholders se não houver dados, ou os dados reais
              final nivelRacao = sensorVM.sensorData?.nivelRacao ?? 0.0;
              final nivelAgua = sensorVM.sensorData?.nivelAgua ?? 0.0;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Ração: ${nivelRacao.toStringAsFixed(1)}%', style: TextStyle(fontSize: 16)),
                    Text('Água: ${nivelAgua.toStringAsFixed(1)}%', style: TextStyle(fontSize: 16)),
                  ],
                ),
              );
            },
          ),
          Divider(),
          // ListView existente para a agenda
          Expanded(
            child: ListView.builder(
              itemCount: agendaViewModel.itens.length,
              itemBuilder: (context, index) {
                final item = agendaViewModel.itens[index];
                return Card(
                  color: item.corStatus.withOpacity(0.2),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('${item.horario} - ${item.alimento}'),
                    subtitle: Text('${item.quantidade} • ${item.status}'),
                    trailing: item.status == 'Pendente'
                        ? ActionChip(
                            avatar: Icon(Icons.schedule, color: Colors.orange),
                            label: Text('Pendente', style: TextStyle(color: Colors.orange)),
                            onPressed: () => agendaViewModel.marcarComoConcluido(index),
                            backgroundColor: Colors.orange.withOpacity(0.1),
                          )
                        : Chip(
                            avatar: Icon(Icons.pets, color: item.corStatus),
                            label: Text(item.status, style: TextStyle(color: item.corStatus)),
                            backgroundColor: item.corStatus.withOpacity(0.1),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // 4. Adicionar FloatingActionButton para adicionar novos itens
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarDialogoAdicionarItem(context, agendaViewModel);
        },
        child: Icon(Icons.add),
        tooltip: 'Adicionar Lembrete',
      ),
    );
  }

  // 5. Método para mostrar o diálogo de adicionar item
  void _mostrarDialogoAdicionarItem(BuildContext context, TelaAgendaViewModel agendaVM) {
    final _formKey = GlobalKey<FormState>();
    // Usar TimeOfDay para o picker e converter para String depois
    TimeOfDay? _selectedTime = TimeOfDay.now();
    final _horarioController = TextEditingController(
        text: _selectedTime.format(context) // Formato localizado
    );
    final _quantidadeController = TextEditingController();
    // O alimento pode ser fixo como "Ração" ou selecionável
    final String _alimento = 'Ração';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Nova Alimentação Programada'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _horarioController,
                  decoration: InputDecoration(labelText: 'Horário', hintText: 'HH:mm'),
                  readOnly: true, // Para forçar o uso do TimePicker
                  onTap: () async {
                    FocusScope.of(context).requestFocus(new FocusNode()); // Remove foco do teclado
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      // setState não é necessário aqui pois o controller é atualizado diretamente
                      // e o diálogo não depende de _selectedTime para rebuild.
                      _selectedTime = pickedTime;
                      _horarioController.text = pickedTime.format(dialogContext); // Usar dialogContext
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, defina o horário';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _quantidadeController,
                  decoration: InputDecoration(labelText: 'Quantidade', hintText: 'ex: 50g ou 1 porção'),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a quantidade';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Salvar'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Chamada ao método que será adicionado no TelaAgendaViewModel
                  agendaVM.adicionarItem(
                    horario: _horarioController.text,
                    alimento: _alimento, // Alimento fixo como "Ração" por enquanto
                    quantidade: _quantidadeController.text,
                  );
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
