import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Importe seu ViewModel e seu Modelo
import 'package:projeto_integrador2/viewmodels/agenda_viewmodel.dart';
// Importe sua Tela (View)
import 'package:projeto_integrador2/views/tela_agenda.dart';

// Importe o arquivo de mock que VAMOS CRIAR
import 'tela_agenda_test.mocks.dart';

// 1. ANOTE o que você quer "mockar" (o ViewModel)
@GenerateMocks([TelaAgendaViewModel])
void main() {
  // 2. Declare o "dublê" (Mock)
  late MockTelaAgendaViewModel mockViewModel;

  // 3. Crie uma lista de dados "falsos" para os testes
  final List<RefeicaoProgramada> refeicoesFalsas = [
    RefeicaoProgramada(
      id: '1',
      horario: TimeOfDay(hour: 8, minute: 0),
      quantidade: '100g',
      ativa: true,
    ),
    RefeicaoProgramada(
      id: '2',
      horario: TimeOfDay(hour: 12, minute: 30),
      quantidade: '200g',
      ativa: false,
    ),
  ];

  // 4. 'setUp' roda antes de CADA teste
  setUp(() {
    // Cria um novo dublê limpo para cada teste
    mockViewModel = MockTelaAgendaViewModel();
  });

  // 5. Crie um "Construtor de Tela"
  // Esta é uma FUNÇÃO AUXILIAR que monta nossa tela
  // com o provider e o dublê injetado.
  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<TelaAgendaViewModel>.value(
      value: mockViewModel, // INJETA O DUBLÊ AQUI
      child: MaterialApp(
        home: TelaAgenda(),
      ),
    );
  }

  // --- TAREFA 1 e 2: Simular e Testar se a lista é renderizada ---
  testWidgets('Deve renderizar a lista de refeições do ViewModel', (WidgetTester tester) async {
    // PREPARAÇÃO (Arrange)
    // "Ensina" o dublê: Quando alguém pedir 'perfilHorarios',
    // retorne a lista de 2 refeições falsas.
    when(mockViewModel.perfilHorarios).thenReturn(refeicoesFalsas);

    // AÇÃO (Act)
    // Renderiza a tela
    await tester.pumpWidget(createWidgetUnderTest());

    // VERIFICAÇÃO (Assert)
    // Procura por Widgets do tipo 'Card'
    expect(find.byType(Card), findsNWidgets(2));
    // Procura pelo texto da primeira refeição
    expect(find.text('Refeição 1'), findsOneWidget);
    // Procura pela quantidade da segunda refeição
    expect(find.text('200g'), findsOneWidget);
  });

  // --- TAREFA 3: Testar o FloatingActionButton (Adicionar) ---
  testWidgets('Deve chamar adicionarNovaRefeicao ao clicar no FAB', (WidgetTester tester) async {
    // PREPARAÇÃO
    // Ensina o dublê a retornar uma lista VAZIA
    when(mockViewModel.perfilHorarios).thenReturn([]);

    // AÇÃO
    await tester.pumpWidget(createWidgetUnderTest());

    // Simula um clique no ícone de "add"
    await tester.tap(find.byIcon(Icons.add));

    // VERIFICAÇÃO
    // Verifica se o método 'adicionarNovaRefeicao' do dublê
    // foi chamado EXATAMENTE UMA VEZ.
    verify(mockViewModel.adicionarNovaRefeicao()).called(1);
  });

  // --- TAREFA 4: Testar o botão de Deletar ---
  testWidgets('Deve chamar removerRefeicaoDefinitivamente ao confirmar o dialog', (WidgetTester tester) async {
    // PREPARAÇÃO
    // Ensina o dublê a retornar UMA refeição (para ter o que deletar)
    when(mockViewModel.perfilHorarios).thenReturn([refeicoesFalsas[0]]);

    // AÇÃO
    await tester.pumpWidget(createWidgetUnderTest());

    // 1. Clica no ícone de deletar
    await tester.tap(find.byIcon(Icons.delete_forever_outlined));

    // 2. Espera o Dialog (pop-up) aparecer
    await tester.pumpAndSettle();

    // 3. Procura o botão "Remover" DENTRO do dialog e clica
    await tester.tap(find.widgetWithText(TextButton, 'Remover'));

    // 4. Espera o Dialog fechar
    await tester.pumpAndSettle();

    // VERIFICAÇÃO
    // Verifica se o método 'removerRefeicaoDefinitivamente'
    // foi chamado com o índice 0.
    verify(mockViewModel.removerRefeicaoDefinitivamente(0)).called(1);
  });

  // --- TAREFA 5: Testar o TextFormField (Quantidade) ---
  testWidgets('Deve chamar atualizarQuantidadeRefeicao ao digitar no TextFormField', (WidgetTester tester) async {
    // PREPARAÇÃO
    when(mockViewModel.perfilHorarios).thenReturn([refeicoesFalsas[0]]);

    // AÇÃO
    await tester.pumpWidget(createWidgetUnderTest());

    // 1. Encontra o TextFormField (só tem 1 na tela)
    Finder textFormField = find.byType(TextFormField);

    // 2. Simula o usuário digitando "50g"
    await tester.enterText(textFormField, '50g');

    // VERIFICAÇÃO
    // Verifica se o método 'atualizarQuantidadeRefeicao'
    // foi chamado com o índice 0 e o valor "50g".
    verify(mockViewModel.atualizarQuantidadeRefeicao(0, '50g')).called(1);
  });
}