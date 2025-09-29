import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrador2/viewmodels/agenda_viewmodel.dart';

class TelaAgenda extends StatelessWidget {
  const TelaAgenda({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TelaAgendaViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Agenda'),
            actions: [
              IconButton(
                icon: Icon(Icons.save),
                tooltip: 'Salvar Configurações',
                onPressed: () async {
                  bool success = await viewModel.salvarPerfil();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Configurações salvas!' : 'Erro ao salvar.'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: viewModel.perfilHorarios.length,
              itemBuilder: (context, index) {
                final refeicao = viewModel.perfilHorarios[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              // Usando o ID da refeição ou o índice para o título,
                              // já que a ordem e o número podem mudar.
                              'Refeição ${index + 1}', // Ou você pode querer usar um ID/nome da refeição se tiver
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_forever_outlined, color: Colors.redAccent), // Ícone alterado para indicar deleção permanente
                              tooltip: 'Remover esta refeição',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      title: Text('Remover Refeição ${index + 1}?'),
                                      content: Text('Esta ação é permanente e removerá a refeição da lista. A alteração será salva ao clicar no ícone de salvar na barra superior.'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Cancelar'),
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Remover', style: TextStyle(color: Colors.redAccent)),
                                          onPressed: () {
                                            // CHAMANDO O MÉTODO CORRETO AQUI
                                            viewModel.removerRefeicaoDefinitivamente(index);
                                            Navigator.of(dialogContext).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Horário:', style: Theme.of(context).textTheme.titleMedium),
                            TextButton(
                              child: Text(
                                refeicao.horario.format(context),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () async {
                                TimeOfDay? novoHorario = await showTimePicker(
                                  context: context,
                                  initialTime: refeicao.horario,
                                );
                                if (novoHorario != null) {
                                  viewModel.atualizarHorarioRefeicao(index, novoHorario);
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          initialValue: refeicao.quantidade,
                          decoration: InputDecoration(
                            labelText: 'Quantidade',
                            hintText: 'ex: 50g, 1 porção',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          keyboardType: TextInputType.text,
                          onChanged: (novaQuantidade) {
                            viewModel.atualizarQuantidadeRefeicao(index, novaQuantidade);
                          },
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ativar Refeição:', style: Theme.of(context).textTheme.titleMedium),
                            Switch(
                              value: refeicao.ativa,
                              activeThumbColor: Colors.teal,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              onChanged: (ativada) {
                                viewModel.toggleAtivacaoRefeicao(index);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              viewModel.adicionarNovaRefeicao();
            },
            tooltip: 'Adicionar Nova Refeição',
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}

