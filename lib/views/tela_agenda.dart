import 'package:projeto_integrador2/utils/app_exports.dart'; // Import centralizado

class TelaAgenda extends StatelessWidget {
  const TelaAgenda({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TelaAgendaViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Agenda'),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Salvar Configurações',
                onPressed: () async {
                  bool success = await viewModel.salvarPerfil();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            success ? 'Configurações salvas!' : 'Erro ao salvar.'),
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
                              'Refeição ${index + 1}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever_outlined,
                                  color: Colors.redAccent),
                              tooltip: 'Remover esta refeição',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      title:
                                      Text('Remover Refeição ${index + 1}?'),
                                      content: const Text(
                                          'Esta ação é permanente e removerá a refeição da lista. '
                                              'A alteração será salva ao clicar no ícone de salvar na barra superior.'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancelar'),
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Remover',
                                              style: TextStyle(
                                                  color: Colors.redAccent)),
                                          onPressed: () {
                                            viewModel
                                                .removerRefeicaoDefinitivamente(
                                                index);
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
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Horário:',
                                style:
                                Theme.of(context).textTheme.titleMedium),
                            TextButton(
                              child: Text(
                                refeicao.horario.format(context),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () async {
                                TimeOfDay? novoHorario = await showTimePicker(
                                  context: context,
                                  initialTime: refeicao.horario,
                                );
                                if (novoHorario != null) {
                                  viewModel.atualizarHorarioRefeicao(
                                      index, novoHorario);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // ======= QUANTIDADE RAÇÃO =======
                        TextFormField(
                          key: Key('refeicao_${index}_quantidade'),
                          initialValue: refeicao.quantidadeRacao,
                          decoration: const InputDecoration(
                            labelText: 'Quantidade de ração',
                            hintText: 'ex: 50g, 1 porção',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          keyboardType: TextInputType.text,
                          onChanged: (novaQuantidade) {
                            viewModel.atualizarQuantidadeRacaoRefeicao(index, novaQuantidade);
                          },
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          initialValue: refeicao.quantidadeAgua,
                          decoration: const InputDecoration(
                            labelText: 'Quantidade de água (ml)',
                            hintText: 'ex: 200ml',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                          ),
                          keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (novaQuantidadeAgua) {
                            viewModel.atualizarQuantidadeAguaRefeicao(
                                index, novaQuantidadeAgua);
                          },
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ativar Refeição:',
                                style:
                                Theme.of(context).textTheme.titleMedium),
                            Switch(
                              value: refeicao.ativa,
                              activeThumbColor: Colors.teal,
                              materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
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
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
