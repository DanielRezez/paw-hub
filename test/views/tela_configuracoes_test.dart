import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Importe o ViewModel e a Tela
import 'package:projeto_integrador2/viewmodels/configuracoes_viewmodel.dart';
import 'package:projeto_integrador2/views/tela_configuracoes.dart';

// Importe o mock que vamos gerar
import 'tela_configuracoes_test.mocks.dart';

// 1. Diga ao Mockito para gerar um dublê do ConfiguracoesViewModel
@GenerateMocks([ConfiguracoesViewModel])
void main() {
  // 2. Declare o dublê
  late MockConfiguracoesViewModel mockViewModel;

  // 3. 'setUp' antes de cada teste
  setUp(() {
    // Cria um dublê limpo
    mockViewModel = MockConfiguracoesViewModel();
  });

  // 4. Função auxiliar para construir a tela com o dublê
  Widget createWidgetUnderTest(WidgetTester tester) {
    return ChangeNotifierProvider<ConfiguracoesViewModel>.value(
      value: mockViewModel, // Injeta o dublê
      child: MaterialApp(
        home: TelaConfiguracoes(),
      ),
    );
  }

  // --- TAREFA: Testar se o clique no "Sair" exibe o AlertDialog ---
  testWidgets('Deve exibir AlertDialog ao clicar em "Sair da conta"', (WidgetTester tester) async {
    // PREPARAÇÃO (Arrange)
    // Ensina o dublê a "fingir" os valores que a tela vai pedir
    when(mockViewModel.isDarkMode).thenReturn(false);
    when(mockViewModel.notificationsEnabled).thenReturn(true);

    // AÇÃO (Act)
    // Renderiza a tela
    await tester.pumpWidget(createWidgetUnderTest(tester));

    // Procura o botão "Sair da conta" e clica
    await tester.tap(find.text('Sair da conta'));

    // Espera a animação do Dialog (pop-up) terminar
    await tester.pumpAndSettle();

    // VERIFICAÇÃO (Assert)
    // Verifica se o pop-up (AlertDialog) apareceu
    expect(find.byType(AlertDialog), findsOneWidget);
    // Verifica se o texto de confirmação está na tela
    expect(find.text('Você tem certeza que deseja sair?'), findsOneWidget);
  });

  // --- TAREFA: Testar se a confirmação no Dialog chama o logout ---
  testWidgets('Deve chamar viewModel.logout() ao confirmar no AlertDialog', (WidgetTester tester) async {
    // PREPARAÇÃO
    when(mockViewModel.isDarkMode).thenReturn(false);
    when(mockViewModel.notificationsEnabled).thenReturn(true);
    // Ensina o dublê que 'logout' não fará nada (é um Future<void>)
    when(mockViewModel.logout()).thenAnswer((_) async {});

    // AÇÃO
    await tester.pumpWidget(createWidgetUnderTest(tester));

    // 1. Clica em "Sair da conta"
    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();

    // 2. Clica no botão "Sair" de dentro do pop-up
    await tester.tap(find.widgetWithText(TextButton, 'Sair'));
    await tester.pumpAndSettle();

    // VERIFICAÇÃO
    // Verifica se o método 'logout' do dublê foi chamado 1 vez
    verify(mockViewModel.logout()).called(1);

    // Verifica se o pop-up desapareceu
    expect(find.byType(AlertDialog), findsNothing);
  });
}